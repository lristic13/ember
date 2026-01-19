import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';

import '../../../../core/utils/mock_data_generator.dart';
import '../../data/datasources/habit_local_datasource.dart';
import '../../data/models/habit_model.dart';
import '../../data/models/habit_entry_model.dart';
import '../../data/repositories/habit_repository_impl.dart';
import '../../domain/repositories/habit_repository.dart';
import '../../domain/usecases/create_habit.dart';
import '../../domain/usecases/delete_habit.dart';
import '../../domain/usecases/get_habit_by_id.dart';
import '../../domain/usecases/get_habit_entries.dart';
import '../../domain/usecases/get_habits.dart';
import '../../domain/usecases/log_habit_entry.dart';
import '../../domain/usecases/update_habit.dart';

// Datasource provider
final habitLocalDatasourceProvider = Provider<HabitLocalDatasource>((ref) {
  final habitsBox = Hive.box<HabitModel>(HabitLocalDatasourceImpl.habitsBoxName);
  final entriesBox = Hive.box<HabitEntryModel>(HabitLocalDatasourceImpl.entriesBoxName);
  return HabitLocalDatasourceImpl(
    habitsBox: habitsBox,
    entriesBox: entriesBox,
  );
});

// Repository provider
final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  final datasource = ref.watch(habitLocalDatasourceProvider);
  return HabitRepositoryImpl(datasource);
});

// Use case providers
final getHabitsUseCaseProvider = Provider<GetHabits>((ref) {
  final repository = ref.watch(habitRepositoryProvider);
  return GetHabits(repository);
});

final getHabitByIdUseCaseProvider = Provider<GetHabitById>((ref) {
  final repository = ref.watch(habitRepositoryProvider);
  return GetHabitById(repository);
});

final createHabitUseCaseProvider = Provider<CreateHabit>((ref) {
  final repository = ref.watch(habitRepositoryProvider);
  return CreateHabit(repository);
});

final updateHabitUseCaseProvider = Provider<UpdateHabit>((ref) {
  final repository = ref.watch(habitRepositoryProvider);
  return UpdateHabit(repository);
});

final deleteHabitUseCaseProvider = Provider<DeleteHabit>((ref) {
  final repository = ref.watch(habitRepositoryProvider);
  return DeleteHabit(repository);
});

final getHabitEntriesUseCaseProvider = Provider<GetHabitEntries>((ref) {
  final repository = ref.watch(habitRepositoryProvider);
  return GetHabitEntries(repository);
});

final logHabitEntryUseCaseProvider = Provider<LogHabitEntry>((ref) {
  final repository = ref.watch(habitRepositoryProvider);
  return LogHabitEntry(repository);
});

// Mock data generator provider (for debug purposes)
final mockDataGeneratorProvider = Provider<MockDataGenerator>((ref) {
  final repository = ref.watch(habitRepositoryProvider);
  return MockDataGenerator(repository);
});
