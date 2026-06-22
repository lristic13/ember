/// Rules for a user `@handle`. Pure domain logic, shared by the handle-setup UI
/// (live validation) and the claim use-case. The backend re-validates and
/// enforces uniqueness; this is the client-side gate.
abstract class HandleRules {
  static const int minLength = 3;
  static const int maxLength = 20;

  /// Lowercase letters, digits and underscore only.
  static final RegExp _allowed = RegExp(r'^[a-z0-9_]+$');

  /// Normalizes a handle for storage/lookup (case-insensitive).
  static String normalize(String handle) => handle.trim().toLowerCase();

  /// Returns a human-readable error, or `null` if [handle] is valid.
  static String? validate(String handle) {
    final value = normalize(handle);
    if (value.isEmpty) return 'Pick a handle';
    if (value.length < minLength) {
      return 'At least $minLength characters';
    }
    if (value.length > maxLength) {
      return 'At most $maxLength characters';
    }
    if (!_allowed.hasMatch(value)) {
      return 'Use only letters, numbers and _';
    }
    return null;
  }

  static bool isValid(String handle) => validate(handle) == null;
}
