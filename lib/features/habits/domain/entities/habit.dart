import 'dart:ui';

/// Represents a habit that a user wants to track.
class Habit {
  final String id;
  final String name;
  final String? emoji;
  final String unit;
  final Color? color;
  final DateTime createdAt;
  final bool isArchived;

  const Habit({
    required this.id,
    required this.name,
    this.emoji,
    required this.unit,
    this.color,
    required this.createdAt,
    this.isArchived = false,
  });

  Habit copyWith({
    String? id,
    String? name,
    String? emoji,
    String? unit,
    Color? color,
    DateTime? createdAt,
    bool? isArchived,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      unit: unit ?? this.unit,
      color: color ?? this.color,
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
          color == other.color &&
          createdAt == other.createdAt &&
          isArchived == other.isArchived;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      emoji.hashCode ^
      unit.hashCode ^
      color.hashCode ^
      createdAt.hashCode ^
      isArchived.hashCode;

  @override
  String toString() {
    return 'Habit{id: $id, name: $name, emoji: $emoji, unit: $unit, isArchived: $isArchived}';
  }
}
