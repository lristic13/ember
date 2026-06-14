import 'package:flutter/material.dart';

import '../../../../core/constants/editorial_card_style.dart';
import '../../../../core/constants/habit_gradient_presets.dart';
import '../../../../core/utils/statistics_calculator.dart';
import '../../../habits/domain/entities/habit.dart';
import '../../../habits/domain/entities/habit_entry.dart';
import 'editorial_calendar_grid.dart';
import 'editorial_card_headline.dart';
import 'editorial_card_wordmark.dart';
import 'editorial_stat_pill.dart';

/// The "Editorial" share card: a 9:16 story image built around a Monday-start
/// month calendar heat map.
///
/// Rendered at a fixed logical [width] × [height]; capture at a higher
/// `pixelRatio` (3.0 → 1080×1920) rather than enlarging the logical size.
class EditorialShareCard extends StatelessWidget {
  final Habit habit;
  final List<HabitEntry> entries;
  final int year;
  final int month;

  /// Logical canvas size. Export at pixelRatio 3.0 for a 1080×1920 PNG.
  static const double width = 360;
  static const double height = 640;

  static const List<String> _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  const EditorialShareCard({
    super.key,
    required this.habit,
    required this.entries,
    required this.year,
    required this.month,
  });

  @override
  Widget build(BuildContext context) {
    final accent = EditorialAccent.fromGradient(
      HabitGradientPresets.getById(habit.gradientId),
    );

    final daysInMonth = DateTime(year, month + 1, 0).day;
    final leadingBlanks = (DateTime(year, month, 1).weekday + 6) % 7;

    final monthEntries = entries
        .where((e) => e.value > 0 && e.date.year == year && e.date.month == month)
        .toList();
    final loggedDays = monthEntries.map((e) => e.date.day).toSet();
    final daysLogged = loggedDays.length;
    final longestStreak = StatisticsCalculator.calculateLongestStreak(monthEntries);
    final bestDay = StatisticsCalculator.calculateBestDay(monthEntries);

    const sidePad = 28.0;
    const gap = 5.0;
    final contentWidth = width - sidePad * 2;
    final cell = (contentWidth - gap * 6) / 7;

    return Container(
      width: width,
      height: height,
      color: EditorialCardColors.background,
      padding: const EdgeInsets.fromLTRB(sidePad, 33, sidePad, 31),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EditorialCardWordmark(accent: accent),
          const SizedBox(height: 40),
          EditorialCardHeadline(
            habitName: habit.name,
            daysLogged: daysLogged,
            monthName: _monthNames[month - 1],
            accent: accent,
          ),
          const Spacer(),
          Center(
            child: EditorialCalendarGrid(
              loggedDays: loggedDays,
              leadingBlanks: leadingBlanks,
              daysInMonth: daysInMonth,
              cell: cell,
              gap: gap,
              accent: accent,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: EditorialStatPill(
                  label: 'STREAK',
                  value: longestStreak == 1 ? '1 day' : '$longestStreak days',
                  accent: accent,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: EditorialStatPill(
                  label: 'BEST DAY',
                  value: bestDay ?? '—',
                  accent: accent,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: EditorialStatPill(
                  label: 'LOGGED',
                  value: '$daysLogged / $daysInMonth',
                  accent: accent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
