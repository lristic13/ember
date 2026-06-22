import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/habit.dart';
import '../entities/tracking_type.dart';

/// Access to shared (cloud) habits. Implemented in the data layer (Firestore).
/// Streams update in real time.
abstract class SharedHabitRepository {
  /// The shared habits the given user participates in.
  Stream<List<Habit>> watchSharedHabits(String uid);

  /// A shared habit's entries as date→value.
  Stream<Map<DateTime, double>> watchSharedEntries(String habitId);

  /// Logs an entry on a shared habit (last-write-wins).
  Future<Result<void, Failure>> logEntry({
    required String habitId,
    required DateTime date,
    required double value,
    required String loggedBy,
  });

  /// Promotes a personal habit into a shared cloud habit owned by [ownerUid],
  /// copying its [entries] up. The Firestore doc reuses the habit's id so
  /// existing navigation/state keys keep working.
  Future<Result<void, Failure>> promoteToShared({
    required Habit habit,
    required Map<DateTime, double> entries,
    required String ownerUid,
    String? ownerHandle,
    String? ownerDisplayName,
  });

  /// Removes the current user from a shared habit they joined (not the owner).
  Future<Result<void, Failure>> leaveHabit(String habitId);

  /// Owner removes participant [uid] from a shared habit.
  Future<Result<void, Failure>> removeParticipant({
    required String habitId,
    required String uid,
  });

  /// Owner deletes a shared habit for everyone (entries + invites included).
  Future<Result<void, Failure>> deleteSharedHabit(String habitId);

  /// Owner edits a shared habit's metadata (name, emoji, gradient, unit, type).
  Future<Result<void, Failure>> updateSharedHabit({
    required String habitId,
    required String name,
    required TrackingType trackingType,
    String? unit,
    String? emoji,
    required String gradientId,
  });
}
