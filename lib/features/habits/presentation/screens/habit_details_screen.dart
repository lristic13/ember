import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../share/presentation/providers/share_providers.dart';
import '../../../share/presentation/widgets/share_preview_dialog.dart';
import '../../domain/entities/habit.dart';
import '../viewmodels/habits_viewmodel.dart';
import '../widgets/entry/delete_confirmation_bottom_sheet.dart';
import '../widgets/habit_details/habit_details_content.dart';
import '../widgets/habit_form/habit_form.dart';

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
              backgroundColor: theme.scaffoldBackgroundColor.withValues(
                alpha: 0.7,
              ),
              title: const SizedBox.shrink(),
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
                habitAsync.maybeWhen(
                  data: (habit) {
                    if (habit == null) return const SizedBox.shrink();
                    return IconButton(
                      icon: const Icon(Icons.edit),
                      tooltip: AppStrings.edit,
                      onPressed: () => _showEditHabitSheet(context, ref, habit),
                    );
                  },
                  orElse: () => const SizedBox.shrink(),
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

  Future<void> _showShareDialog(
    BuildContext context,
    WidgetRef ref,
    habit,
  ) async {
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

  void _showEditHabitSheet(BuildContext context, WidgetRef ref, Habit habit) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: GestureDetector(
          onTap: () => FocusScope.of(sheetContext).unfocus(),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.paddingMd),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppStrings.editActivity,
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.delete_outline,
                              color: theme.colorScheme.error,
                            ),
                            onPressed: () => _handleDelete(
                              context,
                              sheetContext,
                              ref,
                              habit.id,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(sheetContext),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.paddingMd),
                  HabitForm(
                    initialName: habit.name,
                    initialTrackingType: habit.trackingType,
                    initialUnit: habit.unit,
                    initialEmoji: habit.emoji,
                    initialGradientId: habit.gradientId,
                    submitButtonText: AppStrings.save,
                    onSubmit:
                        (name, trackingType, unit, emoji, gradientId) async {
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

                          if (success && sheetContext.mounted) {
                            Navigator.pop(sheetContext);
                          }
                        },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleDelete(
    BuildContext screenContext,
    BuildContext sheetContext,
    WidgetRef ref,
    String habitId,
  ) async {
    final confirmed = await DeleteConfirmationBottomSheet.show(sheetContext);

    if (confirmed == true) {
      await ref.read(habitsViewModelProvider.notifier).deleteHabit(habitId);

      if (screenContext.mounted) {
        // Pop edit sheet and details screen, go to home
        Navigator.of(screenContext).popUntil((route) => route.isFirst);
      }
    }
  }
}
