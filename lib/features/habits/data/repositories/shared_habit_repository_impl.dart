import 'package:cloud_functions/cloud_functions.dart' show FirebaseFunctionsException;

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/tracking_type.dart';
import '../../domain/repositories/shared_habit_repository.dart';
import '../datasources/shared_habit_remote_datasource.dart';

class SharedHabitRepositoryImpl implements SharedHabitRepository {
  SharedHabitRepositoryImpl(this._datasource);

  final SharedHabitRemoteDatasource _datasource;

  @override
  Stream<List<Habit>> watchSharedHabits(String uid) =>
      _datasource.watchSharedHabits(uid);

  @override
  Stream<Map<DateTime, double>> watchSharedEntries(String habitId) =>
      _datasource.watchEntries(habitId);

  @override
  Future<Result<void, Failure>> logEntry({
    required String habitId,
    required DateTime date,
    required double value,
    required String loggedBy,
  }) async {
    try {
      await _datasource.logEntry(
        habitId: habitId,
        date: date,
        value: value,
        loggedBy: loggedBy,
      );
      return const Success(null);
    } catch (e) {
      return Err(NetworkFailure('Failed to log: $e'));
    }
  }

  @override
  Future<Result<void, Failure>> promoteToShared({
    required Habit habit,
    required Map<DateTime, double> entries,
    required String ownerUid,
    String? ownerHandle,
    String? ownerDisplayName,
  }) async {
    try {
      await _datasource.createSharedHabit(
        habit: habit,
        entries: entries,
        ownerUid: ownerUid,
        ownerHandle: ownerHandle,
        ownerDisplayName: ownerDisplayName,
      );
      return const Success(null);
    } catch (e) {
      return Err(NetworkFailure('Failed to share habit: $e'));
    }
  }

  @override
  Future<Result<void, Failure>> leaveHabit(String habitId) =>
      _call(() => _datasource.leaveHabit(habitId));

  @override
  Future<Result<void, Failure>> removeParticipant({
    required String habitId,
    required String uid,
  }) => _call(() => _datasource.removeParticipant(habitId: habitId, uid: uid));

  @override
  Future<Result<void, Failure>> deleteSharedHabit(String habitId) =>
      _call(() => _datasource.deleteSharedHabit(habitId));

  @override
  Future<Result<void, Failure>> updateSharedHabit({
    required String habitId,
    required TrackingType trackingType,
    required String name,
    String? unit,
    String? emoji,
    required String gradientId,
  }) => _call(
    () => _datasource.updateSharedHabit(
      habitId: habitId,
      name: name,
      trackingType: trackingType.name,
      unit: unit,
      emoji: emoji,
      gradientId: gradientId,
    ),
  );

  /// Runs a callable-backed action and maps any error to a [Failure],
  /// preferring the function's own message.
  Future<Result<void, Failure>> _call(Future<void> Function() action) async {
    try {
      await action();
      return const Success(null);
    } catch (e) {
      if (e is FirebaseFunctionsException) {
        final msg = (e.message != null && e.message!.isNotEmpty)
            ? e.message!
            : 'Something went wrong.';
        return Err(NetworkFailure(msg));
      }
      return Err(NetworkFailure('Something went wrong: $e'));
    }
  }
}
