/// A member of a shared habit.
class HabitParticipant {
  final String uid;
  final String? handle;
  final String? displayName;
  final bool isOwner;

  const HabitParticipant({
    required this.uid,
    this.handle,
    this.displayName,
    this.isOwner = false,
  });

  /// Up-to-two-letter initials from the display name, falling back to the
  /// handle, then `?`. For the participant avatar.
  String get initials {
    final source = (displayName != null && displayName!.trim().isNotEmpty)
        ? displayName!.trim()
        : handle;
    if (source == null || source.isEmpty) return '?';
    final parts = source.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) return (parts[0][0] + parts[1][0]).toUpperCase();
    return source.substring(0, source.length >= 2 ? 2 : 1).toUpperCase();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitParticipant &&
          uid == other.uid &&
          handle == other.handle &&
          displayName == other.displayName &&
          isOwner == other.isOwner;

  @override
  int get hashCode =>
      uid.hashCode ^ handle.hashCode ^ displayName.hashCode ^ isOwner.hashCode;
}
