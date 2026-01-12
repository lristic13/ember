import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/habit.dart';
import '../viewmodels/habit_entries_viewmodel.dart';
import '../viewmodels/habit_statistics_viewmodel.dart';
import 'habit_details_header.dart';
import 'habit_statistics_card.dart';
import 'month_heatmap.dart';
import 'view_year_button.dart';

class HabitDetailsContent extends ConsumerWidget {
  final Habit habit;

  const HabitDetailsContent({super.key, required this.habit});

  void _showTooltip(BuildContext context, DateTime date, double value) {
    final formattedDate = '${date.day}/${date.month}/${date.year}';
    final valueText = value > 0
        ? '${value.toStringAsFixed(value == value.truncateToDouble() ? 0 : 1)} ${habit.unit}'
        : AppStrings.noEntry;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$formattedDate: $valueText'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statisticsState = ref.watch(
      habitStatisticsViewModelProvider(habit.id),
    );
    final entriesAsync = ref.watch(allHabitEntriesProvider(habit.id));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HabitDetailsHeader(habit: habit),
          const SizedBox(height: AppDimensions.paddingLg),
          HabitStatisticsCard(
            state: statisticsState,
            unit: habit.unit,
            accentColor: habit.gradient.primaryColor,
          ),
          const SizedBox(height: AppDimensions.paddingLg),
          entriesAsync.when(
            data: (entriesByDate) => MonthHeatmap(
              habitId: habit.id,
              entriesByDate: entriesByDate,
              gradient: habit.gradient,
              onCellTap: (date, value) => _showTooltip(context, date, value),
            ),
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(AppDimensions.paddingLg),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: AppDimensions.paddingMd),
          ViewYearButton(habitId: habit.id, color: habit.gradient.primaryColor),
        ],
      ),
    );
  }
}
