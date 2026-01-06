import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/habit.dart';
import '../entities/habit_entry.dart';

/// Abstract repository interface for habit operations.
/// This is in the domain layer and defines the contract that
/// the data layer must implement.
abstract class HabitRepository {
  /// Gets all habits (excluding archived by default).
  Future<Result<List<Habit>, Failure>> getHabits({bool includeArchived = false});

  /// Gets a single habit by its ID.
  Future<Result<Habit, Failure>> getHabitById(String id);

  /// Creates a new habit.
  Future<Result<Habit, Failure>> createHabit(Habit habit);

  /// Updates an existing habit.
  Future<Result<Habit, Failure>> updateHabit(Habit habit);

  /// Deletes a habit and all its entries.
  Future<Result<void, Failure>> deleteHabit(String id);

  /// Archives a habit (soft delete).
  Future<Result<void, Failure>> archiveHabit(String id);

  /// Gets all entries for a specific habit.
  Future<Result<List<HabitEntry>, Failure>> getEntriesForHabit(String habitId);

  /// Gets entries for a habit within a date range.
  Future<Result<List<HabitEntry>, Failure>> getEntriesInRange({
    required String habitId,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Gets or creates an entry for a specific habit and date.
  Future<Result<HabitEntry?, Failure>> getEntryForDate({
    required String habitId,
    required DateTime date,
  });

  /// Logs/updates a value for a habit on a specific date.
  Future<Result<HabitEntry, Failure>> logEntry({
    required String habitId,
    required DateTime date,
    required double value,
  });

  /// Deletes an entry.
  Future<Result<void, Failure>> deleteEntry(String entryId);
}
