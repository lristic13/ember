sealed class HabitStatisticsState {
  const HabitStatisticsState();
}

final class HabitStatisticsInitial extends HabitStatisticsState {
  const HabitStatisticsInitial();
}

final class HabitStatisticsLoading extends HabitStatisticsState {
  const HabitStatisticsLoading();
}

final class HabitStatisticsLoaded extends HabitStatisticsState {
  final int currentStreak;
  final int longestStreak;
  final double totalLogged;
  final double dailyAverage;
  final String? bestDay;

  const HabitStatisticsLoaded({
    required this.currentStreak,
    required this.longestStreak,
    required this.totalLogged,
    required this.dailyAverage,
    this.bestDay,
  });
}

final class HabitStatisticsError extends HabitStatisticsState {
  final String message;

  const HabitStatisticsError(this.message);
}
