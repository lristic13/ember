import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/app_user.dart';

/// Contract for authentication. Implemented in the data layer (Firebase Auth).
/// The domain layer never sees provider/SDK types.
abstract class AuthRepository {
  /// Emits the current user, or `null` when signed out. Fires on every
  /// auth state change (and when the profile handle is claimed).
  Stream<AppUser?> authStateChanges();

  Future<Result<AppUser, Failure>> signInWithApple();

  Future<Result<AppUser, Failure>> signInWithGoogle();

  Future<Result<void, Failure>> signOut();

  /// Reauthenticates if required, deletes the account, and triggers backend
  /// cleanup (handle freed, removed from shared habits).
  Future<Result<void, Failure>> deleteAccount();
}
