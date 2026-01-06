import 'package:hive_ce/hive.dart';

import '../../domain/entities/habit_entry.dart';

part 'habit_entry_model.g.dart';

@HiveType(typeId: 1)
class HabitEntryModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String habitId;

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  final double value;

  HabitEntryModel({
    required this.id,
    required this.habitId,
    required this.date,
    required this.value,
  });

  /// Creates a [HabitEntryModel] from a [HabitEntry] entity.
  factory HabitEntryModel.fromEntity(HabitEntry entry) {
    return HabitEntryModel(
      id: entry.id,
      habitId: entry.habitId,
      date: entry.date,
      value: entry.value,
    );
  }

  /// Converts this model to a [HabitEntry] entity.
  HabitEntry toEntity() {
    return HabitEntry(
      id: id,
      habitId: habitId,
      date: date,
      value: value,
    );
  }

  /// Creates a unique key for indexing by habitId and date.
  static String createKey(String habitId, DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    return '${habitId}_${normalizedDate.toIso8601String().split('T')[0]}';
  }

  /// Gets the key for this entry.
  String get entryKey => createKey(habitId, date);
}
