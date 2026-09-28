// File: lib/core/utils/input_formatters.dart
// Purpose: Reusable TextInputFormatters for form fields.

import 'package:flutter/services.dart';

/// Upper-cases everything typed or pasted (e.g. IFSC codes).
class UpperCaseTextFormatter extends TextInputFormatter {
  const UpperCaseTextFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) => newValue.copyWith(text: newValue.text.toUpperCase());
}

/// Formatters for a 10-digit Indian mobile number.
final List<TextInputFormatter> mobileNumberFormatters = [
  FilteringTextInputFormatter.digitsOnly,
  LengthLimitingTextInputFormatter(10),
];

/// Formatters for a whole-rupee amount.
final List<TextInputFormatter> amountFormatters = [
  FilteringTextInputFormatter.digitsOnly,
  LengthLimitingTextInputFormatter(7),
];
