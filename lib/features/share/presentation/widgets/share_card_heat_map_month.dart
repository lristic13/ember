import 'package:flutter/material.dart';

import '../../../../core/constants/habit_gradients.dart';
import '../../../habits/domain/entities/habit_entry.dart';

/// Monthly heat map grid for the share card (1080x1920).
/// Renders a single month in a large, detailed calendar format.
class ShareCardHeatMapMonth extends StatelessWidget {
  final List<HabitEntry> entries;
  final int year;
  final int month;
  final HabitGradient gradient;

  static const List<String> _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  static const List<String> _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  const ShareCardHeatMapMonth({
    super.key,
    required this.entries,
    required this.year,
    required this.month,
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

    final calendarGrid = _buildCalendarGrid();

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final availableHeight = constraints.maxHeight;

        // Reserve space for month label and day headers
        const monthLabelHeight = 80.0;
        const dayHeaderHeight = 50.0;
        const spacing = 8.0;

        final gridHeight = availableHeight - monthLabelHeight - dayHeaderHeight - 24;
        final weeksCount = calendarGrid.length;

        // Calculate cell size - 7 columns (days)
        final cellWidth = (availableWidth - (spacing * 6)) / 7;
        final cellHeight = (gridHeight - (spacing * (weeksCount - 1))) / weeksCount;

        // Use smaller dimension for square cells, but allow some stretch
        final cellSize = cellWidth < cellHeight ? cellWidth : cellHeight;

        return Column(
          children: [
            // Month label
            SizedBox(
              height: monthLabelHeight,
              child: Center(
                child: Text(
                  _monthNames[month - 1],
                  style: TextStyle(
                    color: gradient.max,
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Day headers
            SizedBox(
              height: dayHeaderHeight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _dayLabels.asMap().entries.map((entry) {
                  final index = entry.key;
                  final label = entry.value;
                  return SizedBox(
                    width: cellSize,
                    child: Padding(
                      padding: EdgeInsets.only(right: index < 6 ? spacing : 0),
                      child: Center(
                        child: Text(
                          label,
                          style: TextStyle(
                            color: gradient.medium,
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            // Calendar grid
            Expanded(
              child: Center(
                child: SizedBox(
                  width: (cellSize * 7) + (spacing * 6),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: calendarGrid.asMap().entries.map((weekEntry) {
                      final weekIndex = weekEntry.key;
                      final week = weekEntry.value;

                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: weekIndex < calendarGrid.length - 1 ? spacing : 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: week.asMap().entries.map((dayEntry) {
                            final dayIndex = dayEntry.key;
                            final date = dayEntry.value;

                            return Padding(
                              padding: EdgeInsets.only(right: dayIndex < 6 ? spacing : 0),
                              child: _buildCell(date, cellSize, entryMap, maxValue),
                            );
                          }).toList(),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

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
        borderRadius: BorderRadius.circular(cellSize * 0.15),
        boxShadow: colors.glowColor != null
            ? [
                BoxShadow(
                  color: colors.glowColor!.withValues(alpha: 0.5),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          date.day.toString(),
          style: TextStyle(
            color: intensity > 0.3 ? Colors.white : gradient.medium,
            fontSize: cellSize * 0.35,
            fontWeight: FontWeight.w600,
          ),
        ),
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
