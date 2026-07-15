import 'package:flutter/material.dart';

class AppTheme {
  // ─── Brand Colors ───
  static const Color _brandBlue = Color(0xFF2563EB);
  static const Color _brandBlueDark = Color(0xFF93C5FD);

  // ─── Gender Colors (der/die/das) ───
  static const Color _derLight = Color(0xFF2563EB);
  static const Color _derDark = Color(0xFF60A5FA);
  static const Color _dieLight = Color(0xFFDB2777);
  static const Color _dieDark = Color(0xFFF472B6);
  static const Color _dasLight = Color(0xFF059669);
  static const Color _dasDark = Color(0xFF34D399);

  // ─── LIGHT THEME ───
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF8FAFC),
    colorScheme: const ColorScheme.light(
      primary: _brandBlue,
      primaryContainer: Color(0xFFDBEAFE),
      secondary: Color(0xFF7C3AED),
      secondaryContainer: Color(0xFFEDE9FE),
      tertiary: Color(0xFF059669),
      tertiaryContainer: Color(0xFFD1FAE5),
      surface: Color(0xFFFFFFFF),
      surfaceContainerHighest: Color(0xFFF1F5F9),
      onPrimary: Color(0xFFFFFFFF),
      onSurface: Color(0xFF0F172A),
      onSurfaceVariant: Color(0xFF64748B),
      outline: Color(0xFFCBD5E1),
      error: Color(0xFFDC2626),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), letterSpacing: -0.5),
      headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Color(0xFF334155)),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF64748B)),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
      labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF94A3B8), letterSpacing: 0.5),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
      ),
      color: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 72,
      elevation: 0,
      backgroundColor: Colors.white,
      indicatorColor: const Color(0xFFDBEAFE),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _brandBlue);
        }
        return const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF94A3B8));
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: _brandBlue, size: 24);
        }
        return const IconThemeData(color: Color(0xFF94A3B8), size: 24);
      }),
    ),
  );

  // ─── DARK THEME ───
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0A0A0F),
    colorScheme: const ColorScheme.dark(
      primary: _brandBlueDark,
      primaryContainer: Color(0xFF1E3A5F),
      secondary: Color(0xFFA78BFA),
      secondaryContainer: Color(0xFF2E1065),
      tertiary: Color(0xFF34D399),
      tertiaryContainer: Color(0xFF064E3B),
      surface: Color(0xFF141420),
      surfaceContainerHighest: Color(0xFF1E1E2E),
      onPrimary: Color(0xFF0A0A0F),
      onSurface: Color(0xFFE2E8F0),
      onSurfaceVariant: Color(0xFF94A3B8),
      outline: Color(0xFF334155),
      error: Color(0xFFF87171),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Color(0xFFF1F5F9), letterSpacing: -0.5),
      headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFFF1F5F9)),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFFF1F5F9)),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFFE2E8F0)),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Color(0xFFCBD5E1)),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF94A3B8)),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFFE2E8F0)),
      labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF64748B), letterSpacing: 0.5),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFF1E293B), width: 1),
      ),
      color: const Color(0xFF141420),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 72,
      elevation: 0,
      backgroundColor: const Color(0xFF0A0A0F),
      indicatorColor: const Color(0xFF1E3A5F),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _brandBlueDark);
        }
        return const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF64748B));
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: _brandBlueDark, size: 24);
        }
        return const IconThemeData(color: Color(0xFF64748B), size: 24);
      }),
    ),
  );

  // ─── GERMAN GENDER COLORS ───
  static Color getGenderColor(String article, bool isDark) {
    switch (article.toLowerCase()) {
      case 'der':
        return isDark ? _derDark : _derLight;
      case 'die':
        return isDark ? _dieDark : _dieLight;
      case 'das':
        return isDark ? _dasDark : _dasLight;
      default:
        return isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
    }
  }

  // ─── Gender Gradient (for flashcard backgrounds) ───
  static LinearGradient getGenderGradient(String article, bool isDark) {
    final color = getGenderColor(article, isDark);
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        color.withValues(alpha: isDark ? 0.15 : 0.08),
        color.withValues(alpha: isDark ? 0.05 : 0.02),
      ],
    );
  }
}