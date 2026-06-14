import '../../../habits/domain/entities/habit_entry.dart';
import '../../../habits/domain/repositories/habit_repository.dart';

/// Provides the habit entry data used to build shareable heat map images.
///
/// Pure domain logic — image rendering (which needs a `BuildContext`) and the
/// share sheet live in the presentation layer (see `HeatMapImageGenerator` and
/// `SharePreviewSheet`), so this class never depends on Flutter.
class ShareHeatMap {
  final HabitRepository _repository;

  ShareHeatMap(this._repository);

  /// Gets entries for a specific year (for preview generation).
  Future<List<HabitEntry>> getEntriesForYear({
    required String habitId,
    required int year,
  }) async {
    final result = await _repository.getEntriesInRange(
      habitId: habitId,
      startDate: DateTime(year, 1, 1),
      endDate: DateTime(year, 12, 31),
    );

    return result.fold(
      (failure) => <HabitEntry>[],
      (entries) => entries,
    );
  }

  /// Gets entries for a specific month (for monthly preview generation).
  Future<List<HabitEntry>> getEntriesForMonth({
    required String habitId,
    required int year,
    required int month,
  }) async {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0); // Last day of month

    final result = await _repository.getEntriesInRange(
      habitId: habitId,
      startDate: startDate,
      endDate: endDate,
    );

    return result.fold(
      (failure) => <HabitEntry>[],
      (entries) => entries,
    );
  }

  /// Gets all years that have data for a habit.
  Future<List<int>> getYearsWithData(String habitId) async {
    final result = await _repository.getEntriesForHabit(habitId);

    return result.fold(
      (failure) => <int>[],
      (entries) {
        final years = entries
            .map((e) => e.date.year)
            .toSet()
            .toList()
          ..sort((a, b) => b.compareTo(a)); // Sort descending (newest first)
        return years;
      },
    );
  }
}
