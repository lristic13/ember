import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/router/app_router.dart';
import '../../../../../core/theme/ember_tokens.dart';
import '../../../domain/entities/habit.dart';
import '../../viewmodels/habit_entries_state.dart';
import '../../viewmodels/habit_entries_viewmodel.dart';
import '../entry/entry_editor_bottom_sheet.dart';
import 'habit_card_content.dart';

class HabitCard extends ConsumerWidget {
  final Habit habit;

  const HabitCard({super.key, required this.habit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesState = ref.watch(habitEntriesViewModelProvider(habit.id));
    final todayValue = _getTodayValue(entriesState);
    final palette = EmberPalette.of(context);

    return Material(
      color: palette.card,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: palette.border),
        ),
        child: HabitCardContent(
          habit: habit,
          todayValue: todayValue,
          onTap: () => context.push(AppRoutes.habitDetailsPath(habit.id)),
          onQuickLog: () => _quickLog(context, ref, todayValue),
          onCellTap: (date, currentValue) =>
              _showEntryEditor(context, date, currentValue),
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

