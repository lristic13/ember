import 'package:flutter/material.dart';

import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../../../core/constants/habit_gradients.dart';
import 'mini_month_cell.dart';

/// Month grid that expands cells to fill the available width.
class ExpandedMonthGrid extends StatelessWidget {
  final List<List<DateTime?>> calendarGrid;
  final DateTime today;
  final double cellSize;
  final double spacing;
  final String monthLabel;
  final Map<DateTime, double> entriesByDate;
  final Map<DateTime, double> intensitiesByDate;
  final HabitGradient gradient;
  final void Function(DateTime date, double currentValue)? onCellTap;

  const ExpandedMonthGrid({
    super.key,
    required this.calendarGrid,
    required this.today,
    required this.cellSize,
    required this.spacing,
    required this.monthLabel,
    required this.entriesByDate,
    required this.intensitiesByDate,
    required this.gradient,
    required this.onCellTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          monthLabel,
          style: AppTextStyles.labelMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.paddingXs),
        ...calendarGrid.map((week) {
          return Padding(
            padding: EdgeInsets.only(bottom: spacing),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: week.map((date) {
                return MiniMonthCell(
                  date: date,
                  today: today,
                  cellSize: cellSize,
                  entriesByDate: entriesByDate,
                  intensitiesByDate: intensitiesByDate,
                  gradient: gradient,
                  onCellTap: onCellTap,
                );
              }).toList(),
            ),
          );
        }),
      ],
    );
  }
}
