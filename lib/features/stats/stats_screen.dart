import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../../core/database/flashcard.dart';
import '../../core/theme/app_theme.dart';
import '../../main.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> with SingleTickerProviderStateMixin {
  int _total = 0;
  int _mastered = 0;
  int _learning = 0;
  int _newCards = 0;
  int _derCount = 0;
  int _dieCount = 0;
  int _dasCount = 0;
  int _otherCount = 0;
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
    final all = await isarDb.flashcards.where().findAll();
    final total = all.length;
    int mastered = 0, learning = 0, newCards = 0;
    int der = 0, die = 0, das = 0, other = 0;

    for (final card in all) {
      // Mastery status
      if (card.consecutiveCorrect > 3) {
        mastered++;
      } else if (card.consecutiveCorrect > 0) {
        learning++;
      } else {
        newCards++;
      }
      // Article breakdown
      switch ((card.article ?? '').toLowerCase()) {
        case 'der':
          der++;
          break;
        case 'die':
          die++;
          break;
        case 'das':
          das++;
          break;
        default:
          other++;
      }
    }

    setState(() {
      _total = total;
      _mastered = mastered;
      _learning = learning;
      _newCards = newCards;
      _derCount = der;
      _dieCount = die;
      _dasCount = das;
      _otherCount = other;
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
                          Icon(Icons.insights_rounded, color: theme.colorScheme.secondary, size: 28),
                          const SizedBox(width: 10),
                          Text('Progress', style: theme.textTheme.titleLarge),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // ─── Mastery Ring ───
                      _MasteryRing(
                        total: _total,
                        mastered: _mastered,
                        learning: _learning,
                        newCards: _newCards,
                        isDark: isDark,
                      ),

                      const SizedBox(height: 28),

                      // ─── Mastery Breakdown ───
                      Text('Mastery Breakdown', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 14),

                      _ProgressRow(
                        label: 'Mastered',
                        count: _mastered,
                        total: _total,
                        color: theme.colorScheme.tertiary,
                        icon: Icons.verified_rounded,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 10),
                      _ProgressRow(
                        label: 'Learning',
                        count: _learning,
                        total: _total,
                        color: const Color(0xFFF59E0B),
                        icon: Icons.trending_up_rounded,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 10),
                      _ProgressRow(
                        label: 'New',
                        count: _newCards,
                        total: _total,
                        color: theme.colorScheme.primary,
                        icon: Icons.fiber_new_rounded,
                        isDark: isDark,
                      ),

                      const SizedBox(height: 28),

                      // ─── Article Distribution ───
                      Text('Article Distribution', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 14),

                      Row(
                        children: [
                          Expanded(child: _ArticleTile(
                            article: 'der',
                            count: _derCount,
                            total: _total,
                            isDark: isDark,
                          )),
                          const SizedBox(width: 10),
                          Expanded(child: _ArticleTile(
                            article: 'die',
                            count: _dieCount,
                            total: _total,
                            isDark: isDark,
                          )),
                          const SizedBox(width: 10),
                          Expanded(child: _ArticleTile(
                            article: 'das',
                            count: _dasCount,
                            total: _total,
                            isDark: isDark,
                          )),
                        ],
                      ),

                      if (_otherCount > 0) ...[
                        const SizedBox(height: 10),
                        _ArticleTile(
                          article: 'Other',
                          count: _otherCount,
                          total: _total,
                          isDark: isDark,
                        ),
                      ],

                      const SizedBox(height: 28),

                      // ─── Achievement Badges ───
                      Text('Achievements', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 14),

                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _AchievementBadge(
                            icon: Icons.auto_stories_rounded,
                            title: 'First Scan',
                            unlocked: _total > 0,
                            isDark: isDark,
                          ),
                          _AchievementBadge(
                            icon: Icons.looks_one_rounded,
                            title: '10 Cards',
                            unlocked: _total >= 10,
                            isDark: isDark,
                          ),
                          _AchievementBadge(
                            icon: Icons.layers_rounded,
                            title: '50 Cards',
                            unlocked: _total >= 50,
                            isDark: isDark,
                          ),
                          _AchievementBadge(
                            icon: Icons.emoji_events_rounded,
                            title: 'First Master',
                            unlocked: _mastered > 0,
                            isDark: isDark,
                          ),
                          _AchievementBadge(
                            icon: Icons.local_fire_department_rounded,
                            title: '10 Mastered',
                            unlocked: _mastered >= 10,
                            isDark: isDark,
                          ),
                          _AchievementBadge(
                            icon: Icons.star_rounded,
                            title: '100 Cards',
                            unlocked: _total >= 100,
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

// ─── Mastery Ring ───
class _MasteryRing extends StatelessWidget {
  final int total, mastered, learning, newCards;
  final bool isDark;

  const _MasteryRing({
    required this.total,
    required this.mastered,
    required this.learning,
    required this.newCards,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentage = total > 0 ? ((mastered / total) * 100).round() : 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
              : [const Color(0xFFF0F4FF), const Color(0xFFF5F0FF)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          // Circular progress indicator
          SizedBox(
            width: 140,
            height: 140,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 140,
                  height: 140,
                  child: CircularProgressIndicator(
                    value: total > 0 ? mastered / total : 0,
                    strokeWidth: 12,
                    strokeCap: StrokeCap.round,
                    backgroundColor: theme.colorScheme.outline.withValues(alpha: 0.15),
                    color: theme.colorScheme.tertiary,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$percentage%',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text('mastered', style: theme.textTheme.labelSmall),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            total == 0
                ? 'Start scanning to build your vocabulary!'
                : mastered == total
                    ? 'You have mastered all your cards!'
                    : '$mastered of $total cards mastered',
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Progress Row with bar ───
class _ProgressRow extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final Color color;
  final IconData icon;
  final bool isDark;

  const _ProgressRow({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fraction = total > 0 ? count / total : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.15 : 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(label, style: theme.textTheme.titleMedium?.copyWith(fontSize: 14)),
                    Text('$count', style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700, color: color,
                    )),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: fraction,
                    minHeight: 6,
                    backgroundColor: theme.colorScheme.outline.withValues(alpha: 0.12),
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Article Distribution Tile ───
class _ArticleTile extends StatelessWidget {
  final String article;
  final int count;
  final int total;
  final bool isDark;

  const _ArticleTile({
    required this.article,
    required this.count,
    required this.total,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = article == 'Other'
        ? (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8))
        : AppTheme.getGenderColor(article, isDark);
    final pct = total > 0 ? ((count / total) * 100).round() : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.1 : 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(
            article,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color),
          ),
          const SizedBox(height: 6),
          Text(
            '$count',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface),
          ),
          const SizedBox(height: 2),
          Text(
            '$pct%',
            style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

// ─── Achievement Badge ───
class _AchievementBadge extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool unlocked;
  final bool isDark;

  const _AchievementBadge({
    required this.icon,
    required this.title,
    required this.unlocked,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = unlocked
        ? const Color(0xFFF59E0B)
        : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3);

    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: unlocked
            ? const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.1 : 0.06)
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: unlocked
              ? const Color(0xFFF59E0B).withValues(alpha: 0.3)
              : theme.colorScheme.outline.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: unlocked
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
          if (unlocked) ...[
            const SizedBox(height: 4),
            const Text('✓', style: TextStyle(fontSize: 12, color: Color(0xFFF59E0B))),
          ],
        ],
      ),
    );
  }
}
