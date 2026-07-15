import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../../core/services/ai_service.dart';
import '../../core/database/flashcard.dart';
import '../../main.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  // States: idle, scanning, aiProcessing, success, error
  String _phase = 'idle';
  String _statusMessage = '';
  int _savedCount = 0;
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

  Future<void> _scanTextbook() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo == null) return;

    setState(() {
      _phase = 'scanning';
      _statusMessage = 'Reading the textbook page…';
    });

    try {
      final inputImage = InputImage.fromFilePath(photo.path);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      setState(() {
        _phase = 'aiProcessing';
        _statusMessage = 'AI is building your flashcards…';
      });

      final List<Flashcard> generatedCards = await AiService.generateFlashcards(recognizedText.text);

      if (generatedCards.isNotEmpty) {
        await isarDb.writeTxn(() async {
          await isarDb.flashcards.putAll(generatedCards);
        });
        setState(() {
          _phase = 'success';
          _savedCount = generatedCards.length;
          _statusMessage = 'Added $_savedCount flashcards to your deck!';
        });
      } else {
        setState(() {
          _phase = 'error';
          _statusMessage = 'No German vocabulary found. Try a clearer page.';
        });
      }
    } catch (e) {
      setState(() {
        _phase = 'error';
        _statusMessage = 'Something went wrong:\n$e';
      });
    }
  }

  void _reset() {
    setState(() {
      _phase = 'idle';
      _statusMessage = '';
      _savedCount = 0;
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
      case 'scanning':
      case 'aiProcessing':
        return _buildProcessingState(theme, isDark);
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
          'Scan a Textbook Page',
          style: theme.textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Point your camera at a German textbook page. '
            'Our AI will extract the vocabulary and create flashcards automatically.',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
        const Spacer(flex: 2),
        // Scan button
        SizedBox(
          width: double.infinity,
          height: 58,
          child: ElevatedButton.icon(
            onPressed: _scanTextbook,
            icon: const Icon(Icons.auto_awesome_rounded, size: 22),
            label: const Text('Start Scanning'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
        const SizedBox(height: 16),
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
          '$_savedCount flashcard${_savedCount == 1 ? '' : 's'} added to your deck.',
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