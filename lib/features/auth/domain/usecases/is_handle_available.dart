import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../repositories/user_profile_repository.dart';
import '../validators/handle_rules.dart';

/// Use case for the live availability check on the handle-setup screen.
///
/// Returns `false` for locally-invalid handles without hitting the backend.
class IsHandleAvailable {
  final UserProfileRepository _repository;

  const IsHandleAvailable(this._repository);

  Future<Result<bool, Failure>> call(String handle) {
    if (!HandleRules.isValid(handle)) {
      return Future.value(const Success(false));
    }
    return _repository.isHandleAvailable(HandleRules.normalize(handle));
  }
}
