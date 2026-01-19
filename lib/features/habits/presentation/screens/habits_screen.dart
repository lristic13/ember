import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:ember/core/constants/app_text_styles.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import 'create_habit_screen.dart';
import '../viewmodels/habits_providers.dart';
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

  static Future<void> _showDebugSheet(
    BuildContext context,
    WidgetRef ref,
  ) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMd),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Debug Tools',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingMd),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _generateMockData(context, ref);
                      },
                      child: const Text('Generate Mock Data'),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.paddingSm),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _clearAllData(context, ref);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                      ),
                      child: const Text('Clear All Data'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> _generateMockData(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Generate Mock Data?'),
        content: const Text(
          'This will create entries for all activities from January 2025 to today. '
          'Existing entries will be kept.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Generate'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Generating mock data...')),
        );
      }

      await ref.read(mockDataGeneratorProvider).generate();

      // Refresh the habits list
      ref.invalidate(habitsViewModelProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Mock data generated!')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  static Future<void> _clearAllData(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Clear All Entries?'),
        content: const Text(
          'This will delete ALL entries for all activities. '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete Everything'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref.read(mockDataGeneratorProvider).clearAllEntries();

      // Refresh the habits list
      ref.invalidate(habitsViewModelProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('All entries cleared.')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(habitsViewModelProvider);
    final viewMode = ref.watch(habitsViewModeNotifierProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: AppBar(
              backgroundColor: AppColors.background.withValues(alpha: 0.7),
              title: Text(
                AppStrings.appName,
                style: AppTextStyles.headlineLarge,
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.pie_chart_outline),
                  tooltip: AppStrings.insights,
                  onPressed: () => context.push(AppRoutes.insights),
                ),
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
                // if (kDebugMode)
                //   IconButton(
                //     icon: const Icon(Icons.bug_report_outlined),
                //     tooltip: 'Debug Tools',
                //     onPressed: () => _showDebugSheet(context, ref),
                //   ),
              ],
            ),
          ),
        ),
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
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            color: AppColors.background.withValues(alpha: 0.7),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingMd),
                child: SizedBox(
                  width: double.infinity,
                  height: AppDimensions.buttonHeightLg,
                  child: OpenContainer(
                    transitionType: ContainerTransitionType.fadeThrough,
                    transitionDuration: const Duration(milliseconds: 400),
                    openBuilder: (context, _) => const CreateHabitScreen(),
                    closedShape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: AppColors.textPrimary.withValues(alpha: 0.3),
                      ),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMd,
                      ),
                    ),
                    closedColor: AppColors.surface.withValues(alpha: 0.5),
                    openColor: AppColors.background,
                    middleColor: AppColors.background,
                    closedElevation: 0,
                    openElevation: 0,
                    closedBuilder: (context, openContainer) => Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusMd,
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.surface.withValues(alpha: 0.6),
                            AppColors.surface.withValues(alpha: 0.3),
                          ],
                        ),
                        border: Border.all(
                          color: AppColors.textPrimary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusMd,
                        ),
                        child: InkWell(
                          onTap: openContainer,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusMd,
                          ),
                          child: const Center(
                            child: Text(
                              AppStrings.addActivity,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
