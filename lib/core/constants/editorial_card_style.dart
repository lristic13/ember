import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'habit_gradients.dart';

/// Visual tokens for the "Editorial" share card.
///
/// The neutral darks/lights below are shared by every habit, while the accent
/// (filled-tile gradient, glow, headline highlight, pill tint) is derived from
/// the habit's own gradient via [EditorialAccent.fromGradient] so the card keeps
/// ember's per-habit colour identity instead of a fixed hue.
abstract class EditorialCardColors {
  static const Color background = Color(0xFF07070A);
  static const Color cell = Color(0xFF16181C);
  static const Color cellBorder = Color(0x12FFFFFF); // white @ ~7%
  static const Color text = Color(0xFFECEEF0);
  static const Color dim = Color(0xFF6C757D); // headline lead-in, labels
  static const Color dimmer = Color(0xFF454A50); // number on an empty tile
  static const Color sheen = Color(0x59FFFFFF); // top highlight on filled tiles
}

/// Accent colours for one habit's Editorial card, resolved from its gradient.
class EditorialAccent {
  final Color bright; // gradient top (lightest)
  final Color mid; // headline highlight, glow, gradient middle
  final Color deep; // gradient bottom
  final Color ink; // number burned into a filled tile

  const EditorialAccent({
    required this.bright,
    required this.mid,
    required this.deep,
    required this.ink,
  });

  factory EditorialAccent.fromGradient(HabitGradient gradient) {
    return EditorialAccent(
      bright: gradient.glow,
      mid: gradient.max,
      deep: gradient.high,
      ink: Color.lerp(gradient.high, const Color(0xFF000000), 0.78)!,
    );
  }

  Color get pillFill => mid.withValues(alpha: 0.06);
  Color get pillBorder => mid.withValues(alpha: 0.18);
  Color get glow => mid.withValues(alpha: 0.22);
}

/// Type styles for the Editorial card. Display copy uses Space Grotesk; small
/// uppercase labels use JetBrains Mono with wide tracking, per the design spec.
abstract class EditorialCardText {
  static TextStyle display(
    double size, {
    Color color = EditorialCardColors.text,
    FontWeight weight = FontWeight.w600,
    double? letterSpacing,
    double height = 1.0,
  }) => GoogleFonts.spaceGrotesk(
    fontSize: size,
    fontWeight: weight,
    color: color,
    letterSpacing: letterSpacing,
    height: height,
  );

  static TextStyle mono(
    double size, {
    Color color = EditorialCardColors.dim,
    FontWeight weight = FontWeight.w500,
  }) => GoogleFonts.jetBrainsMono(
    fontSize: size,
    fontWeight: weight,
    color: color,
    letterSpacing: size * 0.18,
    height: 1.2,
  );

  /// Pre-warms the card's fonts so a `RepaintBoundary` capture never renders a
  /// fallback-font frame. Await before generating the PNG.
  static Future<void> ensureLoaded() => GoogleFonts.pendingFonts([
    GoogleFonts.spaceGrotesk(),
    GoogleFonts.jetBrainsMono(),
  ]);
}
