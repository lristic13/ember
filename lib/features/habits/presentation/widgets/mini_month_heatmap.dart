import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/habit_gradients.dart';
import '../../../../core/utils/date_utils.dart' as date_utils;

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

  double _getValueForDate(DateTime date) {
    final normalizedDate = date_utils.DateUtils.dateOnly(date);
    return entriesByDate[normalizedDate] ?? 0;
  }

  double _getIntensityForDate(DateTime date) {
    final normalizedDate = date_utils.DateUtils.dateOnly(date);
    return intensitiesByDate[normalizedDate] ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final calendarGrid = _buildCalendarGrid();
    final today = date_utils.DateUtils.dateOnly(DateTime.now());

    if (expandToFill) {
      return LayoutBuilder(
        builder: (context, constraints) {
          const spacing = AppDimensions.miniMonthCellSpacing;
          final cellSize = (constraints.maxWidth - (6 * spacing)) / 7;
          return _buildExpandedGrid(calendarGrid, today, cellSize, spacing);
        },
      );
    }

    return _buildFixedGrid(calendarGrid, today);
  }

  Widget _buildExpandedGrid(
    List<List<DateTime?>> calendarGrid,
    DateTime today,
    double cellSize,
    double spacing,
  ) {
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
                return _buildCell(date, today, cellSize);
              }).toList(),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildFixedGrid(List<List<DateTime?>> calendarGrid, DateTime today) {
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
                  child: _buildCell(date, today, cellSize),
                );
              }).toList(),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCell(DateTime? date, DateTime today, double cellSize) {
    if (date == null) {
      return SizedBox(width: cellSize, height: cellSize);
    }

    final value = _getValueForDate(date);
    final intensity = _getIntensityForDate(date);
    final colors = gradient.getColorsForIntensity(intensity);
    final isToday = date_utils.DateUtils.isSameDay(date, today);
    final isFuture = date_utils.DateUtils.isFuture(date);

    return GestureDetector(
      onTap: isFuture ? null : (onCellTap != null ? () => onCellTap!(date, value) : null),
      child: Opacity(
        opacity: isFuture ? 0.3 : 1.0,
        child: Container(
          width: cellSize,
          height: cellSize,
          decoration: BoxDecoration(
            color: colors.cellColor,
            borderRadius: BorderRadius.circular(AppDimensions.miniMonthCellRadius),
            border: isToday
                ? Border.all(color: gradient.primaryColor, width: 1)
                : null,
            boxShadow: colors.glowColor != null
                ? [
                    BoxShadow(
                      color: colors.glowColor!.withValues(alpha: 0.4),
                      blurRadius: 3,
                      spreadRadius: 0,
                    ),
                  ]
                : null,
          ),
        ),
      ),
    );
  }
}
