import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../repositories/auth_repository.dart';

/// Use case for signing the current user out.
class SignOut {
  final AuthRepository _repository;

  const SignOut(this._repository);

  Future<Result<void, Failure>> call() {
    return _repository.signOut();
  }
}
