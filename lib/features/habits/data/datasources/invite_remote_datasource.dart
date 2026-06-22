import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../../../core/constants/firebase_constants.dart';
import '../../domain/entities/habit_participant.dart';
import '../../domain/entities/invite.dart';
import '../models/invite_model.dart';

/// Reads invites from Firestore and calls the `sendInvite` / `respondToInvite`
/// Cloud Functions. Firestore/Functions types stay in the data layer.
class InviteRemoteDatasource {
  InviteRemoteDatasource({
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
  }) : _db = firestore ?? FirebaseFirestore.instance,
       _functions =
           functions ??
           FirebaseFunctions.instanceFor(region: kCloudFunctionsRegion);

  final FirebaseFirestore _db;
  final FirebaseFunctions _functions;

  /// Pending incoming invites for [uid], newest first. Sorted client-side so the
  /// query stays equality-only (no composite index needed).
  Stream<List<Invite>> watchPendingInvites(String uid) {
    return _db
        .collection('invites')
        .where('toUid', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snap) {
          final invites = snap.docs
              .map((d) => inviteFromDoc(d.id, d.data()))
              .toList();
          invites.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return invites;
        });
  }

  /// The still-pending invites the caller sent for [habitId] (for the owner's
  /// management view), newest first. Filtered to `fromUid` so it stays within
  /// the invite read rules.
  Stream<List<Invite>> watchHabitInvites(String habitId, String fromUid) {
    return _db
        .collection('invites')
        .where('habitId', isEqualTo: habitId)
        .where('fromUid', isEqualTo: fromUid)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snap) {
          final invites = snap.docs
              .map((d) => inviteFromDoc(d.id, d.data()))
              .toList();
          invites.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return invites;
        });
  }

  /// Resolves an `@handle` to its owner's uid, or `null` if unclaimed.
  Future<String?> lookupHandle(String handleLower) async {
    final snap = await _db.collection('handles').doc(handleLower).get();
    return snap.exists ? snap.get('uid') as String? : null;
  }

  /// Users whose handle starts with [prefix] (case-insensitive), for invite
  /// search. Capped to a handful of results.
  Future<List<HabitParticipant>> searchUsers(String prefix) async {
    final q = prefix.trim().toLowerCase();
    if (q.isEmpty) return const [];
    final snap = await _db
        .collection('users')
        .where('handleLower', isGreaterThanOrEqualTo: q)
        .where('handleLower', isLessThan: '$q')
        .orderBy('handleLower')
        .limit(8)
        .get();
    return snap.docs.map((d) {
      final data = d.data();
      return HabitParticipant(
        uid: d.id,
        handle: data['handle'] as String?,
        displayName: data['displayName'] as String?,
      );
    }).toList();
  }

  Future<void> sendInvite({
    required String habitId,
    required String toHandle,
  }) async {
    await _functions.httpsCallable('sendInvite').call(<String, dynamic>{
      'habitId': habitId,
      'toHandle': toHandle,
    });
  }

  Future<void> respondToInvite({
    required String inviteId,
    required bool accept,
  }) async {
    await _functions.httpsCallable('respondToInvite').call(<String, dynamic>{
      'inviteId': inviteId,
      'accept': accept,
    });
  }

  Future<void> cancelInvite(String inviteId) async {
    await _functions.httpsCallable('cancelInvite').call(<String, dynamic>{
      'inviteId': inviteId,
    });
  }
}
