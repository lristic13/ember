import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/presentation/viewmodels/auth_providers.dart';
import '../../data/datasources/shared_habit_remote_datasource.dart';
import '../../data/repositories/shared_habit_repository_impl.dart';
import '../../domain/entities/habit.dart';
import '../../domain/repositories/shared_habit_repository.dart';

part 'shared_habit_providers.g.dart';

@Riverpod(keepAlive: true)
SharedHabitRemoteDatasource sharedHabitRemoteDatasource(Ref ref) =>
    SharedHabitRemoteDatasource();

@Riverpod(keepAlive: true)
SharedHabitRepository sharedHabitRepository(Ref ref) =>
    SharedHabitRepositoryImpl(ref.watch(sharedHabitRemoteDatasourceProvider));

/// The shared habits the current user participates in, live. Empty when signed
/// out (shouldn't happen behind the login wall, but safe).
@riverpod
Stream<List<Habit>> sharedHabits(Ref ref) {
  final uid = ref.watch(currentUserProvider)?.uid;
  if (uid == null) return Stream.value(const []);
  return ref.watch(sharedHabitRepositoryProvider).watchSharedHabits(uid);
}

/// A shared habit's entries (date→value), live.
@riverpod
Stream<Map<DateTime, double>> sharedHabitEntries(Ref ref, String habitId) {
  return ref.watch(sharedHabitRepositoryProvider).watchSharedEntries(habitId);
}

/// For an "Everyone" habit: per date, each participant's logged amount, live.
/// Drives the per-user log button + "x/y logged" progress on the card.
@riverpod
Stream<Map<DateTime, Map<String, double>>> sharedHabitChecks(
  Ref ref,
  String habitId,
) {
  return ref.watch(sharedHabitRepositoryProvider).watchChecks(habitId);
}
