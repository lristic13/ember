import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/entities/habit.dart';
import '../screens/habit_details_screen.dart';
import '../viewmodels/habit_entries_state.dart';
import '../viewmodels/habit_entries_viewmodel.dart';
import 'entry_editor_bottom_sheet.dart';
import 'habit_emoji.dart';
import 'habit_progress_indicator.dart';
import 'quick_log_button.dart';
import 'week_heatmap.dart';

class HabitCard extends ConsumerWidget {
  final Habit habit;

  const HabitCard({super.key, required this.habit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesState = ref.watch(habitEntriesViewModelProvider(habit.id));
    final todayValue = _getTodayValue(entriesState);

    final theme = Theme.of(context);
    return OpenContainer(
      transitionType: ContainerTransitionType.fadeThrough,
      transitionDuration: const Duration(milliseconds: 400),
      openBuilder: (context, _) => HabitDetailsScreen(habitId: habit.id),
      closedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      closedColor: theme.scaffoldBackgroundColor,
      openColor: theme.scaffoldBackgroundColor,
      middleColor: theme.scaffoldBackgroundColor,
      closedElevation: 1,
      openElevation: 0,
      closedBuilder: (context, openContainer) => _HabitCardContent(
        habit: habit,
        todayValue: todayValue,
        onTap: openContainer,
        onQuickLog: () => _quickLog(context, ref, todayValue),
        onCellTap: (date, currentValue) =>
            _showEntryEditor(context, date, currentValue),
      ),
    );
  }

  double _getTodayValue(HabitEntriesState state) {
    if (state is HabitEntriesLoaded) {
      return state.getValueForDate(DateTime.now());
    }
    return 0;
  }

  void _quickLog(BuildContext context, WidgetRef ref, double todayValue) {
    if (habit.isCompletion) {
      // For completion type: toggle on/off
      ref
          .read(habitEntriesViewModelProvider(habit.id).notifier)
          .toggleTodayCompletion();
    } else {
      // For quantity type: open entry editor to input exact value
      _showEntryEditor(context, DateTime.now(), todayValue);
    }
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
      trackingType: habit.trackingType,
      unit: habit.unit,
      date: date,
      currentValue: currentValue,
    );
  }
}

class _HabitCardContent extends ConsumerWidget {
  final Habit habit;
  final double todayValue;
  final VoidCallback onTap;
  final VoidCallback onQuickLog;
  final void Function(DateTime date, double currentValue) onCellTap;

  const _HabitCardContent({
    required this.habit,
    required this.todayValue,
    required this.onTap,
    required this.onQuickLog,
    required this.onCellTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: onTap,
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
                  color: habit.gradient.primaryColor,
                ),
                const SizedBox(width: AppDimensions.marginMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.name,
                        style: AppTextStyles.titleLarge.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.marginXs),
                      HabitProgressIndicator(
                        currentValue: todayValue,
                        trackingType: habit.trackingType,
                        unit: habit.unit,
                        color: habit.gradient.primaryColor,
                      ),
                    ],
                  ),
                ),
                QuickLogButton(
                  onTap: onQuickLog,
                  color: habit.gradient.primaryColor,
                  icon: habit.isCompletion ? Icons.check : Icons.add,
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingMd),
            // Week heatmap
            WeekHeatmap(
              habitId: habit.id,
              gradient: habit.gradient,
              onCellTap: onCellTap,
            ),
          ],
        ),
      ),
    );
  }
}
