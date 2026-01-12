import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../viewmodels/habits_viewmodel.dart';
import '../widgets/habit_details_content.dart';

class HabitDetailsScreen extends ConsumerWidget {
  final String habitId;

  const HabitDetailsScreen({
    super.key,
    required this.habitId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitAsync = ref.watch(habitByIdProvider(habitId));

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.habitDetails),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: AppStrings.edit,
            onPressed: () => context.push(AppRoutes.editHabitPath(habitId)),
          ),
        ],
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
}
