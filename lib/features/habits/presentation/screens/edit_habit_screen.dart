import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../viewmodels/habits_viewmodel.dart';
import '../widgets/habit_form.dart';
import '../widgets/delete_habit_dialog.dart';

class EditHabitScreen extends ConsumerWidget {
  final String habitId;

  const EditHabitScreen({super.key, required this.habitId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitAsync = ref.watch(habitByIdProvider(habitId));

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.editActivity),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            color: AppColors.error,
            onPressed: () => _showDeleteDialog(context, ref),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMd),
          child: habitAsync.when(
            data: (habit) {
              if (habit == null) {
                return const Center(child: Text('Habit not found'));
              }

              return HabitForm(
                initialName: habit.name,
                initialTrackingType: habit.trackingType,
                initialUnit: habit.unit,
                initialEmoji: habit.emoji,
                initialGradientId: habit.gradientId,
                submitButtonText: AppStrings.save,
                onSubmit: (name, trackingType, unit, emoji, gradientId) async {
                  final updatedHabit = habit.copyWith(
                    name: name,
                    trackingType: trackingType,
                    unit: unit,
                    emoji: emoji,
                    gradientId: gradientId,
                  );

                  final success = await ref
                      .read(habitsViewModelProvider.notifier)
                      .updateHabit(updatedHabit);

                  if (success && context.mounted) {
                    context.pop();
                  }
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => const DeleteHabitDialog(),
    );

    if (confirmed == true && context.mounted) {
      final success = await ref
          .read(habitsViewModelProvider.notifier)
          .deleteHabit(habitId);

      if (success && context.mounted) {
        context.pop();
      }
    }
  }
}
