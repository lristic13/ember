import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../viewmodels/habits_viewmodel.dart';
import '../../viewmodels/sort_mode_provider.dart';
import '../../viewmodels/view_mode_provider.dart';
import 'habit_sort_sheet.dart';
import 'habits_grid.dart';
import 'habits_list.dart';
import 'home_today_summary.dart';
import 'sort_button.dart';

/// Body shown when habits have loaded: the "Today" summary, a subtle sort
/// control, and the list (week strips) or month grid.
class HabitsLoadedView extends ConsumerWidget {
  const HabitsLoadedView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewMode = ref.watch(habitsViewModeProvider);
    final sortedHabits = ref.watch(sortedHabitsProvider);
    final topInset = MediaQuery.of(context).padding.top + kToolbarHeight;

    return Column(
      children: [
        SizedBox(height: topInset - 20),
        HomeTodaySummary(habits: sortedHabits),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SortButton(
                onTap: () => showHabitSortSheet(context, ref),
                sortMode: ref.watch(habitsSortModeProvider),
              ),
            ],
          ),
        ),
        Expanded(
          child: viewMode == HabitsViewMode.week
              ? HabitsList(habits: sortedHabits)
              : HabitsGrid(habits: sortedHabits),
        ),
      ],
    );
  }
}
