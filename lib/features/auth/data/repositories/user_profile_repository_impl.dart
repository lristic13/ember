import 'package:cloud_functions/cloud_functions.dart' show FirebaseFunctionsException;

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../datasources/firebase_auth_datasource.dart';
import '../datasources/user_profile_remote_datasource.dart';

class UserProfileRepositoryImpl implements UserProfileRepository {
  UserProfileRepositoryImpl(this._auth, this._profiles);

  final FirebaseAuthDatasource _auth;
  final UserProfileRemoteDatasource _profiles;

  @override
  Future<Result<bool, Failure>> isHandleAvailable(String handle) async {
    try {
      return Success(await _profiles.isHandleAvailable(handle));
    } catch (e) {
      return Err(_mapError(e));
    }
  }

  @override
  Future<Result<AppUser, Failure>> claimHandle(String handle) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Err(AuthFailure('Not signed in'));
    try {
      final model = await _profiles.claimHandle(uid, handle);
      if (model == null) {
        return const Err(UnexpectedFailure('Profile missing after claim'));
      }
      return Success(model.toEntity());
    } catch (e) {
      return Err(_mapError(e));
    }
  }

  @override
  Future<Result<AppUser, Failure>> getProfile(String uid) async {
    try {
      final model = await _profiles.getProfile(uid);
      if (model == null) return const Err(NotFoundFailure('Profile not found'));
      return Success(model.toEntity());
    } catch (e) {
      return Err(_mapError(e));
    }
  }

  Failure _mapError(Object e) {
    if (e is FirebaseFunctionsException) {
      return switch (e.code) {
        'already-exists' => const HandleTakenFailure(),
        'unavailable' => const NetworkFailure(),
        'unauthenticated' => const AuthFailure('Not signed in'),
        _ => AuthFailure(e.message ?? 'Request failed'),
      };
    }
    return const UnexpectedFailure();
  }
}
