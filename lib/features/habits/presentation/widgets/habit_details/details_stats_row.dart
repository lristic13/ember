import 'package:flutter/material.dart';

import '../../../../../core/theme/ember_tokens.dart';

/// A single figure shown in [DetailsStatsRow].
typedef DetailsStat = ({String value, String label});

/// De-emphasized supporting stats under the streak hero: equal-weight figures
/// split by hairline dividers. Pass 2–3 [DetailsStat]s.
class DetailsStatsRow extends StatelessWidget {
  final List<DetailsStat> stats;

  const DetailsStatsRow({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final palette = EmberPalette.of(context);

    final children = <Widget>[];
    for (var i = 0; i < stats.length; i++) {
      if (i > 0) children.add(_divider(palette));
      children.add(_MiniStat(value: stats[i].value, label: stats[i].label));
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: BoxDecoration(
        color: palette.card,
        border: Border.all(color: palette.border),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(children: children),
    );
  }

  Widget _divider(EmberPalette palette) =>
      Container(width: 1, height: 34, color: palette.border);
}

class _MiniStat extends StatelessWidget {
  final String value;
  final String label;

  const _MiniStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final palette = EmberPalette.of(context);
    return Expanded(
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              maxLines: 1,
              style: EmberText.display(
                28,
                color: palette.text,
                letterSpacingEm: -0.03,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(label, style: EmberText.mono(10, color: palette.dim)),
        ],
      ),
    );
  }
}
