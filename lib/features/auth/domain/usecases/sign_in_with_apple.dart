import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

/// Use case for signing in with Apple.
class SignInWithApple {
  final AuthRepository _repository;

  const SignInWithApple(this._repository);

  Future<Result<AppUser, Failure>> call() {
    return _repository.signInWithApple();
  }
}
