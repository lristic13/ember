import 'dart:ui';

import 'package:hive_ce/hive.dart';

import '../../domain/entities/habit.dart';

part 'habit_model.g.dart';

@HiveType(typeId: 0)
class HabitModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? emoji;

  @HiveField(3)
  final String unit;

  @HiveField(4)
  final double? dailyGoal; // Keep for backward compatibility, no longer used

  @HiveField(5)
  final int? colorValue;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final bool isArchived;

  HabitModel({
    required this.id,
    required this.name,
    this.emoji,
    required this.unit,
    this.dailyGoal,
    this.colorValue,
    required this.createdAt,
    this.isArchived = false,
  });

  /// Creates a [HabitModel] from a [Habit] entity.
  factory HabitModel.fromEntity(Habit habit) {
    return HabitModel(
      id: habit.id,
      name: habit.name,
      emoji: habit.emoji,
      unit: habit.unit,
      colorValue: habit.color?.toARGB32(),
      createdAt: habit.createdAt,
      isArchived: habit.isArchived,
    );
  }

  /// Converts this model to a [Habit] entity.
  Habit toEntity() {
    return Habit(
      id: id,
      name: name,
      emoji: emoji,
      unit: unit,
      color: colorValue != null ? Color(colorValue!) : null,
      createdAt: createdAt,
      isArchived: isArchived,
    );
  }
}
