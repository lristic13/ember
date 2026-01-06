import '../../domain/entities/habit.dart';

sealed class HabitsState {
  const HabitsState();
}

final class HabitsInitial extends HabitsState {
  const HabitsInitial();
}

final class HabitsLoading extends HabitsState {
  const HabitsLoading();
}

final class HabitsLoaded extends HabitsState {
  final List<Habit> habits;

  const HabitsLoaded(this.habits);
}

final class HabitsError extends HabitsState {
  final String message;

  const HabitsError(this.message);
}
