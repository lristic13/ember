import 'package:flutter/material.dart';

import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../../../core/constants/habit_gradients.dart';
import 'mini_month_cell.dart';

/// Month grid with fixed-size cells.
class FixedMonthGrid extends StatelessWidget {
  final List<List<DateTime?>> calendarGrid;
  final DateTime today;
  final String monthLabel;
  final Map<DateTime, double> entriesByDate;
  final Map<DateTime, double> intensitiesByDate;
  final HabitGradient gradient;
  final void Function(DateTime date, double currentValue)? onCellTap;

  const FixedMonthGrid({
    super.key,
    required this.calendarGrid,
    required this.today,
    required this.monthLabel,
    required this.entriesByDate,
    required this.intensitiesByDate,
    required this.gradient,
    required this.onCellTap,
  });

  @override
  Widget build(BuildContext context) {
    const cellSize = AppDimensions.miniMonthCellSize;
    const spacing = AppDimensions.miniMonthCellSpacing;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          monthLabel,
          style: AppTextStyles.labelMedium,
        ),
        const SizedBox(height: AppDimensions.paddingXs),
        ...calendarGrid.map((week) {
          return Padding(
            padding: const EdgeInsets.only(bottom: spacing),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: week.map((date) {
                if (date == null) {
                  return Container(
                    width: cellSize,
                    height: cellSize,
                    margin: const EdgeInsets.only(right: spacing),
                  );
                }
                return Container(
                  margin: const EdgeInsets.only(right: spacing),
                  child: MiniMonthCell(
                    date: date,
                    today: today,
                    cellSize: cellSize,
                    entriesByDate: entriesByDate,
                    intensitiesByDate: intensitiesByDate,
                    gradient: gradient,
                    onCellTap: onCellTap,
                  ),
                );
              }).toList(),
            ),
          );
        }),
      ],
    );
  }
}
