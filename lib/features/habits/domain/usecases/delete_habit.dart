import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../repositories/habit_repository.dart';

/// Use case for deleting a habit.
class DeleteHabit {
  final HabitRepository _repository;

  const DeleteHabit(this._repository);

  Future<Result<void, Failure>> call(String id) {
    return _repository.deleteHabit(id);
  }
}
