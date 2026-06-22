import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../../auth/domain/validators/handle_rules.dart';
import '../../../auth/presentation/viewmodels/auth_providers.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_entry.dart';
import 'habits_providers.dart';
import 'habits_viewmodel.dart';
import 'invite_providers.dart';
import 'shared_habit_providers.dart';

part 'invite_sender.g.dart';

/// Orchestrates "invite someone to this habit":
/// 1. resolve the `@handle` (and reject self / unknown) before touching data,
/// 2. promote a personal habit into a shared cloud habit if it isn't already,
/// 3. send the invite.
///
/// Promotion happens before the send because the `sendInvite` function requires
/// the habit to already exist in Firestore.
///
/// `keepAlive` is essential: the sheet only `read`s this notifier (no listener),
/// so an auto-dispose provider would be torn down mid-`submit` during the
/// promotion's async gaps, and the resumed `ref` would throw
/// `UnmountedRefException`.
@Riverpod(keepAlive: true)
class InviteSender extends _$InviteSender {
  @override
  void build() {}

  /// Network calls are wrapped in a timeout so a stalled write/callable can
  /// never leave the invite spinner hanging forever — it surfaces an error.
  static const _timeout = Duration(seconds: 25);

  Future<Result<void, Failure>> submit({
    required Habit habit,
    required String rawHandle,
  }) async {
    final handle = HandleRules.normalize(rawHandle);
    if (!HandleRules.isValid(handle)) {
      return const Err(ValidationFailure('Enter a valid @handle.'));
    }

    final user = ref.read(currentUserProvider);
    if (user == null) return const Err(AuthFailure('Sign in first.'));

    final inviteRepo = ref.read(inviteRepositoryProvider);

    try {
      // Resolve first so a typo'd handle can't promote a habit to the cloud.
      final resolved = await inviteRepo.resolveHandle(handle).timeout(_timeout);
      if (resolved.isFailure) return Err(resolved.errorOrNull!);
      final toUid = resolved.valueOrNull;
      if (toUid == null) {
        return const Err(NotFoundFailure('User not found'));
      }
      if (toUid == user.uid) {
        return const Err(ValidationFailure("You can't invite yourself."));
      }

      if (!habit.isShared) {
        final promoted = await _promote(
          habit,
          user.uid,
          user.handle,
          user.displayName,
        );
        if (promoted.isFailure) return promoted;
      }

      return await inviteRepo
          .sendInvite(habitId: habit.id, toHandle: handle)
          .timeout(_timeout);
    } on TimeoutException {
      return const Err(
        NetworkFailure('Timed out. Check your connection and try again.'),
      );
    } catch (e) {
      return Err(NetworkFailure('Something went wrong: $e'));
    }
  }

  Future<Result<void, Failure>> _promote(
    Habit habit,
    String ownerUid,
    String? ownerHandle,
    String? ownerDisplayName,
  ) async {
    final entriesRes = await ref
        .read(habitRepositoryProvider)
        .getEntriesForHabit(habit.id);
    final entries = entriesRes.valueOrNull ?? const <HabitEntry>[];
    final entriesByDate = <DateTime, double>{
      for (final e in entries)
        DateTime(e.date.year, e.date.month, e.date.day): e.value,
    };

    final result = await ref
        .read(sharedHabitRepositoryProvider)
        .promoteToShared(
          habit: habit,
          entries: entriesByDate,
          ownerUid: ownerUid,
          ownerHandle: ownerHandle,
          ownerDisplayName: ownerDisplayName,
        )
        .timeout(_timeout);
    if (result.isFailure) return result;

    // Drop the local copy so the habit doesn't appear twice (local + shared).
    // A failure here shouldn't fail the invite — the habit is already shared.
    try {
      await ref.read(habitsViewModelProvider.notifier).deleteHabit(habit.id);
    } catch (_) {}
    return const Success(null);
  }
}
