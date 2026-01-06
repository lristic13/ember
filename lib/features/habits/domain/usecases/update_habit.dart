import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/habit.dart';
import '../repositories/habit_repository.dart';

/// Use case for updating an existing habit.
class UpdateHabit {
  final HabitRepository _repository;

  const UpdateHabit(this._repository);

  Future<Result<Habit, Failure>> call(Habit habit) {
    return _repository.updateHabit(habit);
  }
}
