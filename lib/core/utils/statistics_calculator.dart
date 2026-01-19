import '../../features/habits/domain/entities/habit_entry.dart';
import 'date_utils.dart';

abstract class StatisticsCalculator {
  /// Calculates current streak (consecutive days with any entry > 0).
  static int calculateCurrentStreak(List<HabitEntry> entries) {
    if (entries.isEmpty) return 0;

    final entriesByDate = <DateTime, double>{};
    for (final entry in entries) {
      final date = DateUtils.dateOnly(entry.date);
      entriesByDate[date] = (entriesByDate[date] ?? 0) + entry.value;
    }

    final today = DateUtils.dateOnly(DateTime.now());
    final yesterday = DateTime(today.year, today.month, today.day - 1);

    DateTime checkDate;
    if (_hasEntry(entriesByDate, today)) {
      checkDate = today;
    } else if (_hasEntry(entriesByDate, yesterday)) {
      checkDate = yesterday;
    } else {
      return 0;
    }

    int streak = 0;
    while (_hasEntry(entriesByDate, checkDate)) {
      streak++;
      checkDate = DateTime(checkDate.year, checkDate.month, checkDate.day - 1);
    }

    return streak;
  }

  /// Calculates longest streak (consecutive days with any entry > 0).
  static int calculateLongestStreak(List<HabitEntry> entries) {
    if (entries.isEmpty) return 0;

    final entriesByDate = <DateTime, double>{};
    for (final entry in entries) {
      final date = DateUtils.dateOnly(entry.date);
      entriesByDate[date] = (entriesByDate[date] ?? 0) + entry.value;
    }

    final dates = entriesByDate.keys.toList()..sort();
    if (dates.isEmpty) return 0;

    int longestStreak = 0;
    int currentStreak = 0;
    DateTime? previousDate;

    for (final date in dates) {
      final value = entriesByDate[date] ?? 0;

      if (value > 0) {
        if (previousDate != null) {
          final daysDiff = date.difference(previousDate).inDays;
          if (daysDiff == 1) {
            currentStreak++;
          } else {
            currentStreak = 1;
          }
        } else {
          currentStreak = 1;
        }
        previousDate = date;
        longestStreak = currentStreak > longestStreak
            ? currentStreak
            : longestStreak;
      } else {
        currentStreak = 0;
        previousDate = null;
      }
    }

    return longestStreak;
  }

  static double calculateTotalLogged(List<HabitEntry> entries) {
    if (entries.isEmpty) return 0;
    return entries.fold(0.0, (sum, entry) => sum + entry.value);
  }

  static double calculateDailyAverage(List<HabitEntry> entries) {
    if (entries.isEmpty) return 0;

    final entriesByDate = <DateTime, double>{};
    for (final entry in entries) {
      final date = DateUtils.dateOnly(entry.date);
      entriesByDate[date] = (entriesByDate[date] ?? 0) + entry.value;
    }

    if (entriesByDate.isEmpty) return 0;

    final total = entriesByDate.values.fold(0.0, (sum, value) => sum + value);
    return total / entriesByDate.length;
  }

  static bool _hasEntry(Map<DateTime, double> entriesByDate, DateTime date) {
    final value = entriesByDate[date] ?? 0;
    return value > 0;
  }

  /// Calculates the best day of the week based on highest average value.
  /// Returns the weekday name (e.g., "Monday") or null if no entries.
  /// Ties go to the earliest weekday (Monday first).
  ///
  /// First groups entries by specific date (summing multiple entries per day),
  /// then calculates the average for each day of the week.
  static String? calculateBestDay(List<HabitEntry> entries) {
    if (entries.isEmpty) return null;

    // First, group entries by specific date to get daily totals
    final dailyTotals = <DateTime, double>{};
    for (final entry in entries) {
      if (entry.value <= 0) continue;
      final date = DateUtils.dateOnly(entry.date);
      dailyTotals[date] = (dailyTotals[date] ?? 0) + entry.value;
    }

    if (dailyTotals.isEmpty) return null;

    // Then aggregate by day of week
    final weekdayTotals = <int, double>{};
    final weekdayCounts = <int, int>{};

    for (final entry in dailyTotals.entries) {
      final weekday = entry.key.weekday; // 1=Monday, 7=Sunday
      weekdayTotals[weekday] = (weekdayTotals[weekday] ?? 0) + entry.value;
      weekdayCounts[weekday] = (weekdayCounts[weekday] ?? 0) + 1;
    }

    // Calculate averages and find best day
    int? bestWeekday;
    double bestAverage = 0;

    // Iterate 1-7 to ensure earliest weekday wins ties
    for (int weekday = 1; weekday <= 7; weekday++) {
      final total = weekdayTotals[weekday];
      final count = weekdayCounts[weekday];

      if (total != null && count != null && count > 0) {
        final average = total / count;
        if (average > bestAverage) {
          bestAverage = average;
          bestWeekday = weekday;
        }
      }
    }

    if (bestWeekday == null) return null;

    return _weekdayName(bestWeekday);
  }

  static String _weekdayName(int weekday) {
    const names = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return names[weekday - 1];
  }
}
