import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/ember_tokens.dart';
import '../../viewmodels/habits_viewmodel.dart';
import '../../viewmodels/search_query_provider.dart';
import '../../viewmodels/sort_mode_provider.dart';
import '../../viewmodels/view_mode_provider.dart';
import 'habit_sort_sheet.dart';
import 'habits_grid.dart';
import 'habits_list.dart';
import 'habits_search_field.dart';
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
    final visibleHabits = ref.watch(visibleHabitsProvider);
    final searching = ref.watch(habitsSearchQueryProvider).trim().isNotEmpty;
    final topInset = MediaQuery.of(context).padding.top + kToolbarHeight;

    // Dismiss the search keyboard when tapping outside the field.
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Column(
        children: [
          SizedBox(height: topInset - 20),
          HomeTodaySummary(habits: sortedHabits),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
            child: Align(
              alignment: Alignment.centerRight,
              child: SortButton(
                onTap: () => showHabitSortSheet(context, ref),
                sortMode: ref.watch(habitsSortModeProvider),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: HabitsSearchField(),
          ),
          Expanded(
            child: searching && visibleHabits.isEmpty
                ? _NoResults(palette: EmberPalette.of(context))
                : viewMode == HabitsViewMode.week
                ? HabitsList(habits: visibleHabits)
                : HabitsGrid(habits: visibleHabits),
          ),
        ],
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  final EmberPalette palette;

  const _NoResults({required this.palette});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded, size: 36, color: palette.dimmer),
          const SizedBox(height: 12),
          Text(
            'No habits match',
            style: EmberText.display(16, color: palette.dim),
          ),
        ],
      ),
    );
  }
}
