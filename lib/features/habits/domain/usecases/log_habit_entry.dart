import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/habit_entry.dart';
import '../repositories/habit_repository.dart';

/// Use case for logging a habit entry.
class LogHabitEntry {
  final HabitRepository _repository;

  const LogHabitEntry(this._repository);

  Future<Result<HabitEntry, Failure>> call({
    required String habitId,
    required DateTime date,
    required double value,
  }) {
    return _repository.logEntry(
      habitId: habitId,
      date: date,
      value: value,
    );
  }
}
