import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../widgets/presentation/providers/home_widget_providers.dart';
import '../../domain/entities/habit.dart';
import 'habit_order_provider.dart';
import 'habits_providers.dart';
import 'habits_state.dart';
import 'search_query_provider.dart';
import 'shared_habit_providers.dart';
import 'sort_mode_provider.dart';

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
  // Shared habit? Resolve from the live Firestore list before falling back to
  // the local Hive repository.
  final shared = ref.watch(sharedHabitsProvider).asData?.value ?? const <Habit>[];
  for (final habit in shared) {
    if (habit.id == id) return habit;
  }

  final getHabitById = ref.watch(getHabitByIdUseCaseProvider);
  final result = await getHabitById(id);
  return result.valueOrNull;
}

/// Provider that returns habits sorted according to the current sort mode.
@riverpod
List<Habit> sortedHabits(Ref ref) {
  final state = ref.watch(habitsViewModelProvider);
  final sortMode = ref.watch(habitsSortModeProvider);
  final shared =
      ref.watch(sharedHabitsProvider).asData?.value ?? const <Habit>[];

  final local = state is HabitsLoaded ? state.habits : const <Habit>[];
  // Personal (Hive) + shared (Firestore), interleaved. The two stores hold
  // disjoint ids, so no dedup is needed.
  final habits = [...local, ...shared];
  if (habits.isEmpty) return habits;

  switch (sortMode) {
    case HabitsSortMode.name:
      habits.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    case HabitsSortMode.recentlyCreated:
      habits.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    case HabitsSortMode.custom:
      final order = ref.watch(habitsOrderProvider);
      final orderMap = {for (var i = 0; i < order.length; i++) order[i]: i};
      habits.sort((a, b) {
        final ai = orderMap[a.id] ?? habits.length;
        final bi = orderMap[b.id] ?? habits.length;
        return ai.compareTo(bi);
      });
  }

  return habits;
}

/// [sortedHabits] narrowed by the current search query (name or emoji match).
/// Drives the list/grid; the Today summary still uses the full [sortedHabits].
@riverpod
List<Habit> visibleHabits(Ref ref) {
  final habits = ref.watch(sortedHabitsProvider);
  final query = ref.watch(habitsSearchQueryProvider).trim().toLowerCase();
  if (query.isEmpty) return habits;
  return habits
      .where(
        (h) =>
            h.name.toLowerCase().contains(query) ||
            (h.emoji?.contains(query) ?? false),
      )
      .toList();
}
