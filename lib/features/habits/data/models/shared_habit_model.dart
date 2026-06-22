import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_participant.dart';
import '../../domain/entities/tracking_type.dart';

/// Maps a Firestore `habits/{id}` document into a shared [Habit].
Habit sharedHabitFromDoc(String id, Map<String, dynamic> data) {
  final ownerId = data['ownerId'] as String?;

  final rawParticipants = (data['participants'] as Map?) ?? const {};
  final participants = rawParticipants.entries.map((entry) {
    final uid = entry.key as String;
    final info = (entry.value as Map?) ?? const {};
    final role = info['role'] as String?;
    return HabitParticipant(
      uid: uid,
      handle: info['handle'] as String?,
      displayName: info['displayName'] as String?,
      isOwner: role == 'owner' || uid == ownerId,
    );
  }).toList();

  final ts = data['createdAt'];

  return Habit(
    id: id,
    name: (data['name'] as String?) ?? '',
    emoji: data['emoji'] as String?,
    trackingType: _trackingType(data['trackingType'] as String?),
    unit: data['unit'] as String?,
    gradientId: (data['gradientId'] as String?) ?? 'ember',
    createdAt: ts is Timestamp ? ts.toDate() : DateTime.now(),
    ownerId: ownerId,
    participants: participants,
  );
}

TrackingType _trackingType(String? raw) => TrackingType.values.firstWhere(
  (t) => t.name == raw,
  orElse: () => TrackingType.completion,
);
