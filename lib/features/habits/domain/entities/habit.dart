import '../../../../core/constants/habit_gradient_presets.dart';
import '../../../../core/constants/habit_gradients.dart';
import 'habit_participant.dart';
import 'tracking_type.dart';

/// Represents a habit/activity that a user wants to track.
///
/// A habit is either **personal** (local, in Hive — `ownerId == null`) or
/// **shared** (cloud, in Firestore — `ownerId` set, `participants` populated).
class Habit {
  final String id;
  final String name;
  final String? emoji;
  final TrackingType trackingType;
  final String? unit; // Only used when trackingType == quantity
  final String gradientId;
  final DateTime createdAt;
  final bool isArchived;

  /// Owner uid when this is a shared (cloud) habit; null for personal/local.
  final String? ownerId;

  /// Members of a shared habit (includes the owner). Empty for personal.
  final List<HabitParticipant> participants;

  const Habit({
    required this.id,
    required this.name,
    this.emoji,
    required this.trackingType,
    this.unit,
    this.gradientId = 'ember',
    required this.createdAt,
    this.isArchived = false,
    this.ownerId,
    this.participants = const [],
  });

  /// Whether this activity tracks quantities.
  bool get isQuantity => trackingType == TrackingType.quantity;

  /// Whether this activity tracks completion only.
  bool get isCompletion => trackingType == TrackingType.completion;

  /// Whether this is a shared (cloud) habit rather than a personal local one.
  bool get isShared => ownerId != null;

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
    String? ownerId,
    List<HabitParticipant>? participants,
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
      ownerId: ownerId ?? this.ownerId,
      participants: participants ?? this.participants,
    );
  }

  bool _sameParticipants(List<HabitParticipant> other) {
    if (participants.length != other.length) return false;
    for (var i = 0; i < participants.length; i++) {
      if (participants[i] != other[i]) return false;
    }
    return true;
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
          isArchived == other.isArchived &&
          ownerId == other.ownerId &&
          _sameParticipants(other.participants);

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      emoji.hashCode ^
      trackingType.hashCode ^
      unit.hashCode ^
      gradientId.hashCode ^
      createdAt.hashCode ^
      isArchived.hashCode ^
      ownerId.hashCode ^
      Object.hashAll(participants);

  @override
  String toString() {
    return 'Habit{id: $id, name: $name, trackingType: $trackingType, '
        'unit: $unit, gradientId: $gradientId, isArchived: $isArchived, '
        'ownerId: $ownerId, participants: ${participants.length}}';
  }
}
