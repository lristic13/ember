import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/errors/failures.dart';
import '../../../../../core/theme/ember_tokens.dart';
import '../../../../../core/utils/result.dart';
import '../../../../auth/presentation/viewmodels/auth_providers.dart';
import '../../../../auth/presentation/widgets/profile_action_button.dart';
import '../../../domain/entities/habit.dart';
import '../../../domain/entities/habit_participant.dart';
import '../../viewmodels/invite_providers.dart';
import '../../viewmodels/shared_habit_providers.dart';
import '../common/confirm_sheet.dart';
import 'member_row.dart';
import 'pending_invite_row.dart';

/// Members panel for a shared habit's details: participants, the owner's
/// outstanding invites, and the membership action (Leave for members, Delete
/// for the owner).
class SharedMembersSection extends ConsumerWidget {
  final Habit habit;

  const SharedMembersSection({super.key, required this.habit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = EmberPalette.of(context);
    final uid = ref.watch(currentUserProvider)?.uid;
    final isOwner = habit.ownerId == uid;

    final members = [...habit.participants]
      ..sort((a, b) => a.isOwner == b.isOwner ? 0 : (a.isOwner ? -1 : 1));

    final pending = isOwner
        ? (ref.watch(habitInvitesProvider(habit.id)).asData?.value ?? const [])
        : const [];

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: palette.card,
        border: Border.all(color: palette.border),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('MEMBERS', style: EmberText.mono(11, color: palette.dim)),
          const SizedBox(height: 6),
          for (final p in members)
            MemberRow(
              participant: p,
              isYou: p.uid == uid,
              canRemove: isOwner && !p.isOwner,
              onRemove: () => _removeMember(context, ref, p),
            ),
          for (final invite in pending)
            PendingInviteRow(
              invite: invite,
              onCancel: () => _cancelInvite(context, ref, invite.id),
            ),
          const SizedBox(height: 14),
          ProfileActionButton(
            icon: isOwner
                ? Icons.delete_outline_rounded
                : Icons.logout_rounded,
            label: isOwner ? 'Delete habit' : 'Leave habit',
            danger: true,
            onPressed: () => isOwner
                ? _deleteHabit(context, ref)
                : _leaveHabit(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _removeMember(
    BuildContext context,
    WidgetRef ref,
    HabitParticipant member,
  ) async {
    final who = member.handle != null ? '@${member.handle}' : 'this member';
    final confirmed = await ConfirmSheet.show(
      context,
      title: 'Remove $who?',
      message: "They'll lose access to this shared habit.",
      confirmLabel: 'Remove',
      danger: true,
    );
    if (confirmed != true) return;

    final result = await ref
        .read(sharedHabitRepositoryProvider)
        .removeParticipant(habitId: habit.id, uid: member.uid);
    if (context.mounted) _snackOnError(context, result);
  }

  Future<void> _cancelInvite(
    BuildContext context,
    WidgetRef ref,
    String inviteId,
  ) async {
    final result =
        await ref.read(inviteRepositoryProvider).cancelInvite(inviteId);
    if (context.mounted) _snackOnError(context, result);
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
    if (context.mounted) _onLeaveOrDelete(context, result);
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
    if (context.mounted) _onLeaveOrDelete(context, result);
  }

  void _onLeaveOrDelete(BuildContext context, Result<void, Failure> result) {
    if (result.isFailure) {
      _snackOnError(context, result);
      return;
    }
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _snackOnError(BuildContext context, Result<void, Failure> result) {
    final error = result.errorOrNull;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    }
  }
}
