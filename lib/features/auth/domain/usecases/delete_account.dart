import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../repositories/auth_repository.dart';

/// Use case for deleting the current user's account (mandatory App Store flow).
class DeleteAccount {
  final AuthRepository _repository;

  const DeleteAccount(this._repository);

  Future<Result<void, Failure>> call() {
    return _repository.deleteAccount();
  }
}
