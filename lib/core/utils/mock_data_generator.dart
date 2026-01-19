import 'dart:math';

import '../../features/habits/domain/entities/habit.dart';
import '../../features/habits/domain/repositories/habit_repository.dart';

class MockDataGenerator {
  final HabitRepository _repository;
  final Random _random = Random();

  MockDataGenerator(this._repository);

  /// Generates realistic mock data for all activities from Jan 1, 2025 to today.
  /// Creates natural-looking streaks and gaps.
  Future<void> generate() async {
    final habitsResult = await _repository.getHabits();

    final habits = habitsResult.fold(
      (_) => <Habit>[],
      (habits) => habits,
    );

    if (habits.isEmpty) {
      throw Exception('No activities found. Create some activities first.');
    }

    final startDate = DateTime(2025, 1, 1);
    final endDate = DateTime.now();

    for (final habit in habits) {
      await _generateEntriesForHabit(
        habit: habit,
        startDate: startDate,
        endDate: endDate,
      );
    }
  }

  Future<void> _generateEntriesForHabit({
    required Habit habit,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // Base probability of showing up (varies per activity for variety)
    double baseShowUpRate = 0.5 + (_random.nextDouble() * 0.35); // 0.5 to 0.85
    double showUpProbability = baseShowUpRate;

    for (var date = startDate;
        date.isBefore(endDate) || date.isAtSameMomentAs(endDate);
        date = date.add(const Duration(days: 1))) {
      final showedUp = _random.nextDouble() < showUpProbability;

      if (showedUp) {
        // Streak continues - slightly increase probability
        showUpProbability = (showUpProbability + 0.05).clamp(0.0, 0.95);

        await _repository.logEntry(
          habitId: habit.id,
          date: DateTime(date.year, date.month, date.day),
          value: _generateValue(habit),
        );
      } else {
        // Missed day - decrease probability (simulates falling off)
        showUpProbability = (showUpProbability - 0.1).clamp(0.3, 0.95);
      }

      // Occasionally reset to base rate (simulates "fresh start" moments)
      if (_random.nextDouble() < 0.02) {
        showUpProbability = baseShowUpRate;
      }
    }
  }

  double _generateValue(Habit habit) {
    if (habit.isCompletion) {
      return 1.0;
    }

    // For quantity, generate varied but realistic values
    // Creates natural variation where some days are better than others
    final baseValue = 5 + _random.nextInt(6); // 5-10
    final variance = _random.nextDouble() * 4 - 2; // -2 to +2
    return (baseValue + variance).clamp(1.0, 15.0);
  }

  /// Clears all entries (useful for regenerating)
  Future<void> clearAllEntries() async {
    await _repository.deleteAllEntries();
  }
}
