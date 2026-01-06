import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/habit.dart';
import '../repositories/habit_repository.dart';

/// Use case for creating a new habit.
class CreateHabit {
  final HabitRepository _repository;

  const CreateHabit(this._repository);

  Future<Result<Habit, Failure>> call(Habit habit) {
    return _repository.createHabit(habit);
  }
}
