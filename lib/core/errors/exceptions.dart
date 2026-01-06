/// Base class for all exceptions in the application.
sealed class AppException implements Exception {
  final String message;

  const AppException(this.message);

  @override
  String toString() => 'AppException: $message';
}

/// Exception related to local database operations.
final class DatabaseException extends AppException {
  const DatabaseException([super.message = 'Database operation failed']);
}

/// Exception related to cache operations.
final class CacheException extends AppException {
  const CacheException([super.message = 'Cache operation failed']);
}

/// Exception when a requested resource is not found.
final class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Resource not found']);
}

/// Exception related to validation errors.
final class ValidationException extends AppException {
  const ValidationException([super.message = 'Validation failed']);
}
