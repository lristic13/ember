import '../../../habits/domain/entities/habit.dart';
import '../../../habits/domain/entities/habit_entry.dart';
import '../../../habits/domain/repositories/habit_repository.dart';
import '../entities/activity_insight.dart';
import '../entities/insights_period.dart';

class GetActivityInsights {
  final HabitRepository _repository;

  GetActivityInsights(this._repository);

  Future<List<ActivityInsight>> call({required InsightsPeriod period}) async {
    final habitsResult = await _repository.getHabits();

    return habitsResult.fold(
      (_) => [],
      (habits) => _calculateInsights(habits, period),
    );
  }

  Future<List<ActivityInsight>> _calculateInsights(
    List<Habit> habits,
    InsightsPeriod period,
  ) async {
    if (habits.isEmpty) return [];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final insights = <ActivityInsight>[];

    for (final habit in habits) {
      if (habit.isArchived) continue;

      final totalDays = period.days;
      final periodStart = today.subtract(Duration(days: totalDays - 1));

      // Get entries in period
      final entriesResult = await _repository.getEntriesInRange(
        habitId: habit.id,
        startDate: periodStart,
        endDate: today,
      );

      final entries = entriesResult.fold(
        (_) => <HabitEntry>[],
        (entries) => entries,
      );

      // Count unique days with positive entries
      final uniqueDaysLogged = entries
          .where((e) => e.value > 0)
          .map((e) => DateTime(e.date.year, e.date.month, e.date.day))
          .toSet()
          .length;

      final consistencyPercent = (uniqueDaysLogged / totalDays) * 100;

      insights.add(ActivityInsight(
        activity: habit,
        daysLogged: uniqueDaysLogged,
        totalDays: totalDays,
        consistencyPercent: consistencyPercent,
        pieSharePercent: 0, // Calculated below
      ));
    }

    // Calculate pie share (normalized)
    final totalConsistency = insights.fold<double>(
      0,
      (sum, i) => sum + i.consistencyPercent,
    );

    if (totalConsistency == 0) return insights;

    return insights.map((insight) {
      return insight.copyWith(
        pieSharePercent: (insight.consistencyPercent / totalConsistency) * 100,
      );
    }).toList()
      ..sort((a, b) => b.consistencyPercent.compareTo(a.consistencyPercent));
  }
}
