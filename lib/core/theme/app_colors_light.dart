import 'dart:ui';

abstract class AppColorsLight {
  // Background / surfaces (light variant of the redesign palette)
  static const Color background = Color(0xFFF3F6F3);
  static const Color surface = Color(0xFFFFFFFF); // card
  static const Color surfaceLight = Color(0xFFEAF0EA); // raised chip / empty cell

  // Hairline borders
  static const Color border = Color(0x1F2E4A38); // dark green @ ~12%
  static const Color borderSoft = Color(0x0F2E4A38);

  // Text
  static const Color textPrimary = Color(0xFF0E1A12);
  static const Color textSecondary = Color(0xFF566B5E);
  static const Color textMuted = Color(0xFF93A399);

  // Accent (same as dark theme for brand consistency)
  static const Color accent = Color(0xFFFF6B1A);

  // Semantic
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);

  // Card borders (subtle for definition on light backgrounds)
  static const Color cardBorder = border;
}
