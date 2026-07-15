import 'package:flutter/material.dart';
import '../../core/database/flashcard.dart';
import '../../main.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Header ───
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.arrow_back_rounded,
                          color: theme.colorScheme.onSurface, size: 22),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text('Settings', style: theme.textTheme.titleLarge),
                ],
              ),

              const SizedBox(height: 28),

              // ─── General Section ───
              _SectionHeader(title: 'GENERAL'),
              const SizedBox(height: 10),

              _SettingsGroup(
                children: [
                  _SettingsTile(
                    icon: Icons.palette_rounded,
                    title: 'Theme',
                    subtitle: 'Follows system setting',
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        isDark ? 'Dark' : 'Light',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  _SettingsTile(
                    icon: Icons.translate_rounded,
                    title: 'Language',
                    subtitle: 'English',
                    trailing: Icon(Icons.chevron_right_rounded,
                        color: theme.colorScheme.onSurfaceVariant, size: 22),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ─── Data Section ───
              _SectionHeader(title: 'DATA'),
              const SizedBox(height: 10),

              _SettingsGroup(
                children: [
                  _SettingsTile(
                    icon: Icons.delete_sweep_rounded,
                    title: 'Clear All Flashcards',
                    subtitle: 'Delete all saved cards from the database',
                    iconColor: theme.colorScheme.error,
                    onTap: () => _showClearDialog(context),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ─── About Section ───
              _SectionHeader(title: 'ABOUT'),
              const SizedBox(height: 10),

              _SettingsGroup(
                children: [
                  _SettingsTile(
                    icon: Icons.info_outline_rounded,
                    title: 'App Version',
                    subtitle: '1.0.0',
                  ),
                  _SettingsTile(
                    icon: Icons.code_rounded,
                    title: 'Built With',
                    subtitle: 'Flutter · Isar · Gemini AI',
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // ─── Footer ───
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.secondary,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.auto_stories_rounded,
                        color: theme.colorScheme.onPrimary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Klarify German',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Made with ❤️ for German learners',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showClearDialog(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Clear All Flashcards?'),
        content: const Text(
          'This will permanently delete all your saved flashcards. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
          ),
          ElevatedButton(
            onPressed: () async {
              await isarDb.writeTxn(() async {
                await isarDb.flashcards.clear();
              });
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('All flashcards deleted.'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }
}

// ─── Section Header ───
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(letterSpacing: 1.2),
    );
  }
}

// ─── Settings Group ───
class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;
  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: List.generate(children.length * 2 - 1, (index) {
          if (index.isOdd) {
            return Divider(
              height: 1,
              indent: 58,
              color: theme.colorScheme.outline.withValues(alpha: 0.12),
            );
          }
          return children[index ~/ 2];
        }),
      ),
    );
  }
}

// ─── Settings Tile ───
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? iconColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconColor,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = iconColor ?? theme.colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                    Text(title, style: theme.textTheme.titleMedium?.copyWith(fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13)),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}
