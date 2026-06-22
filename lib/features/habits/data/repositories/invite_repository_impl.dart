import 'package:cloud_functions/cloud_functions.dart' show FirebaseFunctionsException;

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/invite.dart';
import '../../domain/repositories/invite_repository.dart';
import '../datasources/invite_remote_datasource.dart';

class InviteRepositoryImpl implements InviteRepository {
  InviteRepositoryImpl(this._datasource);

  final InviteRemoteDatasource _datasource;

  @override
  Stream<List<Invite>> watchPendingInvites(String uid) =>
      _datasource.watchPendingInvites(uid);

  @override
  Stream<List<Invite>> watchHabitInvites(String habitId, String fromUid) =>
      _datasource.watchHabitInvites(habitId, fromUid);

  @override
  Future<Result<String?, Failure>> resolveHandle(String handleLower) async {
    try {
      return Success(await _datasource.lookupHandle(handleLower));
    } catch (e) {
      return Err(NetworkFailure('Lookup failed: $e'));
    }
  }

  @override
  Future<Result<void, Failure>> sendInvite({
    required String habitId,
    required String toHandle,
  }) async {
    try {
      await _datasource.sendInvite(habitId: habitId, toHandle: toHandle);
      return const Success(null);
    } catch (e) {
      return Err(_mapError(e));
    }
  }

  @override
  Future<Result<void, Failure>> respondToInvite({
    required String inviteId,
    required bool accept,
  }) async {
    try {
      await _datasource.respondToInvite(inviteId: inviteId, accept: accept);
      return const Success(null);
    } catch (e) {
      return Err(_mapError(e));
    }
  }

  @override
  Future<Result<void, Failure>> cancelInvite(String inviteId) async {
    try {
      await _datasource.cancelInvite(inviteId);
      return const Success(null);
    } catch (e) {
      return Err(_mapError(e));
    }
  }

  /// Maps a callable error to a [Failure], preferring the function's own
  /// human-readable message (e.g. "They're already in this habit.").
  Failure _mapError(Object e) {
    if (e is FirebaseFunctionsException) {
      final msg = (e.message != null && e.message!.isNotEmpty)
          ? e.message!
          : 'Something went wrong.';
      switch (e.code) {
        case 'not-found':
          return NotFoundFailure(msg);
        case 'unauthenticated':
          return AuthFailure(msg);
        case 'already-exists':
        case 'failed-precondition':
        case 'permission-denied':
        case 'invalid-argument':
          return ValidationFailure(msg);
        default:
          return NetworkFailure(msg);
      }
    }
    return NetworkFailure('Something went wrong: $e');
  }
}
