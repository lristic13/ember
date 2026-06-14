import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../domain/entities/habit.dart';
import '../../viewmodels/habits_viewmodel.dart';
import 'habit_form.dart';

/// Shows the bottom sheet for creating a new habit.
void showCreateHabitSheet(BuildContext context, WidgetRef ref) {
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
                      AppStrings.createActivity,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(sheetContext),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.paddingMd),
                HabitForm(
                  onSubmit: (name, trackingType, unit, emoji, gradientId) async {
                    final habit = Habit(
                      id: const Uuid().v4(),
                      name: name,
                      trackingType: trackingType,
                      unit: unit,
                      emoji: emoji,
                      gradientId: gradientId,
                      createdAt: DateTime.now(),
                    );

                    final success = await ref
                        .read(habitsViewModelProvider.notifier)
                        .createHabit(habit);

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
