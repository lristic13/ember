import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/utils/statistics_calculator.dart';
import 'habit_statistics_state.dart';
import 'habits_providers.dart';

part 'habit_statistics_viewmodel.g.dart';

@riverpod
class HabitStatisticsViewModel extends _$HabitStatisticsViewModel {
  @override
  HabitStatisticsState build(String habitId) {
    _loadStatistics();
    return const HabitStatisticsLoading();
  }

  Future<void> _loadStatistics() async {
    // Get all entries for this habit
    final getHabitEntries = ref.read(getHabitEntriesUseCaseProvider);
    final result = await getHabitEntries(habitId);

    result.fold((failure) => state = HabitStatisticsError(failure.message), (
      entries,
    ) {
      final currentStreak = StatisticsCalculator.calculateCurrentStreak(
        entries,
      );
      final longestStreak = StatisticsCalculator.calculateLongestStreak(
        entries,
      );
      final totalLogged = StatisticsCalculator.calculateTotalLogged(entries);
      final dailyAverage = StatisticsCalculator.calculateDailyAverage(entries);
      final bestDay = StatisticsCalculator.calculateBestDay(entries);

      state = HabitStatisticsLoaded(
        currentStreak: currentStreak,
        longestStreak: longestStreak,
        totalLogged: totalLogged,
        dailyAverage: dailyAverage,
        bestDay: bestDay,
      );
    });
  }

  Future<void> refresh() async {
    state = const HabitStatisticsLoading();
    await _loadStatistics();
  }
}
