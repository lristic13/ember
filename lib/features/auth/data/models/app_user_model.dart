import '../../domain/entities/app_user.dart';

/// Data-layer model for a `users/{uid}` Firestore document.
class AppUserModel {
  final String uid;
  final String? handle;
  final String? displayName;
  final String? photoUrl;

  const AppUserModel({
    required this.uid,
    this.handle,
    this.displayName,
    this.photoUrl,
  });

  factory AppUserModel.fromDoc(String id, Map<String, dynamic> data) {
    return AppUserModel(
      uid: id,
      handle: data['handle'] as String?,
      displayName: data['displayName'] as String?,
      photoUrl: data['photoUrl'] as String?,
    );
  }

  AppUser toEntity() => AppUser(
    uid: uid,
    handle: handle,
    displayName: displayName,
    photoUrl: photoUrl,
  );
}
