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
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOutBack),
    );
    _loadCards();
  }

  @override
  void dispose() {
    _flipController.dispose();
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

    setState(() {
      _currentIndex = nextIndex;
      _isFlipped = false;
    });
    _flipController.reset();
  }

  void _handleSwipe(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity < -200) {
      _goToCard(1);
    } else if (velocity > 200) {
      _goToCard(-1);
    }
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
              Row(
                children: [
                  Icon(Icons.style_rounded, color: theme.colorScheme.secondary, size: 28),
                  const SizedBox(width: 10),
                  Text('Review', style: theme.textTheme.titleLarge),
                  const Spacer(),
                  if (!_isLoading && _cards.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_currentIndex + 1} / ${_cards.length}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
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
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: theme.colorScheme.tertiary.withValues(alpha: isDark ? 0.12 : 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.auto_stories_rounded, size: 56, color: theme.colorScheme.tertiary),
          ),
          const SizedBox(height: 28),
          Text('No cards yet', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 10),
          Text(
            'Scan a textbook page to add flashcards,\nthen swipe through them here.',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCardReview(ThemeData theme, bool isDark) {
    final currentCard = _cards[_currentIndex];
    final article = currentCard.article ?? '';
    final genderColor = AppTheme.getGenderColor(article, isDark);
    final canGoBack = _currentIndex > 0;
    final canGoForward = _currentIndex < _cards.length - 1;

    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _flipCard,
            onHorizontalDragEnd: _handleSwipe,
            child: AnimatedBuilder(
              animation: _flipAnimation,
              builder: (context, child) {
                final angle = _flipAnimation.value * math.pi;
                final isFront = angle < math.pi / 2;
                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(angle),
                  child: isFront
                      ? _buildCardFront(theme, isDark, currentCard, genderColor)
                      : Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()..rotateY(math.pi),
                          child: _buildCardBack(theme, isDark, currentCard, genderColor),
                        ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.swipe_rounded, size: 18, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(
              _isFlipped ? 'Swipe left or right to change cards' : 'Tap to reveal',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            IconButton.filledTonal(
              onPressed: canGoBack ? () => _goToCard(-1) : null,
              icon: const Icon(Icons.chevron_left_rounded),
              tooltip: 'Previous card',
            ),
            const Spacer(),
            Text(
              canGoBack && canGoForward
                  ? 'Swipe to browse'
                  : canGoBack
                      ? 'Last card'
                      : canGoForward
                          ? 'First card'
                          : 'Only card',
              style: theme.textTheme.labelLarge,
            ),
            const Spacer(),
            IconButton.filledTonal(
              onPressed: canGoForward ? () => _goToCard(1) : null,
              icon: const Icon(Icons.chevron_right_rounded),
              tooltip: 'Next card',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCardFront(ThemeData theme, bool isDark, Flashcard card, Color genderColor) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppTheme.getGenderGradient(card.article ?? '', isDark),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: genderColor.withValues(alpha: 0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: genderColor.withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if ((card.article ?? '').isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: genderColor.withValues(alpha: isDark ? 0.2 : 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                card.article!,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: genderColor,
                ),
              ),
            ),
          const SizedBox(height: 16),
          Text(
            card.word ?? '',
            style: theme.textTheme.displayLarge?.copyWith(fontSize: 42),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCardBack(ThemeData theme, bool isDark, Flashcard card, Color genderColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: genderColor.withValues(alpha: 0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: genderColor.withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${card.article ?? ''} ${card.word ?? ''}',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: genderColor,
            ),
            textAlign: TextAlign.center,
          ),
          if ((card.pluralForm ?? '').isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Plural: ${card.pluralForm}',
              style: theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
            ),
          ],
          const SizedBox(height: 20),
          Container(
            width: 60,
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
        ],
      ),
    );
  }
}
