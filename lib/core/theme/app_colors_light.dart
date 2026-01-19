import 'dart:ui';

abstract class AppColorsLight {
  // Background
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF0F0F0);

  // Text
  static const Color textPrimary = Color(0xFF1A1A1E);
  static const Color textSecondary = Color(0xFF606060);
  static const Color textMuted = Color(0xFFA0A0A0);

  // Accent (same as dark theme for brand consistency)
  static const Color accent = Color(0xFFFF6B1A);

  // Semantic
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);

  // Card borders (subtle for definition on light backgrounds)
  static const Color cardBorder = Color(0xFFE0E0E0);
}
