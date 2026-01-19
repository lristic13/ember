import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_entry.dart';
import '../../domain/repositories/habit_repository.dart';
import '../datasources/habit_local_datasource.dart';
import '../models/habit_model.dart';

class HabitRepositoryImpl implements HabitRepository {
  final HabitLocalDatasource _localDatasource;

  const HabitRepositoryImpl(this._localDatasource);

  @override
  Future<Result<List<Habit>, Failure>> getHabits({
    bool includeArchived = false,
  }) async {
    try {
      final models = await _localDatasource.getHabits(
        includeArchived: includeArchived,
      );
      final habits = models.map((m) => m.toEntity()).toList();
      return Success(habits);
    } on DatabaseException catch (e) {
      return Err(DatabaseFailure(e.message));
    } catch (e) {
      return Err(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Result<Habit, Failure>> getHabitById(String id) async {
    try {
      final model = await _localDatasource.getHabitById(id);
      if (model == null) {
        return const Err(NotFoundFailure('Habit not found'));
      }
      return Success(model.toEntity());
    } on DatabaseException catch (e) {
      return Err(DatabaseFailure(e.message));
    } catch (e) {
      return Err(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Result<Habit, Failure>> createHabit(Habit habit) async {
    try {
      final model = HabitModel.fromEntity(habit);
      final createdModel = await _localDatasource.createHabit(model);
      return Success(createdModel.toEntity());
    } on DatabaseException catch (e) {
      return Err(DatabaseFailure(e.message));
    } catch (e) {
      return Err(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Result<Habit, Failure>> updateHabit(Habit habit) async {
    try {
      final model = HabitModel.fromEntity(habit);
      final updatedModel = await _localDatasource.updateHabit(model);
      return Success(updatedModel.toEntity());
    } on DatabaseException catch (e) {
      return Err(DatabaseFailure(e.message));
    } catch (e) {
      return Err(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Result<void, Failure>> deleteHabit(String id) async {
    try {
      await _localDatasource.deleteHabit(id);
      return const Success(null);
    } on DatabaseException catch (e) {
      return Err(DatabaseFailure(e.message));
    } catch (e) {
      return Err(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Result<void, Failure>> archiveHabit(String id) async {
    try {
      await _localDatasource.archiveHabit(id);
      return const Success(null);
    } on DatabaseException catch (e) {
      return Err(DatabaseFailure(e.message));
    } catch (e) {
      return Err(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<HabitEntry>, Failure>> getEntriesForHabit(
    String habitId,
  ) async {
    try {
      final models = await _localDatasource.getEntriesForHabit(habitId);
      final entries = models.map((m) => m.toEntity()).toList();
      return Success(entries);
    } on DatabaseException catch (e) {
      return Err(DatabaseFailure(e.message));
    } catch (e) {
      return Err(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<HabitEntry>, Failure>> getEntriesInRange({
    required String habitId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final models = await _localDatasource.getEntriesInRange(
        habitId: habitId,
        startDate: startDate,
        endDate: endDate,
      );
      final entries = models.map((m) => m.toEntity()).toList();
      return Success(entries);
    } on DatabaseException catch (e) {
      return Err(DatabaseFailure(e.message));
    } catch (e) {
      return Err(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Result<HabitEntry?, Failure>> getEntryForDate({
    required String habitId,
    required DateTime date,
  }) async {
    try {
      final model = await _localDatasource.getEntryForDate(
        habitId: habitId,
        date: date,
      );
      return Success(model?.toEntity());
    } on DatabaseException catch (e) {
      return Err(DatabaseFailure(e.message));
    } catch (e) {
      return Err(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Result<HabitEntry, Failure>> logEntry({
    required String habitId,
    required DateTime date,
    required double value,
  }) async {
    try {
      final model = await _localDatasource.logEntry(
        habitId: habitId,
        date: date,
        value: value,
      );
      return Success(model.toEntity());
    } on DatabaseException catch (e) {
      return Err(DatabaseFailure(e.message));
    } catch (e) {
      return Err(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Result<void, Failure>> deleteEntry(String entryId) async {
    try {
      await _localDatasource.deleteEntry(entryId);
      return const Success(null);
    } on NotFoundException {
      return const Err(NotFoundFailure('Entry not found'));
    } on DatabaseException catch (e) {
      return Err(DatabaseFailure(e.message));
    } catch (e) {
      return Err(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Result<void, Failure>> deleteAllEntries() async {
    try {
      await _localDatasource.deleteAllEntries();
      return const Success(null);
    } on DatabaseException catch (e) {
      return Err(DatabaseFailure(e.message));
    } catch (e) {
      return Err(UnexpectedFailure(e.toString()));
    }
  }
}
