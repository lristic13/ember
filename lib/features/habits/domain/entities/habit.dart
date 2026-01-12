import '../../../../core/constants/habit_gradient_presets.dart';
import '../../../../core/constants/habit_gradients.dart';
import 'tracking_type.dart';

/// Represents a habit/activity that a user wants to track.
class Habit {
  final String id;
  final String name;
  final String? emoji;
  final TrackingType trackingType;
  final String? unit; // Only used when trackingType == quantity
  final String gradientId;
  final DateTime createdAt;
  final bool isArchived;

  const Habit({
    required this.id,
    required this.name,
    this.emoji,
    required this.trackingType,
    this.unit,
    this.gradientId = 'ember',
    required this.createdAt,
    this.isArchived = false,
  });

  /// Whether this activity tracks quantities.
  bool get isQuantity => trackingType == TrackingType.quantity;

  /// Whether this activity tracks completion only.
  bool get isCompletion => trackingType == TrackingType.completion;

  /// Get the HabitGradient for this habit.
  HabitGradient get gradient => HabitGradientPresets.getById(gradientId);

  Habit copyWith({
    String? id,
    String? name,
    String? emoji,
    TrackingType? trackingType,
    String? unit,
    String? gradientId,
    DateTime? createdAt,
    bool? isArchived,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      trackingType: trackingType ?? this.trackingType,
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
          trackingType == other.trackingType &&
          unit == other.unit &&
          gradientId == other.gradientId &&
          createdAt == other.createdAt &&
          isArchived == other.isArchived;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      emoji.hashCode ^
      trackingType.hashCode ^
      unit.hashCode ^
      gradientId.hashCode ^
      createdAt.hashCode ^
      isArchived.hashCode;

  @override
  String toString() {
    return 'Habit{id: $id, name: $name, emoji: $emoji, trackingType: $trackingType, unit: $unit, gradientId: $gradientId, isArchived: $isArchived}';
  }
}
