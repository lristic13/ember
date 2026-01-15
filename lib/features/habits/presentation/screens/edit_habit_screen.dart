import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../viewmodels/habits_viewmodel.dart';
import '../widgets/habit_form.dart';
import '../widgets/delete_confirmation_bottom_sheet.dart';
import '../widgets/habit_options_bottom_sheet.dart';

class EditHabitScreen extends ConsumerWidget {
  final String habitId;

  const EditHabitScreen({super.key, required this.habitId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitAsync = ref.watch(habitByIdProvider(habitId));

    final topPadding = MediaQuery.of(context).padding.top + kToolbarHeight;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: AppBar(
              backgroundColor: AppColors.background.withValues(alpha: 0.7),
              title: const Text(
                AppStrings.editActivity,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => context.pop(),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () => _showOptionsSheet(context, ref),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            top: topPadding + AppDimensions.paddingMd,
            left: AppDimensions.paddingMd,
            right: AppDimensions.paddingMd,
            bottom: AppDimensions.paddingMd,
          ),
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

  Future<void> _showOptionsSheet(BuildContext context, WidgetRef ref) async {
    final result = await HabitOptionsBottomSheet.show(context);

    if (result == HabitOptionResult.delete && context.mounted) {
      final confirmed = await DeleteConfirmationBottomSheet.show(context);

      if (confirmed == true && context.mounted) {
        final success = await ref
            .read(habitsViewModelProvider.notifier)
            .deleteHabit(habitId);

        if (success && context.mounted) {
          context.go(AppRoutes.home);
        }
      }
    }
  }
}
