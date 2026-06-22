/// Base class for all failures in the application.
sealed class Failure {
  final String message;

  const Failure(this.message);

  @override
  String toString() => 'Failure: $message';
}

/// Failure related to local database operations.
final class DatabaseFailure extends Failure {
  const DatabaseFailure([super.message = 'Database operation failed']);
}

/// Failure related to cache operations.
final class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache operation failed']);
}

/// Failure when a requested resource is not found.
final class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Resource not found']);
}

/// Failure related to validation errors.
final class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Validation failed']);
}

/// Failure for unexpected errors.
final class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'An unexpected error occurred']);
}

/// Failure related to authentication (sign-in, sign-out, account deletion).
final class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed']);
}

/// Failure when the user cancels an interactive flow (e.g. sign-in sheet).
final class CancelledFailure extends Failure {
  const CancelledFailure([super.message = 'Cancelled']);
}

/// Failure related to network/connectivity or a remote backend.
final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network error']);
}

/// Failure when a requested @handle is already taken.
final class HandleTakenFailure extends Failure {
  const HandleTakenFailure([super.message = 'That handle is already taken']);
}
