/// Lifecycle of a collaboration [Invite].
enum InviteStatus { pending, accepted, declined }

/// An invitation for [toUid] to collaborate on a shared habit, sent by
/// [fromUid]. Lives in the top-level `invites` collection; written only by the
/// `sendInvite` / `respondToInvite` Cloud Functions.
class Invite {
  final String id;
  final String habitId;
  final String habitName;
  final String? habitEmoji;
  final String fromUid;
  final String? fromHandle;
  final String? fromDisplayName;
  final String toUid;
  final String? toHandle;
  final InviteStatus status;
  final DateTime createdAt;

  const Invite({
    required this.id,
    required this.habitId,
    required this.habitName,
    this.habitEmoji,
    required this.fromUid,
    this.fromHandle,
    this.fromDisplayName,
    required this.toUid,
    this.toHandle,
    required this.status,
    required this.createdAt,
  });

  /// How to refer to the sender: their display name, falling back to `@handle`,
  /// then `Someone`.
  String get fromLabel {
    if (fromDisplayName != null && fromDisplayName!.trim().isNotEmpty) {
      return fromDisplayName!.trim();
    }
    if (fromHandle != null && fromHandle!.isNotEmpty) return '@$fromHandle';
    return 'Someone';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Invite &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          habitId == other.habitId &&
          habitName == other.habitName &&
          habitEmoji == other.habitEmoji &&
          fromUid == other.fromUid &&
          fromHandle == other.fromHandle &&
          fromDisplayName == other.fromDisplayName &&
          toUid == other.toUid &&
          toHandle == other.toHandle &&
          status == other.status &&
          createdAt == other.createdAt;

  @override
  int get hashCode => Object.hash(
    id,
    habitId,
    habitName,
    habitEmoji,
    fromUid,
    fromHandle,
    fromDisplayName,
    toUid,
    toHandle,
    status,
    createdAt,
  );
}
