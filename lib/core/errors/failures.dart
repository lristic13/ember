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
