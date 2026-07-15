import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../../core/database/flashcard.dart';
import '../../main.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onScanTap;
  final VoidCallback onDeckTap;

  const HomeScreen({super.key, required this.onScanTap, required this.onDeckTap});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _totalCards = 0;
  int _dueCards = 0;
  int _masteredCards = 0;
  bool _isLoading = true;
  late AnimationController _animController;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic);
    _loadStats();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    final total = await isarDb.flashcards.count();
    final now = DateTime.now();
    final due = await isarDb.flashcards
        .filter()
        .nextReviewDateLessThan(now)
        .or()
        .nextReviewDateIsNull()
        .count();
    // "Mastered" = reviewed more than 3 times consecutively correct
    final mastered = await isarDb.flashcards
        .filter()
        .consecutiveCorrectGreaterThan(3)
        .count();

    setState(() {
      _totalCards = total;
      _dueCards = due;
      _masteredCards = mastered;
      _isLoading = false;
    });
    _animController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : FadeTransition(
                opacity: _fadeIn,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ─── Header ───
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  theme.colorScheme.primary,
                                  theme.colorScheme.secondary,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              Icons.auto_stories_rounded,
                              color: theme.colorScheme.onPrimary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Klarify', style: theme.textTheme.titleLarge),
                              Text('German Flashcards', style: theme.textTheme.bodyMedium),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // ─── Welcome Banner ───
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isDark
                                ? [const Color(0xFF1E3A5F), const Color(0xFF2E1065)]
                                : [const Color(0xFF2563EB), const Color(0xFF7C3AED)],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '🇩🇪',
                              style: TextStyle(fontSize: 36),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Willkommen zurück!',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _dueCards > 0
                                  ? 'You have $_dueCards card${_dueCards == 1 ? '' : 's'} waiting to review.'
                                  : 'All caught up! Scan a new page to keep learning.',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ─── Stats Row ───
                      Row(
                        children: [
                          Expanded(child: _StatTile(
                            icon: Icons.layers_rounded,
                            label: 'Total',
                            value: '$_totalCards',
                            color: theme.colorScheme.primary,
                            isDark: isDark,
                          )),
                          const SizedBox(width: 12),
                          Expanded(child: _StatTile(
                            icon: Icons.schedule_rounded,
                            label: 'Due',
                            value: '$_dueCards',
                            color: theme.colorScheme.error,
                            isDark: isDark,
                          )),
                          const SizedBox(width: 12),
                          Expanded(child: _StatTile(
                            icon: Icons.emoji_events_rounded,
                            label: 'Mastered',
                            value: '$_masteredCards',
                            color: theme.colorScheme.tertiary,
                            isDark: isDark,
                          )),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // ─── Quick Actions ───
                      Text('Quick Actions', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 14),

                      _ActionCard(
                        icon: Icons.camera_alt_rounded,
                        title: 'Scan Textbook',
                        subtitle: 'Take a photo → AI builds flashcards',
                        gradient: [
                          theme.colorScheme.primary.withValues(alpha: isDark ? 0.15 : 0.08),
                          theme.colorScheme.primary.withValues(alpha: isDark ? 0.05 : 0.02),
                        ],
                        iconColor: theme.colorScheme.primary,
                        onTap: widget.onScanTap,
                      ),

                      const SizedBox(height: 12),

                      _ActionCard(
                        icon: Icons.style_rounded,
                        title: 'Review Deck',
                        subtitle: _dueCards > 0
                            ? '$_dueCards card${_dueCards == 1 ? '' : 's'} ready to study'
                            : 'No cards due — you\'re all caught up!',
                        gradient: [
                          theme.colorScheme.secondary.withValues(alpha: isDark ? 0.15 : 0.08),
                          theme.colorScheme.secondary.withValues(alpha: isDark ? 0.05 : 0.02),
                        ],
                        iconColor: theme.colorScheme.secondary,
                        onTap: widget.onDeckTap,
                      ),

                      const SizedBox(height: 28),

                      // ─── Tip of the Day ───
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: theme.colorScheme.outline.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: Text('💡', style: TextStyle(fontSize: 22)),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Quick Tip', style: theme.textTheme.labelLarge),
                                  const SizedBox(height: 4),
                                  Text(
                                    'der → Blue, die → Pink, das → Green. '
                                    'The card border color helps you memorize the article!',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ],
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

// ─── Mini Stat Tile ───
class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.15 : 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 10),
          Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label, style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }
}

// ─── Action Card ───
class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final Color iconColor;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradient,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: iconColor.withValues(alpha: 0.15),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: iconColor, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(subtitle, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
