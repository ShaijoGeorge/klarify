import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../../core/database/flashcard.dart';
import '../../core/theme/app_theme.dart';
import '../../main.dart';

class DeckScreen extends StatefulWidget {
  const DeckScreen({super.key});

  @override
  State<DeckScreen> createState() => _DeckScreenState();
}

class _DeckScreenState extends State<DeckScreen> with SingleTickerProviderStateMixin {
  List<Flashcard> _cards = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  bool _isFlipped = false;
  bool _isReverseStudy = false; // false = DE->EN, true = EN->DE
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.92);
    _flipController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOutBack),
    );
    _loadCards();
  }

  @override
  void dispose() {
    _flipController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadCards() async {
    final cards = await isarDb.flashcards.where().findAll();

    setState(() {
      _cards = cards;
      _currentIndex = 0;
      _isLoading = false;
      _isFlipped = false;
    });
    _flipController.reset();
  }

  void _flipCard() {
    if (_isFlipped) {
      setState(() => _isFlipped = false);
      _flipController.reverse();
      return;
    }
    setState(() => _isFlipped = true);
    _flipController.forward();
  }

  void _goToCard(int delta) {
    final nextIndex = _currentIndex + delta;
    if (nextIndex < 0 || nextIndex >= _cards.length) return;

    _pageController.animateToPage(
      nextIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Row(
                children: [
                  Text('Review', style: theme.textTheme.titleLarge),
                  const Spacer(),
                  if (!_isLoading && _cards.isNotEmpty) ...[
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isReverseStudy = !_isReverseStudy;
                          _isFlipped = false;
                        });
                        _flipController.reset();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: scheme.surface,
                          border: Border.all(color: scheme.outline.withValues(alpha: isDark ? 0.15 : 0.5)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _isReverseStudy ? 'EN' : 'DE',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: scheme.primary,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.swap_horiz_rounded, size: 14, color: scheme.primary),
                            const SizedBox(width: 4),
                            Text(
                              _isReverseStudy ? 'DE' : 'EN',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: scheme.primary,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        key: ValueKey(_currentIndex),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: scheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_currentIndex + 1} / ${_cards.length}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: scheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Body ──
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _cards.isEmpty
                      ? _buildEmptyState(theme, isDark)
                      : _buildCardReview(theme, isDark),
            ),
          ],
        ),
      ),
    );
  }

  // Empty State (icon + title + subtitle)
  Widget _buildEmptyState(ThemeData theme, bool isDark) {
    final scheme = theme.colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.style_rounded, size: 64, color: scheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              'No cards yet',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Scan a textbook page to add flashcards,\nthen swipe through them here.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Card Review
  Widget _buildCardReview(ThemeData theme, bool isDark) {
    final scheme = theme.colorScheme;

    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
                _isFlipped = false;
              });
              _flipController.reset();
            },
            itemCount: _cards.length,
            itemBuilder: (context, index) {
              final card = _cards[index];
              final article = card.article ?? '';
              final genderColor = AppTheme.getGenderColor(article, isDark);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                child: GestureDetector(
                  onTap: () {
                    if (index == _currentIndex) _flipCard();
                  },
                  child: AnimatedBuilder(
                    animation: _flipAnimation,
                    builder: (context, child) {
                      final angle = index == _currentIndex ? _flipAnimation.value * math.pi : 0.0;
                      final isFront = angle < math.pi / 2;
                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateY(angle),
                        child: isFront
                            ? _buildCardFront(theme, isDark, card, genderColor)
                            : Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()..rotateY(math.pi),
                                child: _buildCardBack(theme, isDark, card, genderColor),
                              ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),

        // Hint Row
        Padding(
          padding: const EdgeInsets.only(bottom: 24, top: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isFlipped ? Icons.swipe_rounded : Icons.touch_app_rounded,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 6),
              Text(
                _isFlipped ? 'Swipe to browse' : 'Tap to reveal',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCardFront(ThemeData theme, bool isDark, Flashcard card, Color genderColor) {
    final scheme = theme.colorScheme;
    
    // Front styling depends on direction
    final gradient = _isReverseStudy ? null : AppTheme.getGenderGradient(card.article ?? '', isDark);
    final bgColor = _isReverseStudy ? scheme.surface : null;
    final borderColor = _isReverseStudy 
        ? scheme.outline.withValues(alpha: isDark ? 0.15 : 0.5) 
        : genderColor.withValues(alpha: isDark ? 0.25 : 0.18);
    final shadowColor = _isReverseStudy
        ? const Color(0x08000000)
        : genderColor.withValues(alpha: 0.08);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: bgColor,
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: const Color(0x08000000),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
          if (!_isReverseStudy)
            BoxShadow(
              color: shadowColor,
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!_isReverseStudy && (card.article ?? '').isNotEmpty)
            // Article chip (German -> English)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: genderColor.withValues(alpha: isDark ? 0.18 : 0.10),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                card.article!,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: genderColor,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          if (!_isReverseStudy && (card.article ?? '').isNotEmpty)
            const SizedBox(height: 16),

          // Main Word
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                _isReverseStudy ? (card.translation ?? '') : (card.word ?? ''),
                style: theme.textTheme.displayLarge?.copyWith(
                  fontSize: 42,
                  letterSpacing: -0.5,
                  color: _isReverseStudy ? scheme.onSurface : null,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardBack(ThemeData theme, bool isDark, Flashcard card, Color genderColor) {
    final scheme = theme.colorScheme;
    
    // Back styling depends on direction
    final gradient = _isReverseStudy ? AppTheme.getGenderGradient(card.article ?? '', isDark) : null;
    final bgColor = _isReverseStudy ? null : scheme.surface;
    final borderColor = _isReverseStudy 
        ? genderColor.withValues(alpha: isDark ? 0.25 : 0.18)
        : scheme.outline.withValues(alpha: isDark ? 0.15 : 0.5);
    final shadowColor = _isReverseStudy
        ? genderColor.withValues(alpha: 0.08)
        : const Color(0x08000000);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: bgColor,
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: const Color(0x08000000),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
          if (_isReverseStudy)
            BoxShadow(
              color: shadowColor,
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Top half (German in DE->EN, English in EN->DE)
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _isReverseStudy 
                  ? (card.translation ?? '')
                  : '${card.article ?? ''} ${card.word ?? ''}'.trim(),
              style: _isReverseStudy
                  ? theme.textTheme.headlineMedium?.copyWith(color: scheme.onSurface)
                  : TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: genderColor,
                    ),
              textAlign: TextAlign.center,
            ),
          ),

          // Plural form (only show if German is on top, DE->EN)
          if (!_isReverseStudy && (card.pluralForm ?? '').isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Plural: ${card.pluralForm}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],

          // Divider
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Container(
              width: 40,
              height: 2,
              decoration: BoxDecoration(
                color: scheme.outline.withValues(alpha: isDark ? 0.15 : 0.3),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),

          // Bottom half (English in DE->EN, German in EN->DE)
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _isReverseStudy
                  ? '${card.article ?? ''} ${card.word ?? ''}'.trim()
                  : (card.translation ?? ''),
              style: _isReverseStudy
                  ? theme.textTheme.displayLarge?.copyWith(
                      fontSize: 42,
                      letterSpacing: -0.5,
                      color: theme.textTheme.displayLarge?.color,
                    )
                  : theme.textTheme.headlineMedium?.copyWith(
                      color: scheme.onSurface,
                    ),
              textAlign: TextAlign.center,
            ),
          ),
          
          // Plural form (only show if German is on bottom, EN->DE)
          if (_isReverseStudy && (card.pluralForm ?? '').isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Plural: ${card.pluralForm}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
