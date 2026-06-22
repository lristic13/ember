import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/router/app_router.dart';
import '../../../../../core/theme/ember_tokens.dart';
import '../../../../auth/presentation/viewmodels/auth_providers.dart';
import '../../../domain/entities/habit.dart';
import '../../viewmodels/habit_entries_state.dart';
import '../../viewmodels/habit_entries_viewmodel.dart';
import '../../viewmodels/shared_habit_providers.dart';
import '../entry/entry_editor_bottom_sheet.dart';
import 'habit_card_content.dart';

class HabitCard extends ConsumerWidget {
  final Habit habit;

  const HabitCard({super.key, required this.habit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = EmberPalette.of(context);

    // "Everyone" habits track each person's own contribution: the button
    // reflects *your* log today, and a pill shows how many of you have logged.
    double todayValue;
    ({int checked, int total})? togetherProgress;
    Map<DateTime, Map<String, double>> checks = const {};
    String? myUid;

    if (habit.isTogether) {
      checks =
          ref.watch(sharedHabitChecksProvider(habit.id)).asData?.value ??
          const <DateTime, Map<String, double>>{};
      myUid = ref.watch(currentUserProvider)?.uid;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final todayAmounts = checks[today] ?? const <String, double>{};
      todayValue = myUid != null ? (todayAmounts[myUid] ?? 0.0) : 0.0;
      togetherProgress = (
        checked: todayAmounts.length,
        total: habit.participants.length,
      );
    } else {
      todayValue = _getTodayValue(
        ref.watch(habitEntriesViewModelProvider(habit.id)),
      );
    }

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
          togetherProgress: togetherProgress,
          onTap: () => context.push(AppRoutes.habitDetailsPath(habit.id)),
          onQuickLog: () => _quickLog(context, ref, todayValue),
          onCellTap: (date, currentValue) {
            // For Everyone, edit *my own* amount for that day, not the group's.
            if (habit.isTogether) {
              final d = DateTime(date.year, date.month, date.day);
              final mine = myUid != null ? (checks[d]?[myUid] ?? 0.0) : 0.0;
              _showEntryEditor(context, date, mine);
            } else {
              _showEntryEditor(context, date, currentValue);
            }
          },
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
    if (habit.isTogether) {
      if (habit.isCompletion) {
        // Toggle my own check-in (the day completes only when everyone has).
        ref
            .read(habitEntriesViewModelProvider(habit.id).notifier)
            .logEntry(DateTime.now(), todayValue > 0 ? 0 : 1)
            .then((ok) {
              if (!ok && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Couldn't update — please try again."),
                  ),
                );
              }
            });
      } else {
        _showEntryEditor(context, DateTime.now(), todayValue);
      }
      return;
    }

    if (habit.isCompletion) {
      ref
          .read(habitEntriesViewModelProvider(habit.id).notifier)
          .toggleTodayCompletion();
    } else {
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
