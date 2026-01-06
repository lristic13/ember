import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/habit.dart';
import '../repositories/habit_repository.dart';

/// Use case for getting a single habit by ID.
class GetHabitById {
  final HabitRepository _repository;

  const GetHabitById(this._repository);

  Future<Result<Habit, Failure>> call(String id) {
    return _repository.getHabitById(id);
  }
}
