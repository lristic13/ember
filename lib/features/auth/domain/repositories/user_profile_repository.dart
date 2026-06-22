import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/app_user.dart';

/// Contract for the user's profile + handle. Implemented in the data layer
/// (Firestore + the `claimHandle` Cloud Function).
abstract class UserProfileRepository {
  /// Whether [handle] is free to claim (case-insensitive lookup).
  Future<Result<bool, Failure>> isHandleAvailable(String handle);

  /// Atomically reserves [handle] for the current user. Fails with
  /// [HandleTakenFailure] if it was claimed first. Returns the updated user.
  Future<Result<AppUser, Failure>> claimHandle(String handle);

  /// Reads a user's public profile by uid.
  Future<Result<AppUser, Failure>> getProfile(String uid);
}
