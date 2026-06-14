import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/ember_tokens.dart';
import '../../../../core/utils/date_utils.dart' as date_utils;
import '../../../../shared/widgets/ember_icon_tile.dart';
import '../../../habits/presentation/viewmodels/habit_entries_viewmodel.dart';
import '../../domain/entities/activity_insight.dart';

/// One row in the insights ranked list: icon, name, "N of M days", a big
/// percentage in the habit's color, and a 7-segment last-week bar.
class InsightsRankedRow extends ConsumerWidget {
  final ActivityInsight insight;

  const InsightsRankedRow({super.key, required this.insight});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = EmberPalette.of(context);
    final habit = insight.activity;
    final color = HabitColor.fromGradient(habit.gradient);
    final pct = insight.consistencyPercent.round();

    final entries = ref.watch(allHabitEntriesProvider(habit.id)).asData?.value ??
        const <DateTime, double>{};
    final week = _lastSevenDays(entries);

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: palette.card,
        border: Border.all(color: palette.border),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              EmberIconTile(emoji: habit.emoji, color: color, size: 38),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: EmberText.display(17, color: palette.text),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${insight.daysLogged} OF ${insight.totalDays} DAYS',
                      style: EmberText.mono(10, color: palette.dim),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$pct%',
                style: EmberText.display(24, color: color.base, letterSpacingEm: -0.03),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < week.length; i++)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: i == week.length - 1 ? 0 : 5),
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: week[i] ? null : palette.cardHi,
                        gradient: week[i]
                            ? LinearGradient(colors: [color.base, color.deep])
                            : null,
                        border: week[i] ? null : Border.all(color: palette.borderSoft),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  List<bool> _lastSevenDays(Map<DateTime, double> entries) {
    final today = date_utils.DateUtils.dateOnly(DateTime.now());
    return [
      for (var i = 6; i >= 0; i--)
        (entries[date_utils.DateUtils.dateOnly(
              today.subtract(Duration(days: i)),
            )] ??
            0) >
            0,
    ];
  }
}
