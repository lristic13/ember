import 'dart:ui';

abstract class AppColors {
  // Background
  static const Color background = Color(0xFF0D0D0F);
  static const Color surface = Color(0xFF1A1A1E);
  static const Color surfaceLight = Color(0xFF252529);

  // Ember gradient (heat map intensity)
  static const Color emberNone = Color(0xFF1A1A1E);
  static const Color emberLow = Color(0xFF3D2417);
  static const Color emberMedium = Color(0xFF6B3410);
  static const Color emberHigh = Color(0xFFB84D00);
  static const Color emberMax = Color(0xFFFF6B1A);
  static const Color emberGlow = Color(0xFFFF8C42);

  // Text
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFA0A0A0);
  static const Color textMuted = Color(0xFF606060);

  // Accent
  static const Color accent = Color(0xFFFF6B1A);

  // Semantic
  static const Color error = Color(0xFFCF6679);
  static const Color success = Color(0xFF4CAF50);

  /// Returns the ember color based on completion percentage (0.0 to 1.0)
  static Color getEmberColor(double percentage) {
    if (percentage <= 0) return emberNone;
    if (percentage <= 0.25) return emberLow;
    if (percentage <= 0.50) return emberMedium;
    if (percentage <= 0.75) return emberHigh;
    return emberMax;
  }

  /// Returns the ember color with glow support for overflow (capped at 150%).
  /// Returns a record with the cell color and optional glow color.
  static ({Color cellColor, Color? glowColor}) getEmberColorWithGlow(
    double percentage,
  ) {
    // Cap at 150%
    final cappedPercentage = percentage.clamp(0.0, 1.5);

    if (cappedPercentage <= 0) {
      return (cellColor: emberNone, glowColor: null);
    }
    if (cappedPercentage <= 0.25) {
      return (cellColor: emberLow, glowColor: null);
    }
    if (cappedPercentage <= 0.50) {
      return (cellColor: emberMedium, glowColor: null);
    }
    if (cappedPercentage <= 0.75) {
      return (cellColor: emberHigh, glowColor: null);
    }
    if (cappedPercentage <= 1.0) {
      return (cellColor: emberMax, glowColor: null);
    }
    // Overflow: 101-150% gets glow effect
    return (cellColor: emberMax, glowColor: emberGlow);
  }

  /// Returns the ember color for percentile-based intensity (0.0 to 1.0).
  /// Glow effect applies to top 10% (intensity >= 0.9).
  /// Any positive intensity shows at least emberLow color.
  static ({Color cellColor, Color? glowColor}) getEmberColorForIntensity(
    double intensity,
  ) {
    if (intensity <= 0) {
      return (cellColor: emberNone, glowColor: null);
    }
    if (intensity <= 0.25) {
      return (cellColor: emberLow, glowColor: null);
    }
    if (intensity <= 0.5) {
      return (cellColor: emberMedium, glowColor: null);
    }
    if (intensity <= 0.75) {
      return (cellColor: emberHigh, glowColor: null);
    }
    if (intensity < 0.9) {
      return (cellColor: emberMax, glowColor: null);
    }
    // Top 10% gets glow effect
    return (cellColor: emberMax, glowColor: emberGlow);
  }
}
