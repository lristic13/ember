import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/habit.dart';
import '../viewmodels/habits_viewmodel.dart';
import '../widgets/habit_form.dart';

class CreateHabitScreen extends ConsumerWidget {
  const CreateHabitScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.createHabit),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMd),
          child: HabitForm(
            onSubmit: (name, unit, emoji, gradientId) async {
              final habit = Habit(
                id: const Uuid().v4(),
                name: name,
                unit: unit,
                emoji: emoji,
                gradientId: gradientId,
                createdAt: DateTime.now(),
              );

              final success = await ref
                  .read(habitsViewModelProvider.notifier)
                  .createHabit(habit);

              if (success && context.mounted) {
                context.pop();
              }
            },
          ),
        ),
      ),
    );
  }
}
