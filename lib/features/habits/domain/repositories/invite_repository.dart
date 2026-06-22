import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/invite.dart';

/// Access to collaboration invites. Reads stream live from Firestore; mutations
/// go through Cloud Functions.
abstract class InviteRepository {
  /// The caller's still-pending incoming invites, newest first.
  Stream<List<Invite>> watchPendingInvites(String uid);

  /// Pending invites [fromUid] sent for [habitId] (owner management view).
  Stream<List<Invite>> watchHabitInvites(String habitId, String fromUid);

  /// Resolves an `@handle` to its owner's uid, or `null` if nobody owns it.
  Future<Result<String?, Failure>> resolveHandle(String handleLower);

  /// Sends an invite to [toHandle] for the (already shared) habit [habitId].
  Future<Result<void, Failure>> sendInvite({
    required String habitId,
    required String toHandle,
  });

  /// Accepts ([accept] true) or declines an incoming invite.
  Future<Result<void, Failure>> respondToInvite({
    required String inviteId,
    required bool accept,
  });

  /// Cancels a pending invite the caller sent.
  Future<Result<void, Failure>> cancelInvite(String inviteId);
}
