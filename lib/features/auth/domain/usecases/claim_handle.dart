import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/app_user.dart';
import '../repositories/user_profile_repository.dart';
import '../validators/handle_rules.dart';

/// Use case for claiming a unique `@handle` for the current user.
///
/// Validates format locally first (fast feedback), then delegates to the
/// repository, which enforces uniqueness on the backend.
class ClaimHandle {
  final UserProfileRepository _repository;

  const ClaimHandle(this._repository);

  Future<Result<AppUser, Failure>> call(String handle) {
    final error = HandleRules.validate(handle);
    if (error != null) {
      return Future.value(Err(ValidationFailure(error)));
    }
    return _repository.claimHandle(HandleRules.normalize(handle));
  }
}
