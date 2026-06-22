import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/errors/failures.dart';
import '../../../../../core/utils/result.dart';
import '../../../../auth/presentation/viewmodels/auth_providers.dart';
import '../../../../auth/presentation/widgets/profile_action_button.dart';
import '../../../domain/entities/habit.dart';
import '../../viewmodels/shared_habit_providers.dart';
import '../common/confirm_sheet.dart';

/// The destructive membership action for a shared habit, shown at the bottom of
/// its details screen: Delete (owner — removes it for everyone) or Leave
/// (member). On success it returns to home.
class SharedHabitDangerAction extends ConsumerWidget {
  final Habit habit;

  const SharedHabitDangerAction({super.key, required this.habit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOwner = habit.ownerId == ref.watch(currentUserProvider)?.uid;

    return ProfileActionButton(
      icon: isOwner ? Icons.delete_outline_rounded : Icons.logout_rounded,
      label: isOwner ? 'Delete habit' : 'Leave habit',
      danger: true,
      onPressed: () =>
          isOwner ? _deleteHabit(context, ref) : _leaveHabit(context, ref),
    );
  }

  Future<void> _leaveHabit(BuildContext context, WidgetRef ref) async {
    final confirmed = await ConfirmSheet.show(
      context,
      title: 'Leave ${habit.name}?',
      message: "You'll stop sharing this habit. Your own history stays in it.",
      confirmLabel: 'Leave',
      danger: true,
    );
    if (confirmed != true) return;

    final result = await ref
        .read(sharedHabitRepositoryProvider)
        .leaveHabit(habit.id);
    if (context.mounted) _onDone(context, result);
  }

  Future<void> _deleteHabit(BuildContext context, WidgetRef ref) async {
    final confirmed = await ConfirmSheet.show(
      context,
      title: 'Delete ${habit.name}?',
      message: 'This deletes it for everyone, with all of its history.',
      confirmLabel: 'Delete',
      danger: true,
    );
    if (confirmed != true) return;

    final result = await ref
        .read(sharedHabitRepositoryProvider)
        .deleteSharedHabit(habit.id);
    if (context.mounted) _onDone(context, result);
  }

  void _onDone(BuildContext context, Result<void, Failure> result) {
    final error = result.errorOrNull;
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
      return;
    }
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}
