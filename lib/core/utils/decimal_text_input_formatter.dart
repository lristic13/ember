import 'package:flutter/services.dart';

/// Allows a non-negative decimal number typed with either '.' or ',' as the
/// decimal separator, since the OS numeric keyboard shows whichever the
/// device locale uses. At most one separator is permitted.
///
/// Normalize the result with `value.replaceAll(',', '.')` before parsing,
/// because `double.tryParse` only accepts '.'.
class DecimalTextInputFormatter extends TextInputFormatter {
  const DecimalTextInputFormatter();

  static final RegExp _allowed = RegExp(r'^[0-9]*[.,]?[0-9]*$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty || _allowed.hasMatch(newValue.text)) {
      return newValue;
    }
    return oldValue;
  }
}
