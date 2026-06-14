import 'package:flutter/material.dart';

import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/constants/habit_gradients.dart';
import '../../../../../core/utils/date_utils.dart' as date_utils;
import 'expanded_month_grid.dart';
import 'fixed_month_grid.dart';

class MiniMonthHeatmap extends StatelessWidget {
  final int year;
  final int month;
  final String monthLabel;
  final Map<DateTime, double> entriesByDate;
  final Map<DateTime, double> intensitiesByDate;
  final HabitGradient gradient;
  final void Function(DateTime date, double currentValue)? onCellTap;
  final bool expandToFill;

  const MiniMonthHeatmap({
    super.key,
    required this.year,
    required this.month,
    required this.monthLabel,
    required this.entriesByDate,
    required this.intensitiesByDate,
    required this.gradient,
    this.onCellTap,
    this.expandToFill = false,
  });

  List<List<DateTime?>> _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(year, month, 1);
    final lastDayOfMonth = DateTime(year, month + 1, 0);

    // Find the Monday before or on the first day of the month
    final firstDayWeekday = firstDayOfMonth.weekday;
    final daysToSubtract = firstDayWeekday - 1;
    final gridStart = firstDayOfMonth.subtract(Duration(days: daysToSubtract));

    // Calculate number of weeks needed
    final totalDays = lastDayOfMonth.day + daysToSubtract;
    final weeksNeeded = (totalDays / 7).ceil();

    final grid = <List<DateTime?>>[];
    var currentDate = gridStart;

    for (var week = 0; week < weeksNeeded; week++) {
      final weekDates = <DateTime?>[];
      for (var day = 0; day < 7; day++) {
        if (currentDate.month == month && currentDate.year == year) {
          weekDates.add(currentDate);
        } else {
          weekDates.add(null);
        }
        currentDate = currentDate.add(const Duration(days: 1));
      }
      grid.add(weekDates);
    }

    return grid;
  }

  @override
  Widget build(BuildContext context) {
    final calendarGrid = _buildCalendarGrid();
    final today = date_utils.DateUtils.dateOnly(DateTime.now());

    if (expandToFill) {
      return LayoutBuilder(
        builder: (context, constraints) {
          const spacing = AppDimensions.miniMonthCellSpacing;
          const labelBlock = 24.0; // month label + gap below it (with margin)
          final weeks = calendarGrid.length;

          final widthBased = (constraints.maxWidth - (6 * spacing)) / 7;

          // When height is bounded, also keep the grid within it so a 5- or
          // 6-week month never overflows the card.
          var cellSize = widthBased;
          if (constraints.hasBoundedHeight && weeks > 0) {
            final heightForCells =
                constraints.maxHeight - labelBlock - (weeks * spacing);
            final heightBased = heightForCells / weeks;
            if (heightBased < cellSize) cellSize = heightBased;
          }
          if (cellSize < 0) cellSize = 0;

          return ExpandedMonthGrid(
            calendarGrid: calendarGrid,
            today: today,
            cellSize: cellSize,
            spacing: spacing,
            monthLabel: monthLabel,
            entriesByDate: entriesByDate,
            intensitiesByDate: intensitiesByDate,
            gradient: gradient,
            onCellTap: onCellTap,
          );
        },
      );
    }

    return FixedMonthGrid(
      calendarGrid: calendarGrid,
      today: today,
      monthLabel: monthLabel,
      entriesByDate: entriesByDate,
      intensitiesByDate: intensitiesByDate,
      gradient: gradient,
      onCellTap: onCellTap,
    );
  }
}
