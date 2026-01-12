import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../domain/entities/habit.dart';
import '../viewmodels/habit_entries_viewmodel.dart';
import '../viewmodels/habit_statistics_viewmodel.dart';
import 'entry_editor_bottom_sheet.dart';
import 'habit_details_header.dart';
import 'habit_statistics_card.dart';
import 'month_heatmap.dart';
import 'view_year_button.dart';

class HabitDetailsContent extends ConsumerWidget {
  final Habit habit;

  const HabitDetailsContent({super.key, required this.habit});

  void _showEntryEditor(BuildContext context, DateTime date, double value) {
    showEntryEditorBottomSheet(
      context: context,
      habitId: habit.id,
      habitName: habit.name,
      unit: habit.unit,
      date: date,
      currentValue: value,
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
              onCellTap: (date, value) => _showEntryEditor(context, date, value),
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
