import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/date_utils.dart' as date_utils;
import '../viewmodels/habit_entries_state.dart';
import '../viewmodels/habit_entries_viewmodel.dart';
import 'heatmap_cell.dart';

class WeekHeatmap extends ConsumerWidget {
  final String habitId;
  final double dailyGoal;
  final void Function(DateTime date, double currentValue)? onCellTap;

  const WeekHeatmap({
    super.key,
    required this.habitId,
    required this.dailyGoal,
    this.onCellTap,
  });

  static const List<String> _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesState = ref.watch(habitEntriesViewModelProvider(habitId));
    final weekDates = date_utils.DateUtils.getWeekDates(DateTime.now());

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Day labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _dayLabels.map((label) {
            return SizedBox(
              width: AppDimensions.weekHeatMapCellSize,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: AppDimensions.paddingXs),
        // Heatmap cells
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: weekDates.asMap().entries.map((entry) {
            final date = entry.value;
            final isToday = date_utils.DateUtils.isToday(date);
            final value = _getValueForDate(entriesState, date);

            return HeatmapCell(
              date: date,
              value: value,
              dailyGoal: dailyGoal,
              isToday: isToday,
              onTap: onCellTap != null
                  ? () => onCellTap!(date, value)
                  : null,
            );
          }).toList(),
        ),
      ],
    );
  }

  double _getValueForDate(HabitEntriesState state, DateTime date) {
    if (state is HabitEntriesLoaded) {
      return state.getValueForDate(date);
    }
    return 0;
  }
}
