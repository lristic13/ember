import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/habit_entry.dart';
import '../repositories/habit_repository.dart';

/// Use case for getting habit entries within a date range.
class GetHabitEntries {
  final HabitRepository _repository;

  const GetHabitEntries(this._repository);

  /// Gets all entries for a habit.
  Future<Result<List<HabitEntry>, Failure>> call(String habitId) {
    return _repository.getEntriesForHabit(habitId);
  }

  /// Gets entries within a specific date range.
  Future<Result<List<HabitEntry>, Failure>> inRange({
    required String habitId,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return _repository.getEntriesInRange(
      habitId: habitId,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
