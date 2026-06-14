// ember_share_card.dart
// Faithful Flutter port of the "Editorial" ember share card.
// Requires: google_fonts (pubspec: google_fonts: ^6.2.1)
//
// To render + share as a PNG, wrap EmberShareCard in a RepaintBoundary and
// use boundary.toImage(pixelRatio: 1080 / 360) — see captureCard() at bottom.

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Palette ────────────────────────────────────────────────────────────────
class Ember {
  static const bg = Color(0xFF060B08);
  static const cell = Color(0xFF141B16);
  static const cellBorder = Color(0x12A0C68C); // rgba(120,180,140,0.07)
  static const neon = Color(0xFF57F08C);
  static const neonBright = Color(0xFF86FFB1);
  static const neonDeep = Color(0xFF2FCB6E);
  static const ink = Color(0xFF062012);
  static const text = Color(0xFFEAF4EE);
  static const dim = Color(0xFF557A63);
  static const dimmer = Color(0xFF3C5247);
}

// Mono label style helper
TextStyle mono(
  double size, {
  Color color = Ember.dim,
  FontWeight w = FontWeight.w500,
}) => GoogleFonts.jetBrainsMono(
  fontSize: size,
  fontWeight: w,
  color: color,
  letterSpacing: size * 0.18,
  height: 1.2,
);

// ── A single day cell ────────────────────────────────────────────────────────
class DayCell extends StatelessWidget {
  final int day;
  final bool logged;
  final double size;
  const DayCell(this.day, {super.key, required this.logged, this.size = 100});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.26),
        gradient: logged
            ? const LinearGradient(
                begin: Alignment.topLeft, // ~155° approximation
                end: Alignment.bottomRight,
                colors: [Ember.neonBright, Ember.neon, Ember.neonDeep],
                stops: [0.0, 0.45, 1.0],
              )
            : null,
        color: logged ? null : Ember.cell,
        border: logged ? null : Border.all(color: Ember.cellBorder, width: 1),
        boxShadow: logged
            ? [
                BoxShadow(
                  color: const Color(0x3857F08C), // rgba(87,240,140,0.22)
                  blurRadius: size * 0.16,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      alignment: Alignment.center,
      // top sheen: a faint white overlay line for the inset highlight
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (logged)
            Positioned(
              top: 1,
              left: size * 0.18,
              right: size * 0.18,
              child: Container(height: 1, color: const Color(0x59FFFFFF)),
            ),
          Text(
            '$day',
            style: GoogleFonts.spaceGrotesk(
              fontSize: size * 0.34,
              fontWeight: FontWeight.w600,
              color: logged ? Ember.ink : Ember.dimmer,
              letterSpacing: -0.02 * size * 0.34,
            ),
          ),
        ],
      ),
    );
  }
}

// ── The month grid (Monday-start) ───────────────────────────────────────────
class CalendarGrid extends StatelessWidget {
  final Set<int> logged;
  final int leadingBlanks; // Jan 2026 starts Thursday → 3
  final int daysInMonth;
  final double cell;
  final double gap;
  const CalendarGrid({
    super.key,
    required this.logged,
    this.leadingBlanks = 3,
    this.daysInMonth = 31,
    this.cell = 100,
    this.gap = 14,
  });

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];
    for (var i = 0; i < leadingBlanks; i++) {
      items.add(SizedBox(width: cell, height: cell));
    }
    for (var d = 1; d <= daysInMonth; d++) {
      items.add(DayCell(d, logged: logged.contains(d), size: cell));
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children:
              ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                  .map(
                    (w) => Container(
                      width: cell,
                      margin: EdgeInsets.only(right: gap),
                      alignment: Alignment.center,
                      child: Text(w, style: mono(cell * 0.2)),
                    ),
                  )
                  .toList()
                ..last = Container(
                  width: cell,
                  alignment: Alignment.center,
                  child: Text('S', style: mono(cell * 0.2)),
                ),
        ),
        SizedBox(height: gap),
        Wrap(spacing: gap, runSpacing: gap, children: items),
      ],
    );
  }
}

// ── The full Editorial card (logical 360×640 → export at pixelRatio 3 = 1080×1920)
class EmberShareCard extends StatelessWidget {
  const EmberShareCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      height: 640,
      color: Ember.bg,
      padding: const EdgeInsets.fromLTRB(28, 33, 28, 31),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // wordmark
          Row(
            children: [
              Text(
                'ember',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Ember.text,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Ember.neonBright, Ember.neonDeep],
                  ),
                  boxShadow: [BoxShadow(color: Ember.neon, blurRadius: 10)],
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          // headline
          RichText(
            text: TextSpan(
              style: GoogleFonts.spaceGrotesk(
                fontSize: 39,
                height: 0.92,
                fontWeight: FontWeight.w600,
                letterSpacing: -2,
              ),
              children: const [
                TextSpan(
                  text: 'I trained\n',
                  style: TextStyle(color: Ember.dim),
                ),
                TextSpan(
                  text: '7 times\n',
                  style: TextStyle(color: Ember.neon),
                ),
                TextSpan(
                  text: 'in January.',
                  style: TextStyle(color: Ember.text),
                ),
              ],
            ),
          ),
          const Spacer(),
          Center(
            child: CalendarGrid(
              logged: {2, 3, 8, 9, 10, 12, 13},
              cell: 35,
              gap: 5,
            ),
          ),
          const Spacer(),
          // stat pills
          Row(
            children: [
              _pill('STREAK', '3 days'),
              const SizedBox(width: 6),
              _pill('BEST DAY', 'Monday'),
              const SizedBox(width: 6),
              _pill('LOGGED', '7 / 31'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pill(String k, String v) => Expanded(
    child: Container(
      padding: const EdgeInsets.fromLTRB(9, 9, 9, 9),
      decoration: BoxDecoration(
        color: const Color(0x0F57F08C),
        border: Border.all(color: const Color(0x2457F08C)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(k, style: mono(6.7)),
          const SizedBox(height: 4),
          Text(
            v,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Ember.text,
              letterSpacing: -0.4,
            ),
          ),
        ],
      ),
    ),
  );
}

// ── Capture to PNG for sharing ───────────────────────────────────────────────
// Wrap EmberShareCard in RepaintBoundary(key: cardKey) somewhere offstage,
// then call this to get 1080×1920 bytes you can hand to share_plus / save.
Future<Uint8List?> captureCard(GlobalKey cardKey) async {
  final boundary =
      cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
  if (boundary == null) return null;
  final image = await boundary.toImage(pixelRatio: 3.0); // 360*3 = 1080 wide
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  return bytes?.buffer.asUint8List();
}
