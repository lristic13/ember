import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../viewmodels/habit_entries_viewmodel.dart';
import '../viewmodels/habits_viewmodel.dart';
import '../widgets/year_heatmap_content.dart';

class YearHeatmapScreen extends ConsumerWidget {
  final String habitId;

  const YearHeatmapScreen({
    super.key,
    required this.habitId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitAsync = ref.watch(habitByIdProvider(habitId));
    final entriesAsync = ref.watch(allHabitEntriesProvider(habitId));

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.yearView),
      ),
      body: habitAsync.when(
        data: (habit) {
          if (habit == null) {
            return const Center(child: Text('Habit not found'));
          }
          return entriesAsync.when(
            data: (entriesByDate) => YearHeatmapContent(
              habitId: habitId,
              unit: habit.unit,
              entriesByDate: entriesByDate,
              gradient: habit.gradient,
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Center(child: Text('Error loading data')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
