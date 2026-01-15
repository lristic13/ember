import 'package:hive_ce/hive.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/habit_model.dart';
import '../models/habit_entry_model.dart';

abstract class HabitLocalDatasource {
  Future<List<HabitModel>> getHabits({bool includeArchived = false});
  Future<HabitModel?> getHabitById(String id);
  Future<HabitModel> createHabit(HabitModel habit);
  Future<HabitModel> updateHabit(HabitModel habit);
  Future<void> deleteHabit(String id);
  Future<void> archiveHabit(String id);

  Future<List<HabitEntryModel>> getEntriesForHabit(String habitId);
  Future<List<HabitEntryModel>> getEntriesInRange({
    required String habitId,
    required DateTime startDate,
    required DateTime endDate,
  });
  Future<HabitEntryModel?> getEntryForDate({
    required String habitId,
    required DateTime date,
  });
  Future<HabitEntryModel> logEntry({
    required String habitId,
    required DateTime date,
    required double value,
  });
  Future<void> deleteEntry(String entryId);
  Future<void> deleteEntriesForHabit(String habitId);
}

class HabitLocalDatasourceImpl implements HabitLocalDatasource {
  static const String habitsBoxName = 'habits';
  static const String entriesBoxName = 'entries';

  final Box<HabitModel> _habitsBox;
  final Box<HabitEntryModel> _entriesBox;
  final Uuid _uuid;

  HabitLocalDatasourceImpl({
    required Box<HabitModel> habitsBox,
    required Box<HabitEntryModel> entriesBox,
    Uuid? uuid,
  })  : _habitsBox = habitsBox,
        _entriesBox = entriesBox,
        _uuid = uuid ?? const Uuid();

  @override
  Future<List<HabitModel>> getHabits({bool includeArchived = false}) async {
    try {
      var habits = _habitsBox.values.toList();
      if (!includeArchived) {
        habits = habits.where((h) => !h.isArchived).toList();
      }
      // Sort by createdAt descending (newest first)
      habits.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return habits;
    } catch (e) {
      throw DatabaseException('Failed to get habits: $e');
    }
  }

  @override
  Future<HabitModel?> getHabitById(String id) async {
    try {
      return _habitsBox.get(id);
    } catch (e) {
      throw DatabaseException('Failed to get habit: $e');
    }
  }

  @override
  Future<HabitModel> createHabit(HabitModel habit) async {
    try {
      final newHabit = HabitModel(
        id: habit.id.isEmpty ? _uuid.v4() : habit.id,
        name: habit.name,
        emoji: habit.emoji,
        trackingTypeIndex: habit.trackingTypeIndex,
        unit: habit.unit,
        gradientId: habit.gradientId,
        createdAt: habit.createdAt,
        isArchived: habit.isArchived,
      );
      await _habitsBox.put(newHabit.id, newHabit);
      return newHabit;
    } catch (e) {
      throw DatabaseException('Failed to create habit: $e');
    }
  }

  @override
  Future<HabitModel> updateHabit(HabitModel habit) async {
    try {
      await _habitsBox.put(habit.id, habit);
      return habit;
    } catch (e) {
      throw DatabaseException('Failed to update habit: $e');
    }
  }

  @override
  Future<void> deleteHabit(String id) async {
    try {
      await _habitsBox.delete(id);
      await deleteEntriesForHabit(id);
    } catch (e) {
      throw DatabaseException('Failed to delete habit: $e');
    }
  }

  @override
  Future<void> archiveHabit(String id) async {
    try {
      final habit = _habitsBox.get(id);
      if (habit != null) {
        final archivedHabit = HabitModel(
          id: habit.id,
          name: habit.name,
          emoji: habit.emoji,
          trackingTypeIndex: habit.trackingTypeIndex,
          unit: habit.unit,
          gradientId: habit.gradientId,
          createdAt: habit.createdAt,
          isArchived: true,
        );
        await _habitsBox.put(id, archivedHabit);
      }
    } catch (e) {
      throw DatabaseException('Failed to archive habit: $e');
    }
  }

  @override
  Future<List<HabitEntryModel>> getEntriesForHabit(String habitId) async {
    try {
      return _entriesBox.values
          .where((entry) => entry.habitId == habitId)
          .toList();
    } catch (e) {
      throw DatabaseException('Failed to get entries: $e');
    }
  }

  @override
  Future<List<HabitEntryModel>> getEntriesInRange({
    required String habitId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final normalizedStart = DateTime(startDate.year, startDate.month, startDate.day);
      final normalizedEnd = DateTime(endDate.year, endDate.month, endDate.day);

      return _entriesBox.values.where((entry) {
        if (entry.habitId != habitId) return false;
        final entryDate = DateTime(entry.date.year, entry.date.month, entry.date.day);
        return !entryDate.isBefore(normalizedStart) &&
            !entryDate.isAfter(normalizedEnd);
      }).toList();
    } catch (e) {
      throw DatabaseException('Failed to get entries in range: $e');
    }
  }

  @override
  Future<HabitEntryModel?> getEntryForDate({
    required String habitId,
    required DateTime date,
  }) async {
    try {
      final key = HabitEntryModel.createKey(habitId, date);
      return _entriesBox.get(key);
    } catch (e) {
      throw DatabaseException('Failed to get entry for date: $e');
    }
  }

  @override
  Future<HabitEntryModel> logEntry({
    required String habitId,
    required DateTime date,
    required double value,
  }) async {
    try {
      final normalizedDate = DateTime(date.year, date.month, date.day);
      final key = HabitEntryModel.createKey(habitId, normalizedDate);

      final existingEntry = _entriesBox.get(key);

      final entry = HabitEntryModel(
        id: existingEntry?.id ?? _uuid.v4(),
        habitId: habitId,
        date: normalizedDate,
        value: value,
      );

      await _entriesBox.put(key, entry);
      return entry;
    } catch (e) {
      throw DatabaseException('Failed to log entry: $e');
    }
  }

  @override
  Future<void> deleteEntry(String entryId) async {
    try {
      final entry = _entriesBox.values.firstWhere(
        (e) => e.id == entryId,
        orElse: () => throw const NotFoundException('Entry not found'),
      );
      await _entriesBox.delete(entry.entryKey);
    } catch (e) {
      if (e is NotFoundException) rethrow;
      throw DatabaseException('Failed to delete entry: $e');
    }
  }

  @override
  Future<void> deleteEntriesForHabit(String habitId) async {
    try {
      final keysToDelete = _entriesBox.keys.where((key) {
        final entry = _entriesBox.get(key);
        return entry?.habitId == habitId;
      }).toList();

      for (final key in keysToDelete) {
        await _entriesBox.delete(key);
      }
    } catch (e) {
      throw DatabaseException('Failed to delete entries for habit: $e');
    }
  }
}
