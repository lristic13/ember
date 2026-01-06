/// A Result type for handling success and failure cases.
///
/// Use [Success] for successful operations and [Err] for errors.
sealed class Result<T, E> {
  const Result();

  /// Returns true if this is a [Success].
  bool get isSuccess => this is Success<T, E>;

  /// Returns true if this is an [Err].
  bool get isFailure => this is Err<T, E>;

  /// Folds the result into a single value.
  R fold<R>(
    R Function(E error) onFailure,
    R Function(T value) onSuccess,
  ) {
    return switch (this) {
      Success(:final value) => onSuccess(value),
      Err(:final error) => onFailure(error),
    };
  }

  /// Maps the success value to a new value.
  Result<R, E> map<R>(R Function(T value) transform) {
    return switch (this) {
      Success(:final value) => Success(transform(value)),
      Err(:final error) => Err(error),
    };
  }

  /// Maps the error to a new error.
  Result<T, R> mapError<R>(R Function(E error) transform) {
    return switch (this) {
      Success(:final value) => Success(value),
      Err(:final error) => Err(transform(error)),
    };
  }

  /// Returns the success value or null.
  T? get valueOrNull => switch (this) {
        Success(:final value) => value,
        Err() => null,
      };

  /// Returns the error or null.
  E? get errorOrNull => switch (this) {
        Success() => null,
        Err(:final error) => error,
      };

  /// Returns the success value or the result of [orElse].
  T getOrElse(T Function() orElse) {
    return switch (this) {
      Success(:final value) => value,
      Err() => orElse(),
    };
  }
}

/// Represents a successful result.
final class Success<T, E> extends Result<T, E> {
  final T value;

  const Success(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<T, E> && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Success($value)';
}

/// Represents a failed result.
final class Err<T, E> extends Result<T, E> {
  final E error;

  const Err(this.error);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Err<T, E> && other.error == error;

  @override
  int get hashCode => error.hashCode;

  @override
  String toString() => 'Err($error)';
}
