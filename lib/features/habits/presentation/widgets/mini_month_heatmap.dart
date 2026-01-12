import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/date_utils.dart' as date_utils;

class MiniMonthHeatmap extends StatelessWidget {
  final int year;
  final int month;
  final String monthLabel;
  final Map<DateTime, double> entriesByDate;
  final Map<DateTime, double> intensitiesByDate;
  final void Function(DateTime date, double currentValue)? onCellTap;

  const MiniMonthHeatmap({
    super.key,
    required this.year,
    required this.month,
    required this.monthLabel,
    required this.entriesByDate,
    required this.intensitiesByDate,
    this.onCellTap,
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Month label
        Text(
          monthLabel,
          style: AppTextStyles.labelMedium,
        ),
        const SizedBox(height: AppDimensions.paddingXs),

        // Mini calendar grid
        ...calendarGrid.map((week) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.miniMonthCellSpacing),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: week.map((date) {
                if (date == null) {
                  return SizedBox(
                    width: AppDimensions.miniMonthCellSize,
                    height: AppDimensions.miniMonthCellSize,
                  );
                }

                final value = _getValueForDate(date);
                final intensity = _getIntensityForDate(date);
                final colors = AppColors.getEmberColorForIntensity(intensity);
                final isToday = date_utils.DateUtils.isSameDay(date, today);

                return GestureDetector(
                  onTap: onCellTap != null ? () => onCellTap!(date, value) : null,
                  child: Container(
                    width: AppDimensions.miniMonthCellSize,
                    height: AppDimensions.miniMonthCellSize,
                    margin: EdgeInsets.only(right: AppDimensions.miniMonthCellSpacing),
                    decoration: BoxDecoration(
                      color: colors.cellColor,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.miniMonthCellRadius,
                      ),
                      border: isToday
                          ? Border.all(color: AppColors.accent, width: 1)
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
                );
              }).toList(),
            ),
          );
        }),
      ],
    );
  }
}
