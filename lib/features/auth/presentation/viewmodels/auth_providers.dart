import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/datasources/firebase_auth_datasource.dart';
import '../../data/datasources/user_profile_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/user_profile_repository_impl.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../../domain/usecases/claim_handle.dart';
import '../../domain/usecases/delete_account.dart';
import '../../domain/usecases/is_handle_available.dart';
import '../../domain/usecases/sign_in_with_apple.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/sign_out.dart';

part 'auth_providers.g.dart';

// ── Datasources ──────────────────────────────────────────────────────────────
@Riverpod(keepAlive: true)
FirebaseAuthDatasource firebaseAuthDatasource(Ref ref) =>
    FirebaseAuthDatasource();

@Riverpod(keepAlive: true)
UserProfileRemoteDatasource userProfileRemoteDatasource(Ref ref) =>
    UserProfileRemoteDatasource();

// ── Repositories ─────────────────────────────────────────────────────────────
@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) => AuthRepositoryImpl(
  ref.watch(firebaseAuthDatasourceProvider),
  ref.watch(userProfileRemoteDatasourceProvider),
);

@Riverpod(keepAlive: true)
UserProfileRepository userProfileRepository(Ref ref) =>
    UserProfileRepositoryImpl(
      ref.watch(firebaseAuthDatasourceProvider),
      ref.watch(userProfileRemoteDatasourceProvider),
    );

// ── Use cases ────────────────────────────────────────────────────────────────
@riverpod
SignInWithApple signInWithAppleUseCase(Ref ref) =>
    SignInWithApple(ref.watch(authRepositoryProvider));

@riverpod
SignInWithGoogle signInWithGoogleUseCase(Ref ref) =>
    SignInWithGoogle(ref.watch(authRepositoryProvider));

@riverpod
SignOut signOutUseCase(Ref ref) => SignOut(ref.watch(authRepositoryProvider));

@riverpod
DeleteAccount deleteAccountUseCase(Ref ref) =>
    DeleteAccount(ref.watch(authRepositoryProvider));

@riverpod
IsHandleAvailable isHandleAvailableUseCase(Ref ref) =>
    IsHandleAvailable(ref.watch(userProfileRepositoryProvider));

@riverpod
ClaimHandle claimHandleUseCase(Ref ref) =>
    ClaimHandle(ref.watch(userProfileRepositoryProvider));

// ── Auth state ───────────────────────────────────────────────────────────────
/// The current user (with live handle), or `null` when signed out.
@Riverpod(keepAlive: true)
Stream<AppUser?> authState(Ref ref) =>
    ref.watch(authRepositoryProvider).authStateChanges();

/// Latest known user synchronously, or `null`. Convenience over [authState].
@riverpod
AppUser? currentUser(Ref ref) => ref.watch(authStateProvider).asData?.value;
