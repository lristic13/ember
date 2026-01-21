import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../widgets/presentation/providers/home_widget_providers.dart';
import '../../domain/entities/habit.dart';
import 'habits_providers.dart';
import 'habits_state.dart';

part 'habits_viewmodel.g.dart';

@riverpod
class HabitsViewModel extends _$HabitsViewModel {
  @override
  HabitsState build() {
    _loadHabits();
    return const HabitsLoading();
  }

  Future<void> _loadHabits() async {
    final getHabits = ref.read(getHabitsUseCaseProvider);
    final result = await getHabits();

    result.fold(
      (failure) => state = HabitsError(failure.message),
      (habits) => state = HabitsLoaded(habits),
    );
  }

  Future<void> refresh() async {
    state = const HabitsLoading();
    await _loadHabits();
  }

  Future<bool> createHabit(Habit habit) async {
    final createHabitUseCase = ref.read(createHabitUseCaseProvider);
    final result = await createHabitUseCase(habit);

    return result.fold(
      (failure) => false,
      (createdHabit) {
        _loadHabits();
        // Update all widgets (new activity available)
        ref.read(homeWidgetServiceProvider).updateAllWidgets();
        return true;
      },
    );
  }

  Future<bool> updateHabit(Habit habit) async {
    final updateHabitUseCase = ref.read(updateHabitUseCaseProvider);
    final result = await updateHabitUseCase(habit);

    return result.fold(
      (failure) => false,
      (updatedHabit) {
        _loadHabits();
        ref.invalidate(habitByIdProvider(habit.id));
        // Update widget for this activity
        ref.read(homeWidgetServiceProvider).updateActivityWidget(habit.id);
        return true;
      },
    );
  }

  Future<bool> deleteHabit(String id) async {
    final deleteHabitUseCase = ref.read(deleteHabitUseCaseProvider);
    final result = await deleteHabitUseCase(id);

    return result.fold(
      (failure) => false,
      (_) {
        _loadHabits();
        // Update all widgets (activity removed)
        ref.read(homeWidgetServiceProvider).updateAllWidgets();
        return true;
      },
    );
  }
}

@riverpod
Future<Habit?> habitById(Ref ref, String id) async {
  final getHabitById = ref.watch(getHabitByIdUseCaseProvider);
  final result = await getHabitById(id);
  return result.valueOrNull;
}
