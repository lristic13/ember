import 'package:flutter/material.dart';

import '../../../../core/theme/ember_tokens.dart';

/// Hero summary: "You showed up the most for [habitName]" with that habit's big
/// accent consistency percentage and a soft accent glow.
class InsightsCompletionHero extends StatelessWidget {
  final String rangeLabel;
  final String habitName;
  final int percent;

  const InsightsCompletionHero({
    super.key,
    required this.rangeLabel,
    required this.habitName,
    required this.percent,
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
        children: [
          Positioned(
            top: -50,
            right: -20,
            child: Container(
              width: 200,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [EmberAccent.glow(0.16), EmberAccent.glow(0.0)],
                  stops: const [0.0, 0.7],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(rangeLabel, style: EmberText.mono(12, color: palette.dim)),
                      const SizedBox(height: 10),
                      RichText(
                        text: TextSpan(
                          style: EmberText.display(24, color: palette.text, letterSpacingEm: -0.02, height: 1.15),
                          children: [
                            const TextSpan(text: 'You showed up the most for '),
                            TextSpan(
                              text: habitName,
                              style: TextStyle(color: EmberAccent.neon),
                            ),
                            const TextSpan(text: '.'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '$percent%',
                  style: EmberText.display(
                    52,
                    color: EmberAccent.neon,
                    letterSpacingEm: -0.04,
                  ).copyWith(
                    shadows: [Shadow(color: EmberAccent.glow(0.45), blurRadius: 40)],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
