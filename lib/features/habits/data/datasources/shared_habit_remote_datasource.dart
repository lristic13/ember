import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../../../core/constants/firebase_constants.dart';
import '../../domain/entities/habit.dart';
import '../models/shared_habit_model.dart';

/// Reads shared habits + their entries from Firestore, and calls the
/// membership Cloud Functions. Firestore/Functions types stay in the data layer.
class SharedHabitRemoteDatasource {
  SharedHabitRemoteDatasource({
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
  }) : _db = firestore ?? FirebaseFirestore.instance,
       _functions =
           functions ??
           FirebaseFunctions.instanceFor(region: kCloudFunctionsRegion);

  final FirebaseFirestore _db;
  final FirebaseFunctions _functions;

  /// Streams the shared habits the given user participates in.
  Stream<List<Habit>> watchSharedHabits(String uid) {
    return _db
        .collection('habits')
        .where('participantIds', arrayContains: uid)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => sharedHabitFromDoc(d.id, d.data())).toList(),
        );
  }

  /// Logs an entry on an "Anyone" shared habit (one doc per `yyyy-MM-dd`,
  /// last-write-wins). Goes through the `logSharedEntry` function so the entries
  /// subcollection can deny direct participant writes (the function stamps
  /// `loggedBy` from auth); [loggedBy] is therefore ignored.
  Future<void> logEntry({
    required String habitId,
    required DateTime date,
    required double value,
    required String loggedBy,
  }) async {
    await _functions.httpsCallable('logSharedEntry').call(<String, dynamic>{
      'habitId': habitId,
      'date': _docId(date),
      'value': value,
    });
  }

  /// Creates a shared `habits/{habit.id}` doc owned by [ownerUid] and copies
  /// [entries] into its `entries` subcollection. Entry writes are chunked to
  /// stay under Firestore's 500-op batch limit.
  Future<void> createSharedHabit({
    required Habit habit,
    required Map<DateTime, double> entries,
    required String ownerUid,
    String? ownerHandle,
    String? ownerDisplayName,
  }) async {
    final habitRef = _db.collection('habits').doc(habit.id);
    await habitRef.set({
      'name': habit.name,
      'emoji': habit.emoji,
      'trackingType': habit.trackingType.name,
      'unit': habit.unit,
      'gradientId': habit.gradientId,
      'completionMode': habit.completionMode.name,
      'ownerId': ownerUid,
      'participantIds': [ownerUid],
      'participants': {
        ownerUid: {
          'role': 'owner',
          'handle': ownerHandle,
          'displayName': ownerDisplayName,
        },
      },
      'createdAt': Timestamp.fromDate(habit.createdAt),
    });

    final items = entries.entries.toList();
    for (var i = 0; i < items.length; i += 400) {
      final batch = _db.batch();
      for (final entry in items.skip(i).take(400)) {
        batch.set(habitRef.collection('entries').doc(_docId(entry.key)), {
          'value': entry.value,
          'loggedBy': ownerUid,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
    }
  }

  Future<void> leaveHabit(String habitId) async {
    await _functions.httpsCallable('leaveHabit').call(<String, dynamic>{
      'habitId': habitId,
    });
  }

  Future<void> removeParticipant({
    required String habitId,
    required String uid,
  }) async {
    await _functions.httpsCallable('removeParticipant').call(<String, dynamic>{
      'habitId': habitId,
      'uid': uid,
    });
  }

  Future<void> deleteSharedHabit(String habitId) async {
    await _functions.httpsCallable('deleteSharedHabit').call(<String, dynamic>{
      'habitId': habitId,
    });
  }

  Future<void> updateSharedHabit({
    required String habitId,
    required String name,
    required String trackingType,
    String? unit,
    String? emoji,
    required String gradientId,
    required String completionMode,
  }) async {
    await _functions.httpsCallable('updateSharedHabit').call(<String, dynamic>{
      'habitId': habitId,
      'name': name,
      'trackingType': trackingType,
      'unit': unit,
      'emoji': emoji,
      'gradientId': gradientId,
      'completionMode': completionMode,
    });
  }

  /// Sets the caller's own contribution for [date] on an "Everyone" habit
  /// ([value] 1 for a check-in, the amount for quantity, 0 to clear).
  Future<void> setTogetherEntry({
    required String habitId,
    required DateTime date,
    required double value,
  }) async {
    await _functions.httpsCallable('setTogetherEntry').call(<String, dynamic>{
      'habitId': habitId,
      'date': _docId(date),
      'value': value,
    });
  }

  /// Streams, per date, each participant's logged amount (Everyone mode). A uid
  /// with amount > 0 has logged that day. Only dates with a `checks` map appear.
  Stream<Map<DateTime, Map<String, double>>> watchChecks(String habitId) {
    return _db
        .collection('habits')
        .doc(habitId)
        .collection('entries')
        .snapshots()
        .map((snap) {
          final map = <DateTime, Map<String, double>>{};
          for (final doc in snap.docs) {
            final date = DateTime.tryParse(doc.id);
            final raw = doc.data()['checks'];
            if (date == null || raw is! Map) continue;
            final amounts = <String, double>{};
            raw.forEach((k, v) {
              // Tolerate the legacy boolean form (`true` → 1).
              final n = v is num ? v.toDouble() : (v == true ? 1.0 : 0.0);
              if (n > 0) amounts[k as String] = n;
            });
            map[DateTime(date.year, date.month, date.day)] = amounts;
          }
          return map;
        });
  }

  String _docId(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  /// Streams a shared habit's entries as date→value (one doc per `yyyy-MM-dd`).
  Stream<Map<DateTime, double>> watchEntries(String habitId) {
    return _db
        .collection('habits')
        .doc(habitId)
        .collection('entries')
        .snapshots()
        .map((snap) {
          final map = <DateTime, double>{};
          for (final doc in snap.docs) {
            final date = DateTime.tryParse(doc.id);
            final value = (doc.data()['value'] as num?)?.toDouble();
            if (date != null && value != null) {
              map[DateTime(date.year, date.month, date.day)] = value;
            }
          }
          return map;
        });
  }
}
