import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/habit_gradients.dart';
import '../../../../core/utils/date_utils.dart' as date_utils;
import '../viewmodels/intensity_viewmodel.dart';
import 'heatmap_navigation.dart';
import 'month_heatmap_cell.dart';

class MonthHeatmap extends ConsumerStatefulWidget {
  final String habitId;
  final Map<DateTime, double> entriesByDate;
  final HabitGradient gradient;
  final void Function(DateTime date, double currentValue)? onCellTap;

  const MonthHeatmap({
    super.key,
    required this.habitId,
    required this.entriesByDate,
    required this.gradient,
    this.onCellTap,
  });

  @override
  ConsumerState<MonthHeatmap> createState() => _MonthHeatmapState();
}

class _MonthHeatmapState extends ConsumerState<MonthHeatmap> {
  late DateTime _selectedMonth;

  static const List<String> _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month);
  }

  void _goToPreviousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
  }

  void _goToNextMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    });
  }

  String _formatMonth(DateTime date) {
    return DateFormat.yMMMM().format(date);
  }

  List<List<DateTime?>> _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month,
      1,
    );
    final lastDayOfMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month + 1,
      0,
    );

    // Find the Monday before or on the first day of the month
    final firstDayWeekday = firstDayOfMonth.weekday; // 1 = Monday, 7 = Sunday
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
        if (currentDate.month == _selectedMonth.month) {
          weekDates.add(currentDate);
        } else {
          weekDates.add(null); // Outside current month
        }
        currentDate = currentDate.add(const Duration(days: 1));
      }
      grid.add(weekDates);
    }

    return grid;
  }

  double _getValueForDate(DateTime date) {
    final normalizedDate = date_utils.DateUtils.dateOnly(date);
    return widget.entriesByDate[normalizedDate] ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final calendarGrid = _buildCalendarGrid();
    final today = date_utils.DateUtils.dateOnly(DateTime.now());

    // Calculate date range for intensity calculation
    final firstDayOfMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month,
      1,
    );
    final lastDayOfMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month + 1,
      0,
    );

    final intensitiesAsync = ref.watch(
      habitIntensitiesProvider(
        widget.habitId,
        startDate: firstDayOfMonth,
        endDate: lastDayOfMonth,
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Navigation
        HeatmapNavigation(
          title: _formatMonth(_selectedMonth),
          onPrevious: _goToPreviousMonth,
          onNext: _goToNextMonth,
        ),
        const SizedBox(height: AppDimensions.paddingSm),

        // Day of week headers
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: _dayLabels.map((label) {
            return SizedBox(
              width: AppDimensions.monthHeatMapCellSize,
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

        // Calendar grid
        ...calendarGrid.map((week) {
          return Padding(
            padding: const EdgeInsets.only(
              bottom: AppDimensions.monthHeatMapCellSpacing,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: week.map((date) {
                if (date == null) {
                  return const SizedBox(
                    width: AppDimensions.monthHeatMapCellSize,
                    height: AppDimensions.monthHeatMapCellSize,
                  );
                }

                final value = _getValueForDate(date);
                final isToday = date_utils.DateUtils.isSameDay(date, today);
                final intensity =
                    intensitiesAsync.whenOrNull(
                      data: (intensities) =>
                          intensities[date_utils.DateUtils.dateOnly(date)] ??
                          0.0,
                    ) ??
                    0.0;

                return MonthHeatmapCell(
                  dayNumber: date.day,
                  intensity: intensity,
                  isToday: isToday,
                  gradient: widget.gradient,
                  onTap: widget.onCellTap != null
                      ? () => widget.onCellTap!(date, value)
                      : null,
                );
              }).toList(),
            ),
          );
        }),
      ],
    );
  }
}
