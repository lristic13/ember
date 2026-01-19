import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/habit_gradients.dart';
import '../../../../core/utils/date_utils.dart' as date_utils;
import '../viewmodels/habit_entries_state.dart';
import '../viewmodels/habit_entries_viewmodel.dart';
import '../viewmodels/intensity_viewmodel.dart';
import 'heatmap_cell.dart';

class WeekHeatmap extends ConsumerWidget {
  final String habitId;
  final HabitGradient gradient;
  final void Function(DateTime date, double currentValue)? onCellTap;

  const WeekHeatmap({
    super.key,
    required this.habitId,
    required this.gradient,
    this.onCellTap,
  });

  static const List<String> _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesState = ref.watch(habitEntriesViewModelProvider(habitId));
    final weekDates = date_utils.DateUtils.getWeekDates(DateTime.now());

    // Fetch intensities for the week
    final intensitiesAsync = ref.watch(
      habitIntensitiesProvider(
        habitId,
        startDate: weekDates.first,
        endDate: weekDates.last,
      ),
    );

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
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
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
            final intensity = intensitiesAsync.whenOrNull(
              data: (intensities) => intensities[date_utils.DateUtils.dateOnly(date)] ?? 0.0,
            ) ?? 0.0;

            return HeatmapCell(
              date: date,
              intensity: intensity,
              isToday: isToday,
              gradient: gradient,
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
