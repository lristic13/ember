import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/ember_tokens.dart';
import '../../../../../core/utils/statistics_calculator.dart';
import '../../../domain/entities/habit.dart';
import '../../viewmodels/habit_entries_viewmodel.dart';
import '../../viewmodels/habit_statistics_state.dart';
import '../../viewmodels/habit_statistics_viewmodel.dart';
import '../entry/entry_editor_bottom_sheet.dart';
import '../heatmap/month_heatmap.dart';
import 'details_stats_row.dart';
import 'details_streak_hero.dart';
import 'habit_details_header.dart';
import 'member_contributions_section.dart';
import 'shared_habit_danger_action.dart';
import 'view_year_button.dart';

class HabitDetailsContent extends ConsumerWidget {
  final Habit habit;

  const HabitDetailsContent({super.key, required this.habit});

  void _showEntryEditor(BuildContext context, DateTime date, double value) {
    showEntryEditorBottomSheet(
      context: context,
      habitId: habit.id,
      habitName: habit.name,
      trackingType: habit.trackingType,
      unit: habit.unit,
      date: date,
      currentValue: value,
    );
  }

  String _formatTotal(double value, String? unit) {
    final formatted = NumberFormat('#,##0.##').format(value);
    return (unit == null || unit.isEmpty) ? formatted : '$formatted $unit';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = EmberPalette.of(context);
    final color = HabitColor.fromGradient(habit.gradient);
    final statisticsState = ref.watch(habitStatisticsViewModelProvider(habit.id));
    final entriesAsync = ref.watch(allHabitEntriesProvider(habit.id));

    final stats = statisticsState is HabitStatisticsLoaded ? statisticsState : null;
    final entriesByDate = entriesAsync.asData?.value ?? const <DateTime, double>{};

    final now = DateTime.now();
    final List<DetailsStat> statItems;
    if (habit.isQuantity) {
      final monthTotal = StatisticsCalculator.calculateMonthTotal(
        entriesByDate,
        now.year,
        now.month,
      );
      final yearTotal = StatisticsCalculator.calculateYearTotal(
        entriesByDate,
        now.year,
      );
      statItems = [
        (value: '${stats?.longestStreak ?? 0}', label: 'LONGEST'),
        (value: _formatTotal(monthTotal, habit.unit), label: 'THIS MONTH'),
        (value: _formatTotal(yearTotal, habit.unit), label: 'THIS YEAR'),
      ];
    } else {
      var loggedThisMonth = 0;
      entriesByDate.forEach((date, value) {
        if (value > 0 &&
            date.year == now.year &&
            date.month == now.month &&
            date.day <= now.day) {
          loggedThisMonth++;
        }
      });
      final monthPct = now.day == 0
          ? 0
          : ((loggedThisMonth / now.day) * 100).round();
      statItems = [
        (value: '${stats?.longestStreak ?? 0}', label: 'LONGEST'),
        (value: '$loggedThisMonth', label: 'LOGGED'),
        (value: '$monthPct%', label: 'THIS MONTH'),
      ];
    }

    final topPadding = MediaQuery.of(context).padding.top + kToolbarHeight;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, topPadding + 8, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HabitDetailsHeader(habit: habit),
          const SizedBox(height: 26),
          DetailsStreakHero(
            currentStreak: stats?.currentStreak ?? 0,
            color: color,
          ),
          const SizedBox(height: 14),
          DetailsStatsRow(stats: statItems),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
            decoration: BoxDecoration(
              color: palette.card,
              border: Border.all(color: palette.border),
              borderRadius: BorderRadius.circular(24),
            ),
            child: entriesAsync.when(
              data: (entries) => MonthHeatmap(
                habitId: habit.id,
                entriesByDate: entries,
                gradient: habit.gradient,
                onCellTap: (date, value) => _showEntryEditor(context, date, value),
              ),
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (_, _) => const SizedBox.shrink(),
            ),
          ),
          const SizedBox(height: 16),
          ViewYearButton(habitId: habit.id, color: color.base),
          if (habit.isTogether) ...[
            const SizedBox(height: 16),
            MemberContributionsSection(habit: habit),
          ],
          if (habit.isShared) ...[
            const SizedBox(height: 16),
            SharedHabitDangerAction(habit: habit),
          ],
        ],
      ),
    );
  }
}
