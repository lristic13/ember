import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/utils/statistics_calculator.dart';
import '../../domain/entities/habit_entry.dart';
import 'habit_statistics_state.dart';
import 'habits_providers.dart';
import 'shared_habit_providers.dart';

part 'habit_statistics_viewmodel.g.dart';

@riverpod
class HabitStatisticsViewModel extends _$HabitStatisticsViewModel {
  bool _isShared = false;

  @override
  HabitStatisticsState build(String habitId) {
    _isShared = ref.watch(
      sharedHabitsProvider.select(
        (async) => async.asData?.value.any((h) => h.id == habitId) ?? false,
      ),
    );

    // Shared habit: stats over the live Firestore history (same for everyone).
    if (_isShared) {
      return ref
          .watch(sharedHabitEntriesProvider(habitId))
          .when(
            data: (map) => _statsFor(_entriesFromMap(habitId, map)),
            loading: () => const HabitStatisticsLoading(),
            error: (error, _) => HabitStatisticsError(error.toString()),
          );
    }

    _loadStatistics();
    return const HabitStatisticsLoading();
  }

  Future<void> _loadStatistics() async {
    final getHabitEntries = ref.read(getHabitEntriesUseCaseProvider);
    final result = await getHabitEntries(habitId);
    result.fold(
      (failure) => state = HabitStatisticsError(failure.message),
      (entries) => state = _statsFor(entries),
    );
  }

  HabitStatisticsLoaded _statsFor(List<HabitEntry> entries) {
    return HabitStatisticsLoaded(
      currentStreak: StatisticsCalculator.calculateCurrentStreak(entries),
      longestStreak: StatisticsCalculator.calculateLongestStreak(entries),
      totalLogged: StatisticsCalculator.calculateTotalLogged(entries),
      dailyAverage: StatisticsCalculator.calculateDailyAverage(entries),
      bestDay: StatisticsCalculator.calculateBestDay(entries),
    );
  }

  List<HabitEntry> _entriesFromMap(String habitId, Map<DateTime, double> map) {
    return [
      for (final entry in map.entries)
        HabitEntry(
          id: '$habitId|${entry.key.toIso8601String()}',
          habitId: habitId,
          date: entry.key,
          value: entry.value,
        ),
    ];
  }

  Future<void> refresh() async {
    if (_isShared) return; // driven by the live stream
    state = const HabitStatisticsLoading();
    await _loadStatistics();
  }
}
