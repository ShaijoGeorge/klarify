import 'package:flutter/material.dart';
import '../../core/database/flashcard.dart';
import '../../main.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: scheme.outline.withValues(
                            alpha: isDark ? 0.15 : 0.5,
                          ),
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: scheme.onSurface,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text('Settings', style: theme.textTheme.titleLarge),
                ],
              ),

              const SizedBox(height: 28),

              // General Section
              _SectionHeader(title: 'GENERAL'),
              const SizedBox(height: 10),

              _SettingsGroup(
                isDark: isDark,
                children: [
                  ValueListenableBuilder<ThemeMode>(
                    valueListenable: themeNotifier,
                    builder: (context, themeMode, _) {
                      String themeText = 'System';
                      if (themeMode == ThemeMode.light) themeText = 'Light';
                      if (themeMode == ThemeMode.dark) themeText = 'Dark';

                      return _SettingsTile(
                        icon: Icons.palette_rounded,
                        title: 'Theme',
                        subtitle: themeMode == ThemeMode.system
                            ? 'Follows system setting'
                            : 'Custom theme applied',
                        isDark: isDark,
                        onTap: () => _showThemeSheet(context),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: scheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            themeText,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: scheme.primary,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  ValueListenableBuilder<String>(
                    valueListenable: fontNotifier,
                    builder: (context, currentFont, _) {
                      return _SettingsTile(
                        icon: Icons.font_download_rounded,
                        title: 'Font',
                        subtitle: currentFont,
                        isDark: isDark,
                        onTap: () => _showFontSheet(context),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: scheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            currentFont,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: scheme.primary,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Data Section
              _SectionHeader(title: 'DATA'),
              const SizedBox(height: 10),

              _SettingsGroup(
                isDark: isDark,
                children: [
                  _SettingsTile(
                    icon: Icons.delete_sweep_rounded,
                    title: 'Clear All Flashcards',
                    subtitle: 'Delete all saved cards from the database',
                    iconColor: scheme.error,
                    isDark: isDark,
                    onTap: () => _showClearDialog(context),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // About Section
              _SectionHeader(title: 'ABOUT'),
              const SizedBox(height: 10),

              _SettingsGroup(
                isDark: isDark,
                children: [
                  _SettingsTile(
                    icon: Icons.info_outline_rounded,
                    title: 'App Version',
                    subtitle: 'v1.0.0',
                    isDark: isDark,
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Footer
              Center(
                child: Column(
                  children: [
                    Text('Klarify German', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      'Made with ❤️ by Shaijo George',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
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

  void _showThemeSheet(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(
          color: scheme.outline.withValues(alpha: isDark ? 0.15 : 0.3),
        ),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Text('Select Theme', style: theme.textTheme.titleMedium),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                _ThemeOption(title: 'System Default', mode: ThemeMode.system),
                _ThemeOption(title: 'Light', mode: ThemeMode.light),
                _ThemeOption(title: 'Dark', mode: ThemeMode.dark),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFontSheet(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(
          color: scheme.outline.withValues(alpha: isDark ? 0.15 : 0.3),
        ),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Text('Select Font', style: theme.textTheme.titleMedium),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                _FontOption(title: 'Inter'),
                _FontOption(title: 'Roboto'),
                _FontOption(title: 'Open Sans'),
                _FontOption(title: 'Outfit'),
                _FontOption(title: 'Lora'),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showClearDialog(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: scheme.outline.withValues(alpha: isDark ? 0.15 : 0.5),
          ),
        ),
        title: Text(
          'Clear All Flashcards?',
          style: theme.textTheme.titleMedium,
        ),
        content: Text(
          'This will permanently delete all your saved flashcards. This action cannot be undone.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
          ),
          FilledButton(
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: scheme.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }
}

// Section Header
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Text(
      title,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        letterSpacing: 1.2,
        color: scheme.onSurfaceVariant,
      ),
    );
  }
}

// Settings Group
class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;
  final bool isDark;
  const _SettingsGroup({required this.children, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: scheme.outline.withValues(alpha: isDark ? 0.15 : 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0x08000000),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: List.generate(children.length * 2 - 1, (index) {
          if (index.isOdd) {
            return Divider(
              height: 1,
              indent: 56,
              color: scheme.outline.withValues(alpha: isDark ? 0.1 : 0.3),
            );
          }
          return children[index ~/ 2];
        }),
      ),
    );
  }
}

// Settings Tile
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? iconColor;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isDark;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
    this.iconColor,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = iconColor ?? scheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isDark ? 0.15 : 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleSmall),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
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

class _ThemeOption extends StatelessWidget {
  final String title;
  final ThemeMode mode;

  const _ThemeOption({required this.title, required this.mode});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, _) {
        final isSelected = currentMode == mode;

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
          title: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: isSelected ? scheme.primary : scheme.onSurface,
            ),
          ),
          trailing: isSelected
              ? Icon(Icons.check_circle_rounded, color: scheme.primary)
              : null,
          onTap: () async {
            themeNotifier.value = mode;
            String savedValue = 'system';
            if (mode == ThemeMode.light) savedValue = 'light';
            if (mode == ThemeMode.dark) savedValue = 'dark';
            await prefs.setString('themeMode', savedValue);
            if (context.mounted) Navigator.pop(context);
          },
        );
      },
    );
  }
}

class _FontOption extends StatelessWidget {
  final String title;

  const _FontOption({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return ValueListenableBuilder<String>(
      valueListenable: fontNotifier,
      builder: (context, currentFont, _) {
        final isSelected = currentFont == title;

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
          title: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: isSelected ? scheme.primary : scheme.onSurface,
            ),
          ),
          trailing: isSelected
              ? Icon(Icons.check_circle_rounded, color: scheme.primary)
              : null,
          onTap: () async {
            fontNotifier.value = title;
            await prefs.setString('fontFamily', title);
            if (context.mounted) Navigator.pop(context);
          },
        );
      },
    );
  }
}
