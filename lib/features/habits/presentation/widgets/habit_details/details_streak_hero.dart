import 'package:flutter/material.dart';

import '../../../../../core/theme/ember_tokens.dart';

/// The emotional payload of the details screen: the current streak as one big
/// glowing number in the habit's color, on a card with a soft radial glow.
class DetailsStreakHero extends StatelessWidget {
  final int currentStreak;
  final HabitColor color;

  const DetailsStreakHero({
    super.key,
    required this.currentStreak,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final palette = EmberPalette.of(context);

    return Container(
      decoration: BoxDecoration(
        color: palette.card,
        border: Border.all(color: palette.border),
        borderRadius: BorderRadius.circular(24),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: -40,
            child: Container(
              width: 220,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    color.base.withValues(alpha: 0.12),
                    color.base.withValues(alpha: 0.0),
                  ],
                  stops: const [0.0, 0.7],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 20),
            child: Column(
              children: [
                Text(
                  '🔥 CURRENT STREAK',
                  style: EmberText.mono(12, color: palette.dim),
                ),
                const SizedBox(height: 8),
                Text(
                  '$currentStreak',
                  style: EmberText.display(
                    78,
                    color: color.base,
                    letterSpacingEm: -0.04,
                  ).copyWith(
                    shadows: [
                      Shadow(color: color.base.withValues(alpha: 0.33), blurRadius: 40),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'DAYS IN A ROW',
                  style: EmberText.mono(12, color: palette.dim),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
