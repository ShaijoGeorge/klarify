import 'package:flutter/material.dart';

class AppTheme {
  // LIGHT MODE COLORS
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF8F9FA), // Clean, soft off-white
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF0061A4),    // Royal Blue
      surface: Color(0xFFFFFFFF),    // Pure white for cards
      onSurface: Color(0xFF1A1C1E),  // Deep charcoal text
    ),
    // Text styling for a premium look
    textTheme: const TextTheme(
      headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A1C1E)),
      bodyLarge: TextStyle(fontSize: 16, color: Color(0xFF42474E)),
    ),
  );

  // DARK MODE COLORS
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF000000), // Pure OLED Black
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF9ECAFF),    // Soft neon blue
      surface: Color(0xFF121212),    // Dark charcoal for cards
      onSurface: Color(0xFFE2E2E6),  // Bright off-white text
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFE2E2E6)),
      bodyLarge: TextStyle(fontSize: 16, color: Color(0xFFC2C7CF)),
    ),
  );

  // GERMAN GENDER CRAYONS
  // Blue for Masculine (der), Pink/Red for Feminine (die), Green for Neutral (das)
  static Color getGenderColor(String article, bool isDark) {
    switch (article.toLowerCase()) {
      case 'der':
        return isDark ? const Color(0xFF64B5F6) : const Color(0xFF1976D2);
      case 'die':
        return isDark ? const Color(0xFFF06292) : const Color(0xFFD81B60);
      case 'das':
        return isDark ? const Color(0xFF81C784) : const Color(0xFF388E3C);
      default:
        return isDark ? const Color(0xFF8E9196) : const Color(0xFF72777A);
    }
  }
}