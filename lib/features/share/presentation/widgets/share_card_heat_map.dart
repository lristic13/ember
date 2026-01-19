import 'package:flutter/material.dart';

import '../../../../core/constants/habit_gradients.dart';
import '../../../habits/domain/entities/habit_entry.dart';

/// Simplified year heat map grid for the share card preview.
/// Shows all days of the year in a compact grid format.
class ShareCardHeatMap extends StatelessWidget {
  final List<HabitEntry> entries;
  final int year;
  final HabitGradient gradient;

  const ShareCardHeatMap({
    super.key,
    required this.entries,
    required this.year,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    // Build a map of date -> entry for quick lookup
    final entryMap = <DateTime, HabitEntry>{};
    for (final entry in entries) {
      final dateKey = DateTime(entry.date.year, entry.date.month, entry.date.day);
      entryMap[dateKey] = entry;
    }

    // Calculate max value for intensity scaling
    final maxValue = entries.isEmpty
        ? 1.0
        : entries.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    // Build weeks for the year (GitHub-style: columns are weeks, rows are days)
    final weeks = _buildYearWeeks();

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate cell size to fit all 53 weeks
        const weekCount = 53;
        const dayCount = 7;
        const spacing = 1.5;

        // Calculate cell size based on available width
        final cellSize = (constraints.maxWidth - (spacing * (weekCount - 1))) / weekCount;

        // Check if we need to scale down based on height
        final maxCellSize = (constraints.maxHeight - (spacing * (dayCount - 1))) / dayCount;
        final finalCellSize = cellSize > maxCellSize ? maxCellSize : cellSize;

        return SizedBox(
          height: (finalCellSize * dayCount) + (spacing * (dayCount - 1)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: weeks.asMap().entries.map((weekEntry) {
              final weekIndex = weekEntry.key;
              final week = weekEntry.value;
              final isLast = weekIndex == weeks.length - 1;

              return Padding(
                padding: EdgeInsets.only(right: isLast ? 0 : spacing),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: week.asMap().entries.map((dayEntry) {
                    final dayIndex = dayEntry.key;
                    final date = dayEntry.value;
                    final isLastDay = dayIndex == week.length - 1;

                    return Padding(
                      padding: EdgeInsets.only(bottom: isLastDay ? 0 : spacing),
                      child: _buildCell(date, finalCellSize, entryMap, maxValue),
                    );
                  }).toList(),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  List<List<DateTime?>> _buildYearWeeks() {
    final firstDayOfYear = DateTime(year, 1, 1);
    final lastDayOfYear = DateTime(year, 12, 31);

    // Find the Monday of the week containing Jan 1
    final firstDayWeekday = firstDayOfYear.weekday; // 1 = Monday, 7 = Sunday
    final daysToSubtract = firstDayWeekday - 1;
    var currentDate = firstDayOfYear.subtract(Duration(days: daysToSubtract));

    final weeks = <List<DateTime?>>[];

    while (currentDate.isBefore(lastDayOfYear) ||
           currentDate.isAtSameMomentAs(lastDayOfYear) ||
           weeks.length < 53) {
      final week = <DateTime?>[];

      for (var day = 0; day < 7; day++) {
        if (currentDate.year == year) {
          week.add(currentDate);
        } else {
          week.add(null);
        }
        currentDate = currentDate.add(const Duration(days: 1));
      }

      weeks.add(week);

      if (weeks.length >= 53) break;
    }

    return weeks;
  }

  Widget _buildCell(
    DateTime? date,
    double cellSize,
    Map<DateTime, HabitEntry> entryMap,
    double maxValue,
  ) {
    if (date == null) {
      return SizedBox(width: cellSize, height: cellSize);
    }

    final dateKey = DateTime(date.year, date.month, date.day);
    final entry = entryMap[dateKey];
    final intensity = _calculateIntensity(entry, maxValue);
    final colors = gradient.getColorsForIntensity(intensity);

    return Container(
      width: cellSize,
      height: cellSize,
      decoration: BoxDecoration(
        color: colors.cellColor,
        borderRadius: BorderRadius.circular(cellSize * 0.2),
      ),
    );
  }

  double _calculateIntensity(HabitEntry? entry, double maxValue) {
    if (entry == null || entry.value <= 0) return 0.0;
    if (maxValue <= 0) return 0.0;

    final ratio = entry.value / maxValue;
    return 0.3 + (ratio * 0.7);
  }
}
