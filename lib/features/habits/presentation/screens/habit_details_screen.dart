import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../../../share/presentation/providers/share_providers.dart';
import '../../../share/presentation/widgets/share_preview_dialog.dart';
import '../viewmodels/habits_viewmodel.dart';
import '../widgets/habit_details_content.dart';

class HabitDetailsScreen extends ConsumerWidget {
  final String habitId;

  const HabitDetailsScreen({super.key, required this.habitId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitAsync = ref.watch(habitByIdProvider(habitId));
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: AppBar(
              backgroundColor: theme.scaffoldBackgroundColor.withValues(alpha: 0.7),
              title: const Text(
                AppStrings.activityDetails,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              actions: [
                habitAsync.maybeWhen(
                  data: (habit) {
                    if (habit == null) return const SizedBox.shrink();
                    return IconButton(
                      icon: const Icon(Icons.share),
                      tooltip: 'Share',
                      onPressed: () => _showShareDialog(context, ref, habit),
                    );
                  },
                  orElse: () => const SizedBox.shrink(),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: AppStrings.edit,
                  onPressed: () =>
                      context.push(AppRoutes.editHabitPath(habitId)),
                ),
              ],
            ),
          ),
        ),
      ),
      body: habitAsync.when(
        data: (habit) {
          if (habit == null) {
            return const Center(child: Text('Habit not found'));
          }
          return HabitDetailsContent(habit: habit);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Future<void> _showShareDialog(BuildContext context, WidgetRef ref, habit) async {
    final shareUseCase = ref.read(shareHeatMapProvider);

    // Get years with data
    final years = await shareUseCase.getYearsWithData(habit.id);

    // Default to current year or first available year
    final currentYear = DateTime.now().year;
    final initialYear = years.contains(currentYear)
        ? currentYear
        : (years.isNotEmpty ? years.first : currentYear);

    // Ensure we have at least the current year in the list
    final availableYears = years.isNotEmpty ? years : [currentYear];

    if (context.mounted) {
      await SharePreviewDialog.show(
        context: context,
        habit: habit,
        initialYear: initialYear,
        availableYears: availableYears,
      );
    }
  }
}
