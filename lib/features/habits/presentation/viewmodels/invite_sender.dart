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

/// Outcome of a batch invite: who was invited, who failed (handle → reason),
/// and an optional fatal error (auth/promotion/timeout) that stopped the batch.
typedef InviteBatchOutcome = ({
  List<String> sent,
  Map<String, String> failed,
  String? error,
});

/// Orchestrates inviting one or more people to a habit:
/// 1. resolve every `@handle` (rejecting self / unknown),
/// 2. promote a personal habit into a shared cloud habit **once** if needed,
/// 3. send an invite to each resolved handle.
///
/// keepAlive: the sheet only `read`s this, so an auto-dispose provider could be
/// torn down mid-`submit` during the promotion's async gaps.
@Riverpod(keepAlive: true)
class InviteSender extends _$InviteSender {
  @override
  void build() {}

  static const _timeout = Duration(seconds: 25);

  Future<InviteBatchOutcome> submitMany({
    required Habit habit,
    required List<String> rawHandles,
  }) async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      return (
        sent: const <String>[],
        failed: const <String, String>{},
        error: 'Sign in first.',
      );
    }

    final inviteRepo = ref.read(inviteRepositoryProvider);
    final failed = <String, String>{};
    final sent = <String>[];

    // Normalize, dedupe and format-check.
    final handles = <String>{};
    for (final raw in rawHandles) {
      final h = HandleRules.normalize(raw);
      if (h.isEmpty) continue;
      if (!HandleRules.isValid(h)) {
        failed[h] = 'Invalid handle';
      } else {
        handles.add(h);
      }
    }
    if (handles.isEmpty) {
      return (
        sent: sent,
        failed: failed,
        error: failed.isEmpty ? 'Enter at least one @handle.' : null,
      );
    }

    try {
      // Resolve each before touching data so a typo can't promote on its own.
      final valid = <String>[];
      for (final h in handles) {
        final resolved = await inviteRepo.resolveHandle(h).timeout(_timeout);
        final toUid = resolved.valueOrNull;
        if (resolved.isFailure) {
          failed[h] = 'Lookup failed';
        } else if (toUid == null) {
          failed[h] = 'User not found';
        } else if (toUid == user.uid) {
          failed[h] = "That's you";
        } else {
          valid.add(h);
        }
      }

      if (valid.isEmpty) return (sent: sent, failed: failed, error: null);

      // Promote a personal habit to the cloud once, before any send.
      if (!habit.isShared) {
        final promoted = await _promote(
          habit,
          user.uid,
          user.handle,
          user.displayName,
        );
        if (promoted.isFailure) {
          return (
            sent: sent,
            failed: failed,
            error: promoted.errorOrNull!.message,
          );
        }
      }

      for (final h in valid) {
        final result = await inviteRepo
            .sendInvite(habitId: habit.id, toHandle: h)
            .timeout(_timeout);
        result.fold((f) => failed[h] = f.message, (_) => sent.add(h));
      }

      return (sent: sent, failed: failed, error: null);
    } on TimeoutException {
      return (sent: sent, failed: failed, error: 'Timed out. Try again.');
    } catch (e) {
      return (sent: sent, failed: failed, error: 'Something went wrong.');
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
    try {
      await ref.read(habitsViewModelProvider.notifier).deleteHabit(habit.id);
    } catch (_) {}
    return const Success(null);
  }
}
