// ember_theme.dart
// Design tokens for the ember account screens (Sign-in · Handle setup · Profile).
// Drop into lib/theme/ and import where needed.
//
// pubspec.yaml:  google_fonts: ^6.2.1
//
// ⚠️ SCALE: the HTML/React mockups are authored on a 980pt-wide canvas — that is
// ~2.5× a real iPhone (≈392pt logical width). Every pixel value in the reference
// source is therefore ~2.5× too big for Flutter logical points. The constants
// below are already converted to LOGICAL POINTS (raw ÷ 2.5). When you read a
// number off the .jsx source, divide it by 2.5.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Colors ───────────────────────────────────────────────────────────────────
class EmberColors {
  // surfaces / neutrals
  static const bg         = Color(0xFF070809);
  static const card       = Color(0xFF101316);
  static const cardHi     = Color(0xFF171B1F);
  static const field      = Color(0xFF15191D);
  static const border     = Color(0x1A96A5B4); // rgba(150,165,180,0.10)
  static const borderSoft = Color(0x0D96A5B4); // rgba(150,165,180,0.05)
  static const text       = Color(0xFFEEF1F4);
  static const dim        = Color(0xFF8A95A0);
  static const dimmer     = Color(0xFF4C555E);

  // brand ember (the warm accent)
  static const neon       = Color(0xFFFF6B1A);
  static const bright     = Color(0xFFFF8A45);
  static const deep       = Color(0xFFE85600);
  static const ink        = Color(0xFF1E0A00); // dark text on bright fills
  static const brandRgb   = Color(0xFFFF6B1A);

  // semantic — danger (destructive / errors)
  static const danger      = Color(0xFFFF6B6B);
  static const dangerSoft  = Color(0xFFFF8A8A);
  static const dangerDeep  = Color(0xFFE84545);
  static const dangerTint  = Color(0x17FF6B6B); // rgba(255,107,107,0.09)
  static const dangerLine  = Color(0x57FF6B6B); // rgba(255,107,107,0.34)

  // semantic — good (handle available)
  static const good        = Color(0xFF5FC56B);
  static const goodDeep     = Color(0xFF36A646);
  static const goodInk      = Color(0xFF04210C);

  // the brand gradient used on every primary fill (≈155°)
  static const Gradient brandFill = LinearGradient(
    begin: Alignment.topCenter, end: Alignment.bottomRight,
    colors: [bright, deep],
  );
  static const Gradient dangerFill = LinearGradient(
    begin: Alignment.topCenter, end: Alignment.bottomRight,
    colors: [danger, dangerDeep],
  );
}

// ── Type ─────────────────────────────────────────────────────────────────────
// Display = Space Grotesk; Mono micro-labels = JetBrains Mono.
TextStyle disp(double size, {FontWeight w = FontWeight.w600, Color color = EmberColors.text, double? height}) =>
    GoogleFonts.spaceGrotesk(
      fontSize: size, fontWeight: w, color: color, height: height,
      letterSpacing: -0.02 * size, // mockups use ~-0.02em to -0.04em on display
    );

TextStyle body(double size, {FontWeight w = FontWeight.w400, Color color = EmberColors.dim, double height = 1.4}) =>
    GoogleFonts.spaceGrotesk(fontSize: size, fontWeight: w, color: color, height: height);

// Uppercase mono label: letterSpacing 0.14em, all-caps.
TextStyle mono(double size, {Color color = EmberColors.dim, FontWeight w = FontWeight.w500}) =>
    GoogleFonts.jetBrainsMono(
      fontSize: size, fontWeight: w, color: color, letterSpacing: size * 0.14,
    );

// ── ThemeData ──────────────────────────────────────────────────────────────
ThemeData emberTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: EmberColors.bg,
    colorScheme: base.colorScheme.copyWith(
      surface: EmberColors.bg,
      primary: EmberColors.neon,
      error: EmberColors.danger,
    ),
    textTheme: GoogleFonts.spaceGroteskTextTheme(base.textTheme)
        .apply(bodyColor: EmberColors.text, displayColor: EmberColors.text),
  );
}
