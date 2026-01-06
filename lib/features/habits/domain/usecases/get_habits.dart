import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/habit.dart';
import '../repositories/habit_repository.dart';

/// Use case for getting all habits.
class GetHabits {
  final HabitRepository _repository;

  const GetHabits(this._repository);

  Future<Result<List<Habit>, Failure>> call({
    bool includeArchived = false,
  }) {
    return _repository.getHabits(includeArchived: includeArchived);
  }
}
