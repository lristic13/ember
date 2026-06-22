import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_datasource.dart';
import '../datasources/user_profile_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._auth, this._profiles);

  final FirebaseAuthDatasource _auth;
  final UserProfileRemoteDatasource _profiles;

  @override
  Stream<AppUser?> authStateChanges() {
    // switch-map: each auth change cancels the previous profile subscription so
    // sign-out propagates even while a profile stream is live.
    final controller = StreamController<AppUser?>();
    StreamSubscription? profileSub;

    final authSub = _auth.authStateChanges().listen((user) {
      profileSub?.cancel();
      if (user == null) {
        controller.add(null);
        return;
      }
      profileSub = _profiles
          .watchProfile(user.uid)
          .listen(
            (profile) => controller.add(
              AppUser(
                uid: user.uid,
                handle: profile?.handle,
                displayName: profile?.displayName ?? user.displayName,
                photoUrl: profile?.photoUrl ?? user.photoURL,
              ),
            ),
            onError: controller.addError,
          );
    }, onError: controller.addError);

    controller.onCancel = () async {
      await profileSub?.cancel();
      await authSub.cancel();
    };
    return controller.stream;
  }

  @override
  Future<Result<AppUser, Failure>> signInWithApple() =>
      _guard(() => _auth.signInWithApple().then(_toAppUser));

  @override
  Future<Result<AppUser, Failure>> signInWithGoogle() =>
      _guard(() => _auth.signInWithGoogle().then(_toAppUser));

  @override
  Future<Result<void, Failure>> signOut() async {
    try {
      await _auth.signOut();
      return const Success(null);
    } catch (e) {
      return Err(_mapError(e));
    }
  }

  @override
  Future<Result<void, Failure>> deleteAccount() async {
    try {
      await _auth.deleteAccount();
      return const Success(null);
    } catch (e) {
      return Err(_mapError(e));
    }
  }

  Future<AppUser> _toAppUser(User user) async {
    final profile = await _profiles.getProfile(user.uid);
    return AppUser(
      uid: user.uid,
      handle: profile?.handle,
      displayName: profile?.displayName ?? user.displayName,
      photoUrl: profile?.photoUrl ?? user.photoURL,
    );
  }

  Future<Result<AppUser, Failure>> _guard(Future<AppUser> Function() run) async {
    try {
      return Success(await run());
    } catch (e) {
      return Err(_mapError(e));
    }
  }

  Failure _mapError(Object e) {
    if (e is GoogleSignInException) {
      return e.code == GoogleSignInExceptionCode.canceled
          ? const CancelledFailure()
          : AuthFailure(e.description ?? 'Google sign-in failed');
    }
    if (e is SignInWithAppleAuthorizationException) {
      return e.code == AuthorizationErrorCode.canceled
          ? const CancelledFailure()
          : AuthFailure(e.message);
    }
    if (e is FirebaseAuthException) {
      return e.code == 'network-request-failed'
          ? const NetworkFailure()
          : AuthFailure(e.message ?? 'Authentication failed');
    }
    return const UnexpectedFailure();
  }
}
