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

class _DeckScreenState extends State<DeckScreen> with TickerProviderStateMixin {
  List<Flashcard> _dueCards = [];
  bool _isLoading = true;
  bool _isFlipped = false;
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOutBack),
    );
    _slideController = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _slideAnimation = Tween<Offset>(begin: Offset.zero, end: const Offset(1.5, 0)).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeInCubic),
    );
    _loadDueCards();
  }

  @override
  void dispose() {
    _flipController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadDueCards() async {
    final now = DateTime.now();
    final cards = await isarDb.flashcards
        .filter()
        .nextReviewDateLessThan(now)
        .or()
        .nextReviewDateIsNull()
        .findAll();

    setState(() {
      _dueCards = cards;
      _isLoading = false;
      _isFlipped = false;
    });
    _flipController.reset();
  }

  void _flipCard() {
    if (_isFlipped) return;
    setState(() => _isFlipped = true);
    _flipController.forward();
  }

  Future<void> _gradeCard(int multiplierInHours) async {
    if (_dueCards.isEmpty) return;

    final card = _dueCards.first;
    card.nextReviewDate = DateTime.now().add(Duration(hours: multiplierInHours));
    if (multiplierInHours >= 24) {
      card.consecutiveCorrect++;
    } else {
      card.consecutiveCorrect = 0;
    }

    await isarDb.writeTxn(() async {
      await isarDb.flashcards.put(card);
    });

    // Slide out animation, then pop the card
    await _slideController.forward();

    setState(() {
      _dueCards.removeAt(0);
      _isFlipped = false;
    });
    _flipController.reset();
    _slideController.reset();
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
                  Icon(Icons.style_rounded, color: theme.colorScheme.secondary, size: 28),
                  const SizedBox(width: 10),
                  Text('Review', style: theme.textTheme.titleLarge),
                  const Spacer(),
                  if (!_isLoading && _dueCards.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_dueCards.length} left',
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

              // ─── Main Content ───
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _dueCards.isEmpty
                        ? _buildEmptyState(theme, isDark)
                        : _buildCardReview(theme, isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Empty State ───
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
            child: Icon(Icons.celebration_rounded, size: 56, color: theme.colorScheme.tertiary),
          ),
          const SizedBox(height: 28),
          Text('All caught up!', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 10),
          Text(
            'No cards are due right now.\nGo scan a textbook page to add more!',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ─── Card Review ───
  Widget _buildCardReview(ThemeData theme, bool isDark) {
    final currentCard = _dueCards.first;
    final article = currentCard.article ?? '';
    final genderColor = AppTheme.getGenderColor(article, isDark);

    return Column(
      children: [
        // The Flashcard
        Expanded(
          child: SlideTransition(
            position: _slideAnimation,
            child: GestureDetector(
              onTap: _flipCard,
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
        ),

        const SizedBox(height: 24),

        // Grading Buttons (only when flipped)
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _isFlipped
              ? Row(
                  key: const ValueKey('buttons'),
                  children: [
                    _GradeButton(
                      label: 'Again',
                      subtitle: 'Now',
                      color: theme.colorScheme.error,
                      isDark: isDark,
                      onPressed: () => _gradeCard(0),
                    ),
                    const SizedBox(width: 8),
                    _GradeButton(
                      label: 'Hard',
                      subtitle: '12h',
                      color: const Color(0xFFF59E0B),
                      isDark: isDark,
                      onPressed: () => _gradeCard(12),
                    ),
                    const SizedBox(width: 8),
                    _GradeButton(
                      label: 'Good',
                      subtitle: '1d',
                      color: theme.colorScheme.tertiary,
                      isDark: isDark,
                      onPressed: () => _gradeCard(24),
                    ),
                    const SizedBox(width: 8),
                    _GradeButton(
                      label: 'Easy',
                      subtitle: '4d',
                      color: theme.colorScheme.primary,
                      isDark: isDark,
                      onPressed: () => _gradeCard(96),
                    ),
                  ],
                )
              : SizedBox(
                  key: const ValueKey('hint'),
                  height: 64,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.touch_app_rounded, size: 18, color: theme.colorScheme.onSurfaceVariant),
                        const SizedBox(width: 8),
                        Text('Tap the card to reveal', style: theme.textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ),
        ),

        const SizedBox(height: 8),
      ],
    );
  }

  // ─── Card Front ───
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
          // Article badge
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
          // Word
          Text(
            card.word ?? '',
            style: theme.textTheme.displayLarge?.copyWith(fontSize: 42),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ─── Card Back ───
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
          // Full word with article
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
          // Translation
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

// ─── Grade Button ───
class _GradeButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final Color color;
  final bool isDark;
  final VoidCallback onPressed;

  const _GradeButton({
    required this.label,
    required this.subtitle,
    required this.color,
    required this.isDark,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.15 : 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: color.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}