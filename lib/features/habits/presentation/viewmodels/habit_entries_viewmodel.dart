import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/utils/date_utils.dart';
import '../../../auth/presentation/viewmodels/auth_providers.dart';
import '../../../widgets/presentation/providers/home_widget_providers.dart';
import 'habit_entries_state.dart';
import 'habit_statistics_viewmodel.dart';
import 'habits_providers.dart';
import 'intensity_viewmodel.dart';
import 'shared_habit_providers.dart';

part 'habit_entries_viewmodel.g.dart';

/// Provider that loads all entries for a habit and returns them as a map by date.
/// Routes to Firestore for shared habits, Hive for personal ones.
@riverpod
Future<Map<DateTime, double>> allHabitEntries(Ref ref, String habitId) async {
  final isShared = ref.watch(
    sharedHabitsProvider.select(
      (async) => async.asData?.value.any((h) => h.id == habitId) ?? false,
    ),
  );
  if (isShared) {
    return ref.watch(sharedHabitEntriesProvider(habitId).future);
  }

  final getHabitEntries = ref.read(getHabitEntriesUseCaseProvider);
  final result = await getHabitEntries(habitId);

  return result.fold(
    (failure) => <DateTime, double>{},
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
      return entriesByDate;
    },
  );
}

@riverpod
class HabitEntriesViewModel extends _$HabitEntriesViewModel {
  bool _isShared = false;

  @override
  HabitEntriesState build(String habitId) {
    _isShared = ref.watch(
      sharedHabitsProvider.select(
        (async) => async.asData?.value.any((h) => h.id == habitId) ?? false,
      ),
    );

    // Shared habits: read the week slice from the live Firestore stream.
    if (_isShared) {
      return ref
          .watch(sharedHabitEntriesProvider(habitId))
          .when(
            data: (all) => HabitEntriesLoaded(_weekSlice(all)),
            loading: () => const HabitEntriesLoading(),
            error: (error, _) => HabitEntriesError(error.toString()),
          );
    }

    _loadEntriesForWeek();
    return const HabitEntriesLoading();
  }

  Map<DateTime, double> _weekSlice(Map<DateTime, double> all) {
    final now = DateTime.now();
    final weekStart = DateUtils.getWeekStart(now);
    final weekEnd = DateUtils.getWeekEnd(now);
    final week = <DateTime, double>{};
    all.forEach((date, value) {
      if (!date.isBefore(weekStart) && !date.isAfter(weekEnd)) {
        week[date] = value;
      }
    });
    return week;
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
    final normalizedDate = DateTime(date.year, date.month, date.day);

    if (_isShared) {
      // Shared logging: write to Firestore (last-write-wins). The live stream
      // refreshes the week strip, intensity and stats reactively.
      final uid = ref.read(currentUserProvider)?.uid;
      if (uid == null) return false;
      final result = await ref
          .read(sharedHabitRepositoryProvider)
          .logEntry(
            habitId: habitId,
            date: normalizedDate,
            value: value,
            loggedBy: uid,
          );
      return result.fold((_) => false, (_) => true);
    }

    final logHabitEntry = ref.read(logHabitEntryUseCaseProvider);

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
      (_) {
        // Invalidate providers so UI updates
        ref.invalidate(habitIntensitiesProvider);
        ref.invalidate(allHabitEntriesProvider(habitId));
        ref.invalidate(habitStatisticsViewModelProvider(habitId));

        // Update home widget
        ref.read(homeWidgetServiceProvider).updateActivityWidget(habitId);

        return true;
      },
    );
  }

  /// Increments today's entry by 1 (for quantity tracking).
  Future<bool> incrementToday() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final currentValue = _getCurrentValueForDate(today);
    return logEntry(today, currentValue + 1);
  }

  /// Toggles today's completion status (for completion tracking).
  Future<bool> toggleTodayCompletion() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final currentValue = _getCurrentValueForDate(today);
    // Toggle: if already done (>0), mark as not done (0), otherwise mark as done (1)
    final newValue = currentValue > 0 ? 0.0 : 1.0;
    return logEntry(today, newValue);
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
