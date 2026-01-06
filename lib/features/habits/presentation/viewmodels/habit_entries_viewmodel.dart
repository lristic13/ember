import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/utils/date_utils.dart';
import 'habit_entries_state.dart';
import 'habits_providers.dart';

part 'habit_entries_viewmodel.g.dart';

@riverpod
class HabitEntriesViewModel extends _$HabitEntriesViewModel {
  @override
  HabitEntriesState build(String habitId) {
    _loadEntriesForWeek();
    return const HabitEntriesLoading();
  }

  /// Loads entries for the current week (Monday–Sunday).
  Future<void> _loadEntriesForWeek() async {
    final now = DateTime.now();
    final weekStart = DateUtils.getWeekStart(now);
    final weekEnd = DateUtils.getWeekEnd(now);

    final getHabitEntries = ref.read(getHabitEntriesUseCaseProvider);
    final result = await getHabitEntries.inRange(
      habitId: habitId,
      startDate: weekStart,
      endDate: weekEnd,
    );

    result.fold(
      (failure) => state = HabitEntriesError(failure.message),
      (entries) {
        final entriesByDate = <DateTime, double>{};
        for (final entry in entries) {
          final normalizedDate = DateTime(
            entry.date.year,
            entry.date.month,
            entry.date.day,
          );
          entriesByDate[normalizedDate] = entry.value;
        }
        state = HabitEntriesLoaded(entriesByDate);
      },
    );
  }

  /// Refreshes entries for the current week.
  Future<void> refresh() async {
    state = const HabitEntriesLoading();
    await _loadEntriesForWeek();
  }

  /// Logs an entry for a specific date with the given value.
  Future<bool> logEntry(DateTime date, double value) async {
    final logHabitEntry = ref.read(logHabitEntryUseCaseProvider);
    final normalizedDate = DateTime(date.year, date.month, date.day);

    // Optimistic update
    final previousState = state;
    if (state is HabitEntriesLoaded) {
      state = (state as HabitEntriesLoaded).copyWithEntry(normalizedDate, value);
    }

    final result = await logHabitEntry(
      habitId: habitId,
      date: normalizedDate,
      value: value,
    );

    return result.fold(
      (failure) {
        // Revert on failure
        state = previousState;
        return false;
      },
      (_) => true,
    );
  }

  /// Increments today's entry by 1.
  Future<bool> incrementToday() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final currentValue = _getCurrentValueForDate(today);
    return logEntry(today, currentValue + 1);
  }

  /// Gets the current value for today.
  double getTodayValue() {
    return _getCurrentValueForDate(DateUtils.dateOnly(DateTime.now()));
  }

  double _getCurrentValueForDate(DateTime date) {
    final currentState = state;
    if (currentState is HabitEntriesLoaded) {
      return currentState.getValueForDate(date);
    }
    return 0;
  }
}
