import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../../core/services/ai_service.dart';
import '../../core/database/flashcard.dart';
import '../../core/theme/app_theme.dart';
import '../../main.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  // States: idle, selecting, scanning, aiProcessing, scannedLibrary, test, success, error
  String _phase = 'idle';
  String _statusMessage = '';
  int _savedCount = 0;
  List<XFile> _selectedImages = [];
  List<Flashcard> _scannedCards = [];
  int _testIndex = 0;
  bool _showAnswer = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  Future<void> _addCameraPhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo == null) return;

    setState(() {
      _selectedImages.add(photo);
      _phase = 'selecting';
    });
  }

  Future<void> _addGalleryImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isEmpty) return;

    setState(() {
      _selectedImages.addAll(images);
      _phase = 'selecting';
    });
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
      if (_selectedImages.isEmpty) {
        _phase = 'idle';
      }
    });
  }

  Future<void> _processSelectedImages() async {
    if (_selectedImages.isEmpty) return;

    final totalPages = _selectedImages.length;
    setState(() {
      _phase = 'scanning';
      _statusMessage = totalPages == 1
          ? 'Reading the textbook page…'
          : 'Reading page 1 of $totalPages…';
    });

    try {
      final textBuffer = StringBuffer();
      for (var i = 0; i < _selectedImages.length; i++) {
        if (i > 0) {
          setState(() {
            _statusMessage = 'Reading page ${i + 1} of $totalPages…';
          });
        }

        final inputImage = InputImage.fromFilePath(_selectedImages[i].path);
        final RecognizedText recognizedText =
            await _textRecognizer.processImage(inputImage);
        textBuffer.writeln(recognizedText.text);
      }

      setState(() {
        _phase = 'aiProcessing';
        _statusMessage = 'AI is building your flashcards…';
      });

      final List<Flashcard> generatedCards =
          await AiService.generateFlashcards(textBuffer.toString());

      if (generatedCards.isNotEmpty) {
        await isarDb.writeTxn(() async {
          await isarDb.flashcards.putAll(generatedCards);
        });

        setState(() {
          _phase = 'scannedLibrary';
          _scannedCards = generatedCards;
          _savedCount = generatedCards.length;
          _testIndex = 0;
          _showAnswer = false;
          _selectedImages = [];
          _statusMessage = totalPages == 1
              ? 'Saved $_savedCount words from this scan.'
              : 'Saved $_savedCount words from $totalPages pages.';
        });
      } else {
        setState(() {
          _phase = 'error';
          _statusMessage = 'No German vocabulary found. Try clearer photos.';
        });
      }
    } catch (e) {
      setState(() {
        _phase = 'error';
        _statusMessage = 'Something went wrong:\n$e';
      });
    }
  }

  void _startTest() {
    if (_scannedCards.isEmpty) return;
    setState(() {
      _phase = 'test';
      _testIndex = 0;
      _showAnswer = false;
      _statusMessage = 'Flashcard test for this scan.';
    });
  }

  void _toggleTestAnswer() {
    setState(() => _showAnswer = !_showAnswer);
  }

  void _moveTest(int delta) {
    if (_scannedCards.isEmpty) return;

    setState(() {
      final nextIndex = _testIndex + delta;
      _testIndex = nextIndex < 0
          ? 0
          : nextIndex >= _scannedCards.length
              ? _scannedCards.length - 1
              : nextIndex;
      _showAnswer = false;
    });
  }

  void _finishTest() {
    setState(() {
      _phase = 'success';
      _statusMessage = 'Test complete. $_savedCount words are saved in your library.';
      _showAnswer = false;
    });
  }

  void _reset() {
    setState(() {
      _phase = 'idle';
      _statusMessage = '';
      _savedCount = 0;
      _selectedImages = [];
      _scannedCards = [];
      _testIndex = 0;
      _showAnswer = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            children: [
              // ─── Header ───
              Row(
                children: [
                  Icon(Icons.document_scanner_rounded,
                      color: theme.colorScheme.primary, size: 28),
                  const SizedBox(width: 10),
                  Text('Scanner', style: theme.textTheme.titleLarge),
                ],
              ),

              const SizedBox(height: 24),

              // ─── Main Content Area ───
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  switchInCurve: Curves.easeOutCubic,
                  child: _buildPhaseContent(theme, isDark),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhaseContent(ThemeData theme, bool isDark) {
    switch (_phase) {
      case 'selecting':
        return _buildSelectingState(theme, isDark);
      case 'scanning':
      case 'aiProcessing':
        return _buildProcessingState(theme, isDark);
      case 'scannedLibrary':
        return _buildScannedLibraryState(theme, isDark);
      case 'test':
        return _buildTestState(theme, isDark);
      case 'success':
        return _buildSuccessState(theme, isDark);
      case 'error':
        return _buildErrorState(theme, isDark);
      default:
        return _buildIdleState(theme, isDark);
    }
  }

  // ─── Idle: Ready to scan ───
  Widget _buildIdleState(ThemeData theme, bool isDark) {
    return Column(
      key: const ValueKey('idle'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(flex: 2),
        // Big camera icon area
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [const Color(0xFF1E3A5F), const Color(0xFF2E1065)]
                  : [const Color(0xFFDBEAFE), const Color(0xFFEDE9FE)],
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.camera_alt_rounded,
            size: 56,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Scan Textbook Pages',
          style: theme.textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Take multiple photos or pick images from your gallery. Add all vocab pages, then scan them together.',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
        const Spacer(flex: 2),
        SizedBox(
          width: double.infinity,
          height: 58,
          child: ElevatedButton.icon(
            onPressed: _addCameraPhoto,
            icon: const Icon(Icons.camera_alt_rounded, size: 22),
            label: const Text('Take Photos'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 58,
          child: OutlinedButton.icon(
            onPressed: _addGalleryImages,
            icon: const Icon(Icons.photo_library_rounded, size: 22),
            label: const Text('Choose from Gallery'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              side: BorderSide(color: theme.colorScheme.outline),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // ─── Selecting: review photos before scanning ───
  Widget _buildSelectingState(ThemeData theme, bool isDark) {
    final pageCount = _selectedImages.length;
    final pageLabel = pageCount == 1 ? '1 page selected' : '$pageCount pages selected';

    return Column(
      key: const ValueKey('selecting'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: _reset,
              icon: const Icon(Icons.arrow_back_rounded, size: 16),
              label: const Text('Back'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                minimumSize: const Size(0, 36),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                pageLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Review your pages',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Add more photos from the camera or gallery, then scan all pages together.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        Expanded(
          child: GridView.builder(
            physics: const BouncingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: _selectedImages.length,
            itemBuilder: (context, index) {
              final image = _selectedImages[index];
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.file(
                      File(image.path),
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Material(
                      color: theme.colorScheme.errorContainer,
                      shape: const CircleBorder(),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => _removeImage(index),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: theme.colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 8,
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _addCameraPhoto,
                icon: const Icon(Icons.add_a_photo_rounded, size: 18),
                label: const Text('Camera'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _addGalleryImages,
                icon: const Icon(Icons.photo_library_rounded, size: 18),
                label: const Text('Gallery'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 58,
          child: ElevatedButton.icon(
            onPressed: _processSelectedImages,
            icon: const Icon(Icons.bolt_rounded, size: 22),
            label: Text(pageCount == 1 ? 'Scan Page' : 'Scan $pageCount Pages'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Processing: scanning / AI working ───
  Widget _buildProcessingState(ThemeData theme, bool isDark) {
    final isAI = _phase == 'aiProcessing';
    return Column(
      key: const ValueKey('processing'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(flex: 2),
        ScaleTransition(
          scale: _pulseAnim,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isAI
                    ? [const Color(0xFF7C3AED), const Color(0xFF2563EB)]
                    : [theme.colorScheme.primary, theme.colorScheme.secondary],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              isAI ? Icons.psychology_rounded : Icons.document_scanner_rounded,
              size: 48,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 36),
        Text(
          isAI ? 'AI is Thinking…' : 'Reading Page…',
          style: theme.textTheme.headlineMedium,
        ),
        const SizedBox(height: 12),
        Text(
          _statusMessage,
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: 200,
          child: LinearProgressIndicator(
            borderRadius: BorderRadius.circular(8),
            minHeight: 6,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            color: theme.colorScheme.primary,
          ),
        ),
        const Spacer(flex: 3),
      ],
    );
  }

  // ─── Scanned Library: only the current scan ───
  Widget _buildScannedLibraryState(ThemeData theme, bool isDark) {
    return Column(
      key: const ValueKey('scannedLibrary'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: _reset,
              icon: const Icon(Icons.arrow_back_rounded, size: 16),
              label: const Text('Back'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                minimumSize: const Size(0, 36),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: _startTest,
              icon: const Icon(Icons.quiz_rounded, size: 16),
              label: const Text('Take Test'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                minimumSize: const Size(0, 36),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Text(
              'Just scanned vocabulary',
              style: theme.textTheme.titleMedium,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                '$_savedCount saved',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Expanded(
          child: ListView.separated(
            physics: const BouncingScrollPhysics(),
            itemCount: _scannedCards.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final card = _scannedCards[index];
              final article = card.article ?? '';
              final genderColor = AppTheme.getGenderColor(article, isDark);

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: genderColor.withValues(alpha: isDark ? 0.15 : 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          article.isNotEmpty ? article : '-',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: genderColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(card.word ?? '', style: theme.textTheme.titleMedium),
                          const SizedBox(height: 2),
                          Text(card.translation ?? '', style: theme.textTheme.bodyMedium),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ─── Test: flashcards from only the current scan ───
  Widget _buildTestState(ThemeData theme, bool isDark) {
    final card = _scannedCards[_testIndex];
    final article = card.article ?? '';
    final genderColor = AppTheme.getGenderColor(article, isDark);
    final canGoBack = _testIndex > 0;
    final canGoForward = _testIndex < _scannedCards.length - 1;

    return Column(
      key: const ValueKey('test'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                '${_testIndex + 1} / ${_scannedCards.length}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _statusMessage,
                style: theme.textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Expanded(
          child: GestureDetector(
            onTap: _toggleTestAnswer,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: Container(
                key: ValueKey('${_testIndex}_$_showAnswer'),
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: _showAnswer
                      ? null
                      : AppTheme.getGenderGradient(card.article ?? '', isDark),
                  color: _showAnswer ? theme.colorScheme.surface : null,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: genderColor.withValues(alpha: 0.3), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: genderColor.withValues(alpha: 0.14),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (article.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        decoration: BoxDecoration(
                          color: genderColor.withValues(alpha: isDark ? 0.2 : 0.12),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          article,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: genderColor,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      card.word ?? '',
                      style: theme.textTheme.displayLarge?.copyWith(fontSize: 40),
                      textAlign: TextAlign.center,
                    ),
                    if (_showAnswer) ...[
                      const SizedBox(height: 20),
                      Container(
                        width: 56,
                        height: 2,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.outline.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        card.translation ?? '',
                        style: theme.textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      if ((card.pluralForm ?? '').isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          'Plural: ${card.pluralForm}',
                          style: theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ] else ...[
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.touch_app_rounded,
                              size: 18, color: theme.colorScheme.onSurfaceVariant),
                          const SizedBox(width: 8),
                          Text('Tap to reveal', style: theme.textTheme.bodyMedium),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            IconButton.filledTonal(
              onPressed: canGoBack ? () => _moveTest(-1) : null,
              icon: const Icon(Icons.chevron_left_rounded),
              tooltip: 'Previous card',
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton.icon(
                onPressed: canGoForward ? () => _moveTest(1) : _finishTest,
                icon: Icon(canGoForward ? Icons.chevron_right_rounded : Icons.check_rounded,
                    size: 20),
                label: Text(canGoForward ? 'Next Card' : 'Finish Test'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            IconButton.filledTonal(
              onPressed: () {
                setState(() {
                  _phase = 'scannedLibrary';
                  _showAnswer = false;
                });
              },
              icon: const Icon(Icons.list_rounded),
              tooltip: 'Back to scanned vocabulary',
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextButton.icon(
          onPressed: () {
            setState(() {
              _phase = 'scannedLibrary';
              _showAnswer = false;
            });
          },
          icon: const Icon(Icons.menu_book_rounded, size: 18),
          label: const Text('Back to Scanned Vocab'),
        ),
      ],
    );
  }

  // ─── Success ───
  Widget _buildSuccessState(ThemeData theme, bool isDark) {
    return Column(
      key: const ValueKey('success'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(flex: 2),
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: theme.colorScheme.tertiary.withValues(alpha: isDark ? 0.15 : 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle_rounded,
            size: 64,
            color: theme.colorScheme.tertiary,
          ),
        ),
        const SizedBox(height: 28),
        Text('Success!', style: theme.textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(
          _statusMessage.isNotEmpty
              ? _statusMessage
              : '$_savedCount flashcard${_savedCount == 1 ? '' : 's'} saved to your library.',
          style: theme.textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const Spacer(flex: 2),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _reset,
                icon: const Icon(Icons.camera_alt_rounded, size: 20),
                label: const Text('Scan Another'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  side: BorderSide(color: theme.colorScheme.outline),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // ─── Error ───
  Widget _buildErrorState(ThemeData theme, bool isDark) {
    return Column(
      key: const ValueKey('error'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(flex: 2),
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: theme.colorScheme.error.withValues(alpha: isDark ? 0.15 : 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: theme.colorScheme.error,
          ),
        ),
        const SizedBox(height: 28),
        Text('Oops!', style: theme.textTheme.headlineMedium),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              _statusMessage,
              style: theme.textTheme.bodyMedium?.copyWith(fontFamily: 'monospace', fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const Spacer(flex: 2),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _reset,
            icon: const Icon(Icons.refresh_rounded, size: 20),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
