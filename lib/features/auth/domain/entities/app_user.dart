/// An authenticated Ember user.
///
/// [handle] is `null` until the user completes one-time handle setup, so a
/// freshly signed-in account has an identity (`uid`) but no handle yet.
class AppUser {
  final String uid;
  final String? handle; // immutable once set; null until handle setup
  final String? displayName;
  final String? photoUrl;

  const AppUser({
    required this.uid,
    this.handle,
    this.displayName,
    this.photoUrl,
  });

  /// Whether the user has completed handle setup.
  bool get hasHandle => handle != null && handle!.isNotEmpty;

  /// Up-to-two-letter initials from the display name, falling back to the
  /// handle, then `?`. For the avatar.
  String get initials {
    final source = (displayName != null && displayName!.trim().isNotEmpty)
        ? displayName!.trim()
        : handle;
    if (source == null || source.isEmpty) return '?';
    final parts = source.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) return (parts[0][0] + parts[1][0]).toUpperCase();
    return source.substring(0, source.length >= 2 ? 2 : 1).toUpperCase();
  }

  AppUser copyWith({
    String? uid,
    String? handle,
    String? displayName,
    String? photoUrl,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      handle: handle ?? this.handle,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppUser &&
          uid == other.uid &&
          handle == other.handle &&
          displayName == other.displayName &&
          photoUrl == other.photoUrl;

  @override
  int get hashCode =>
      uid.hashCode ^
      handle.hashCode ^
      displayName.hashCode ^
      photoUrl.hashCode;
}
