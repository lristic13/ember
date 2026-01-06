import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../viewmodels/habits_state.dart';
import '../viewmodels/habits_viewmodel.dart';
import '../widgets/habits_empty_state.dart';
import '../widgets/habits_error_state.dart';
import '../widgets/habits_list.dart';
import '../widgets/habits_loading_state.dart';

class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(habitsViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
      ),
      body: switch (state) {
        HabitsInitial() => const HabitsLoadingState(),
        HabitsLoading() => const HabitsLoadingState(),
        HabitsError(:final message) => HabitsErrorState(
            message: message,
            onRetry: () => ref.read(habitsViewModelProvider.notifier).refresh(),
          ),
        HabitsLoaded(:final habits) => habits.isEmpty
            ? const HabitsEmptyState()
            : HabitsList(habits: habits),
      },
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.createHabit),
        backgroundColor: AppColors.accent,
        child: const Icon(
          Icons.add,
          size: AppDimensions.fabIconSize,
        ),
      ),
    );
  }
}
