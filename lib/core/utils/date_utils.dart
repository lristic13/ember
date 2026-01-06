/// Utility functions for date calculations.
abstract class DateUtils {
  /// Returns the start of the current week (Monday at 00:00:00).
  static DateTime getWeekStart(DateTime date) {
    final daysFromMonday = (date.weekday - DateTime.monday) % 7;
    return DateTime(date.year, date.month, date.day - daysFromMonday);
  }

  /// Returns the end of the current week (Sunday at 23:59:59).
  static DateTime getWeekEnd(DateTime date) {
    final weekStart = getWeekStart(date);
    return DateTime(
      weekStart.year,
      weekStart.month,
      weekStart.day + 6,
      23,
      59,
      59,
    );
  }

  /// Returns a list of all dates in the week containing [date].
  /// List starts with Monday and ends with Sunday.
  static List<DateTime> getWeekDates(DateTime date) {
    final weekStart = getWeekStart(date);
    return List.generate(
      7,
      (index) => DateTime(
        weekStart.year,
        weekStart.month,
        weekStart.day + index,
      ),
    );
  }

  /// Returns the date portion only (no time component).
  static DateTime dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Checks if two dates are the same day.
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Checks if the given date is today.
  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now());
  }
}
