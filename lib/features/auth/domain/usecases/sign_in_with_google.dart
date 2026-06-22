import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

/// Use case for signing in with Google.
class SignInWithGoogle {
  final AuthRepository _repository;

  const SignInWithGoogle(this._repository);

  Future<Result<AppUser, Failure>> call() {
    return _repository.signInWithGoogle();
  }
}
