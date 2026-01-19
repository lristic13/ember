import 'package:flutter/material.dart';

import '../../../../core/constants/habit_gradients.dart';
import '../../../habits/domain/entities/habit_entry.dart';

/// Full-size year heat map grid for the share card (1080x1920).
/// Renders 12 months in a grid layout (4 columns × 3 rows) with month labels.
class ShareCardHeatMapFull extends StatelessWidget {
  final List<HabitEntry> entries;
  final int year;
  final HabitGradient gradient;

  static const List<String> _monthLabels = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  const ShareCardHeatMapFull({
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
      final dateKey = DateTime(
        entry.date.year,
        entry.date.month,
        entry.date.day,
      );
      entryMap[dateKey] = entry;
    }

    // Calculate max value for intensity scaling
    final maxValue = entries.isEmpty
        ? 1.0
        : entries.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    const columns = 4;
    const rows = 3;

    return Column(
      children: List.generate(rows, (rowIndex) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: rowIndex < rows - 1 ? 40 : 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: List.generate(columns, (colIndex) {
                final monthIndex = rowIndex * columns + colIndex;
                final month = monthIndex + 1;

                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: colIndex < columns - 1 ? 20 : 0,
                    ),
                    child: _MonthWidget(
                      month: month,
                      year: year,
                      monthLabel: _monthLabels[monthIndex],
                      entryMap: entryMap,
                      maxValue: maxValue,
                      gradient: gradient,
                    ),
                  ),
                );
              }),
            ),
          ),
        );
      }),
    );
  }
}

class _MonthWidget extends StatelessWidget {
  final int month;
  final int year;
  final String monthLabel;
  final Map<DateTime, HabitEntry> entryMap;
  final double maxValue;
  final HabitGradient gradient;

  const _MonthWidget({
    required this.month,
    required this.year,
    required this.monthLabel,
    required this.entryMap,
    required this.maxValue,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final calendarGrid = _buildCalendarGrid();

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final availableHeight = constraints.maxHeight;

        // Reserve space for label
        const labelHeight = 32.0;
        const labelGap = 10.0;
        final gridHeight = availableHeight - labelHeight - labelGap;

        // Calculate cell size - 7 columns (days), up to 6 rows (weeks)
        const cellSpacing = 4.0;
        final cellWidth = (availableWidth - (cellSpacing * 6)) / 7;
        final cellHeight = (gridHeight - (cellSpacing * 5)) / 6; // Max 6 weeks

        // Use smaller dimension for square cells
        final cellSize = cellWidth < cellHeight ? cellWidth : cellHeight;

        return Column(
          children: [
            // Month label
            SizedBox(
              height: labelHeight,
              child: Center(
                child: Text(
                  monthLabel,
                  style: TextStyle(
                    color: gradient.max,
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(height: labelGap),
            // Calendar grid - centered
            Expanded(
              child: Center(
                child: SizedBox(
                  width: (cellSize * 7) + (cellSpacing * 6),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: calendarGrid.asMap().entries.map((weekEntry) {
                      final weekIndex = weekEntry.key;
                      final week = weekEntry.value;

                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: weekIndex < calendarGrid.length - 1
                              ? cellSpacing
                              : 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: week.asMap().entries.map((dayEntry) {
                            final dayIndex = dayEntry.key;
                            final date = dayEntry.value;

                            return Padding(
                              padding: EdgeInsets.only(
                                right: dayIndex < 6 ? cellSpacing : 0,
                              ),
                              child: _buildCell(date, cellSize),
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

  Widget _buildCell(DateTime? date, double cellSize) {
    if (date == null) {
      return SizedBox(width: cellSize, height: cellSize);
    }

    final dateKey = DateTime(date.year, date.month, date.day);
    final entry = entryMap[dateKey];
    final intensity = _calculateIntensity(entry);
    final colors = gradient.getColorsForIntensity(intensity);

    return Container(
      width: cellSize,
      height: cellSize,
      decoration: BoxDecoration(
        color: colors.cellColor,
        borderRadius: BorderRadius.circular(cellSize * 0.2),
        boxShadow: colors.glowColor != null
            ? [
                BoxShadow(
                  color: colors.glowColor!.withValues(alpha: 0.5),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
    );
  }

  double _calculateIntensity(HabitEntry? entry) {
    if (entry == null || entry.value <= 0) return 0.0;
    if (maxValue <= 0) return 0.0;

    final ratio = entry.value / maxValue;
    return 0.3 + (ratio * 0.7);
  }
}
