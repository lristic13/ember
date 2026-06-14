import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/habits_state.dart';
import '../viewmodels/habits_viewmodel.dart';
import '../widgets/habits_list/add_activity_bar.dart';
import '../widgets/habit_form/create_habit_sheet.dart';
import '../widgets/habits_list/habits_app_bar.dart';
import '../widgets/habits_list/states/habits_empty_state.dart';
import '../widgets/habits_list/states/habits_error_state.dart';
import '../widgets/habits_list/habits_loaded_view.dart';
import '../widgets/habits_list/states/habits_loading_state.dart';

class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(habitsViewModelProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: const HabitsAppBar(),
      body: switch (state) {
        HabitsInitial() => const HabitsLoadingState(),
        HabitsLoading() => const HabitsLoadingState(),
        HabitsError(:final message) => HabitsErrorState(
          message: message,
          onRetry: () => ref.read(habitsViewModelProvider.notifier).refresh(),
        ),
        HabitsLoaded(:final habits) => habits.isEmpty
            ? const HabitsEmptyState()
            : const HabitsLoadedView(),
      },
      bottomNavigationBar: AddActivityBar(
        onTap: () => showCreateHabitSheet(context, ref),
      ),
    );
  }
}
