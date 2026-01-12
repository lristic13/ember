import '../../../../core/constants/habit_gradient_presets.dart';
import '../../../../core/constants/habit_gradients.dart';

/// Represents a habit that a user wants to track.
class Habit {
  final String id;
  final String name;
  final String? emoji;
  final String unit;
  final String gradientId;
  final DateTime createdAt;
  final bool isArchived;

  const Habit({
    required this.id,
    required this.name,
    this.emoji,
    required this.unit,
    this.gradientId = 'ember',
    required this.createdAt,
    this.isArchived = false,
  });

  /// Get the HabitGradient for this habit.
  HabitGradient get gradient => HabitGradientPresets.getById(gradientId);

  Habit copyWith({
    String? id,
    String? name,
    String? emoji,
    String? unit,
    String? gradientId,
    DateTime? createdAt,
    bool? isArchived,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      unit: unit ?? this.unit,
      gradientId: gradientId ?? this.gradientId,
      createdAt: createdAt ?? this.createdAt,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Habit &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          emoji == other.emoji &&
          unit == other.unit &&
          gradientId == other.gradientId &&
          createdAt == other.createdAt &&
          isArchived == other.isArchived;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      emoji.hashCode ^
      unit.hashCode ^
      gradientId.hashCode ^
      createdAt.hashCode ^
      isArchived.hashCode;

  @override
  String toString() {
    return 'Habit{id: $id, name: $name, emoji: $emoji, unit: $unit, gradientId: $gradientId, isArchived: $isArchived}';
  }
}
