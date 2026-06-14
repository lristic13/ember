import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/ember_tokens.dart';
import '../../viewmodels/habit_statistics_state.dart';
import '../../viewmodels/habit_statistics_viewmodel.dart';

/// "🔥 N day streak" line shown under a habit's name, with the count in the
/// habit's identity color.
class HabitStreakChip extends ConsumerWidget {
  final String habitId;
  final HabitColor color;

  const HabitStreakChip({super.key, required this.habitId, required this.color});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = EmberPalette.of(context);
    final stats = ref.watch(habitStatisticsViewModelProvider(habitId));
    final streak = stats is HabitStatisticsLoaded ? stats.currentStreak : 0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('🔥', style: TextStyle(fontSize: 12)),
        const SizedBox(width: 5),
        Text(
          '$streak',
          style: EmberText.mono(12, color: color.base, weight: FontWeight.w600),
        ),
        const SizedBox(width: 5),
        Text('DAY STREAK', style: EmberText.mono(11, color: palette.dim)),
      ],
    );
  }
}
