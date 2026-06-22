import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../domain/entities/completion_mode.dart';
import '../../../domain/entities/habit.dart';
import '../../../../auth/presentation/viewmodels/auth_providers.dart';
import '../../viewmodels/habits_viewmodel.dart';
import '../../viewmodels/shared_habit_creator.dart';
import '../invites/invite_sheet.dart';
import 'habit_form.dart';
import 'habit_type_sheet.dart';

/// Entry point for creating a habit: first pick the type (Personal / Everyone /
/// Anyone), then fill in the form.
Future<void> showCreateHabitSheet(BuildContext context, WidgetRef ref) async {
  final type = await showHabitTypeSheet(context);
  if (type == null || !context.mounted) return;
  _showHabitFormSheet(context, ref, type);
}

void _showHabitFormSheet(
  BuildContext context,
  WidgetRef ref,
  HabitCreateType type,
) {
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
                      completionMode: _modeFor(type),
                    );

                    if (type == HabitCreateType.personal) {
                      await _createPersonal(sheetContext, ref, habit);
                    } else {
                      await _createShared(context, sheetContext, ref, habit);
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

HabitCompletionMode _modeFor(HabitCreateType type) =>
    type == HabitCreateType.everyone
    ? HabitCompletionMode.all
    : HabitCompletionMode.any;

Future<void> _createPersonal(
  BuildContext sheetContext,
  WidgetRef ref,
  Habit habit,
) async {
  final success = await ref
      .read(habitsViewModelProvider.notifier)
      .createHabit(habit);
  if (success && sheetContext.mounted) Navigator.pop(sheetContext);
}

Future<void> _createShared(
  BuildContext context,
  BuildContext sheetContext,
  WidgetRef ref,
  Habit habit,
) async {
  final ownerUid = ref.read(currentUserProvider)?.uid;
  final result = await ref.read(sharedHabitCreatorProvider.notifier).create(habit);
  if (!sheetContext.mounted) return;

  result.fold(
    (failure) => ScaffoldMessenger.of(
      sheetContext,
    ).showSnackBar(SnackBar(content: Text(failure.message))),
    (_) async {
      Navigator.pop(sheetContext);
      // Straight to inviting someone. Mark it shared (ownerId) so the invite
      // flow doesn't try to re-promote the freshly created cloud habit.
      if (context.mounted) {
        final message = await showInviteSheet(
          context,
          habit.copyWith(ownerId: ownerUid),
        );
        if (message != null && context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        }
      }
    },
  );
}
