import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../../../core/constants/firebase_constants.dart';
import '../models/app_user_model.dart';

/// Reads the `users/{uid}` profile + `handles` collection, and calls the
/// `claimHandle` Cloud Function. Firestore/Functions types stay in the data
/// layer.
class UserProfileRemoteDatasource {
  UserProfileRemoteDatasource({
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
  }) : _db = firestore ?? FirebaseFirestore.instance,
       _functions =
           functions ?? FirebaseFunctions.instanceFor(region: kCloudFunctionsRegion);

  final FirebaseFirestore _db;
  final FirebaseFunctions _functions;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _db.collection('users').doc(uid);

  Stream<AppUserModel?> watchProfile(String uid) {
    return _userDoc(uid).snapshots().map(
      (snap) => snap.exists ? AppUserModel.fromDoc(snap.id, snap.data()!) : null,
    );
  }

  Future<AppUserModel?> getProfile(String uid) async {
    final snap = await _userDoc(uid).get();
    return snap.exists ? AppUserModel.fromDoc(snap.id, snap.data()!) : null;
  }

  Future<bool> isHandleAvailable(String handleLower) async {
    final snap = await _db.collection('handles').doc(handleLower).get();
    return !snap.exists;
  }

  /// Calls `claimHandle`, then returns the refreshed profile.
  Future<AppUserModel?> claimHandle(String uid, String handleLower) async {
    await _functions.httpsCallable('claimHandle').call(<String, dynamic>{
      'handle': handleLower,
    });
    return getProfile(uid);
  }
}
