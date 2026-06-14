import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';
import '../constants/habit_gradients.dart';
import 'app_colors_light.dart';

/// Theme-aware surface/text/border tokens for the redesigned screens.
///
/// Resolve once per build with `EmberPalette.of(context)` and read the named
/// fields, so the same widget renders correctly in both dark and light mode.
class EmberPalette {
  final Color bg;
  final Color card;
  final Color cardHi;
  final Color border;
  final Color borderSoft;
  final Color text;
  final Color dim;
  final Color dimmer;

  const EmberPalette({
    required this.bg,
    required this.card,
    required this.cardHi,
    required this.border,
    required this.borderSoft,
    required this.text,
    required this.dim,
    required this.dimmer,
  });

  static const EmberPalette dark = EmberPalette(
    bg: AppColors.background,
    card: AppColors.surface,
    cardHi: AppColors.surfaceLight,
    border: AppColors.border,
    borderSoft: AppColors.borderSoft,
    text: AppColors.textPrimary,
    dim: AppColors.textSecondary,
    dimmer: AppColors.textMuted,
  );

  static const EmberPalette light = EmberPalette(
    bg: AppColorsLight.background,
    card: AppColorsLight.surface,
    cardHi: AppColorsLight.surfaceLight,
    border: AppColorsLight.border,
    borderSoft: AppColorsLight.borderSoft,
    text: AppColorsLight.textPrimary,
    dim: AppColorsLight.textSecondary,
    dimmer: AppColorsLight.textMuted,
  );

  static EmberPalette of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;
}

/// The single brand accent (ember orange). Drives global chrome only:
/// wordmark dot, "today" rings, the today-summary chip, the Add Activity
/// button, and the Insights hero number.
abstract class EmberAccent {
  static const Color neon = Color(0xFFFF6B1A);
  static const Color bright = Color(0xFFFF8A45);
  static const Color deep = Color(0xFFE85600);
  static const Color ink = Color(0xFF1E0A00); // text on an accent fill

  static Color get chipFill => neon.withValues(alpha: 0.08);
  static Color get chipBorder => neon.withValues(alpha: 0.18);
  static Color glow(double opacity) => neon.withValues(alpha: opacity);
}

/// A habit's identity colour, derived from its gradient. Used ONLY on
/// habit-owned elements: its icon tile, completed calendar/week cells, its
/// checkmark, and its Insights row %/bars — never on global chrome.
class HabitColor {
  final Color base;
  final Color deep;
  final Color ink; // text/icon drawn on top of a filled habit cell

  const HabitColor({required this.base, required this.deep, required this.ink});

  factory HabitColor.fromGradient(HabitGradient gradient) {
    return HabitColor(
      base: gradient.max,
      deep: gradient.high,
      ink: Color.lerp(gradient.high, const Color(0xFF000000), 0.82)!,
    );
  }

  /// 155° fill gradient for tiles/cells/checkmarks.
  LinearGradient get fill => LinearGradient(
    begin: EmberGradients.begin155,
    end: EmberGradients.end155,
    colors: [base, deep],
  );
}

/// Shared gradient geometry. CSS 155° ≈ these Alignment endpoints.
abstract class EmberGradients {
  static const Alignment begin155 = Alignment(-0.9, -1);
  static const Alignment end155 = Alignment(0.9, 1);

  static LinearGradient accent155 = const LinearGradient(
    begin: begin155,
    end: end155,
    colors: [EmberAccent.bright, EmberAccent.deep],
  );
}

/// Type helpers for the redesign: Space Grotesk for display/numbers,
/// JetBrains Mono (UPPERCASE, wide tracking) for labels/data.
abstract class EmberText {
  static TextStyle display(
    double size, {
    required Color color,
    FontWeight weight = FontWeight.w600,
    double letterSpacingEm = -0.02,
    double height = 1.0,
  }) => GoogleFonts.spaceGrotesk(
    fontSize: size,
    fontWeight: weight,
    color: color,
    letterSpacing: size * letterSpacingEm,
    height: height,
  );

  static TextStyle mono(
    double size, {
    required Color color,
    FontWeight weight = FontWeight.w500,
  }) => GoogleFonts.jetBrainsMono(
    fontSize: size,
    fontWeight: weight,
    color: color,
    letterSpacing: size * 0.14,
    height: 1.2,
  );
}
