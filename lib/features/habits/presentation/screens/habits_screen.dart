import 'package:ember/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../viewmodels/habits_state.dart';
import '../viewmodels/habits_viewmodel.dart';
import '../viewmodels/view_mode_provider.dart';
import '../widgets/habits_empty_state.dart';
import '../widgets/habits_error_state.dart';
import '../widgets/habits_grid.dart';
import '../widgets/habits_list.dart';
import '../widgets/habits_loading_state.dart';

class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(habitsViewModelProvider);
    final viewMode = ref.watch(habitsViewModeNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.appName, style: AppTextStyles.headlineLarge),
        actions: [
          IconButton(
            icon: Icon(
              viewMode == HabitsViewMode.week
                  ? Icons.calendar_month
                  : Icons.view_agenda,
            ),
            tooltip: viewMode == HabitsViewMode.week
                ? AppStrings.monthView
                : AppStrings.weekView,
            onPressed: () {
              ref.read(habitsViewModeNotifierProvider.notifier).toggle();
            },
          ),
        ],
      ),
      body: switch (state) {
        HabitsInitial() => const HabitsLoadingState(),
        HabitsLoading() => const HabitsLoadingState(),
        HabitsError(:final message) => HabitsErrorState(
          message: message,
          onRetry: () => ref.read(habitsViewModelProvider.notifier).refresh(),
        ),
        HabitsLoaded(:final habits) =>
          habits.isEmpty
              ? const HabitsEmptyState()
              : viewMode == HabitsViewMode.week
              ? HabitsList(habits: habits)
              : HabitsGrid(habits: habits),
      },
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMd),
          child: SizedBox(
            width: double.infinity,
            height: AppDimensions.buttonHeightLg,
            child: FilledButton(
              onPressed: () => context.push(AppRoutes.createHabit),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accent,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: AppColors.accent),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
              ),
              child: const Text(
                AppStrings.addHabit,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
