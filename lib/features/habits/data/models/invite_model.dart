import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/invite.dart';

/// Maps a Firestore `invites/{id}` document into an [Invite].
Invite inviteFromDoc(String id, Map<String, dynamic> data) {
  final ts = data['createdAt'];
  return Invite(
    id: id,
    habitId: (data['habitId'] as String?) ?? '',
    habitName: (data['habitName'] as String?) ?? '',
    habitEmoji: data['habitEmoji'] as String?,
    fromUid: (data['fromUid'] as String?) ?? '',
    fromHandle: data['fromHandle'] as String?,
    fromDisplayName: data['fromDisplayName'] as String?,
    toUid: (data['toUid'] as String?) ?? '',
    toHandle: data['toHandle'] as String?,
    status: _status(data['status'] as String?),
    createdAt: ts is Timestamp ? ts.toDate() : DateTime.now(),
  );
}

InviteStatus _status(String? raw) => InviteStatus.values.firstWhere(
  (s) => s.name == raw,
  orElse: () => InviteStatus.pending,
);
