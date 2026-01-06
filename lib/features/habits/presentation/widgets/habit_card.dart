import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/router/app_router.dart';
import '../../domain/entities/habit.dart';
import '../viewmodels/habit_entries_state.dart';
import '../viewmodels/habit_entries_viewmodel.dart';
import 'entry_editor_bottom_sheet.dart';
import 'habit_emoji.dart';
import 'habit_progress_indicator.dart';
import 'quick_log_button.dart';
import 'week_heatmap.dart';

class HabitCard extends ConsumerWidget {
  final Habit habit;

  const HabitCard({
    super.key,
    required this.habit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesState = ref.watch(habitEntriesViewModelProvider(habit.id));
    final todayValue = _getTodayValue(entriesState);

    return Card(
      child: InkWell(
        onTap: () => context.push(AppRoutes.editHabitPath(habit.id)),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header row: emoji, name/progress, +1 button
              Row(
                children: [
                  HabitEmoji(
                    emoji: habit.emoji,
                    color: habit.color,
                  ),
                  const SizedBox(width: AppDimensions.marginMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          habit.name,
                          style: AppTextStyles.titleLarge,
                        ),
                        const SizedBox(height: AppDimensions.marginXs),
                        HabitProgressIndicator(
                          currentValue: todayValue,
                          dailyGoal: habit.dailyGoal,
                          unit: habit.unit,
                        ),
                      ],
                    ),
                  ),
                  QuickLogButton(
                    onTap: () => _incrementToday(ref),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.paddingMd),
              // Week heatmap
              WeekHeatmap(
                habitId: habit.id,
                dailyGoal: habit.dailyGoal,
                onCellTap: (date, currentValue) => _showEntryEditor(
                  context,
                  date,
                  currentValue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _getTodayValue(HabitEntriesState state) {
    if (state is HabitEntriesLoaded) {
      return state.getValueForDate(DateTime.now());
    }
    return 0;
  }

  void _incrementToday(WidgetRef ref) {
    ref.read(habitEntriesViewModelProvider(habit.id).notifier).incrementToday();
  }

  void _showEntryEditor(
    BuildContext context,
    DateTime date,
    double currentValue,
  ) {
    showEntryEditorBottomSheet(
      context: context,
      habitId: habit.id,
      habitName: habit.name,
      unit: habit.unit,
      date: date,
      currentValue: currentValue,
    );
  }
}
