import 'package:intl/intl.dart';

class StringFormatter {
  StringFormatter._privateConstructor();

  /// Capitalizes the first letter of a string
  /// Example: "hello world" -> "Hello world"
  static String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  /// Capitalizes the first letter of each word separated by hyphens
  /// Example: "under-maintenance" -> "Under-Maintenance"
  static String capitalizeHyphenatedWords(String text) {
    if (text.isEmpty) return text;
    return text.split('-').map((word) => capitalizeFirstLetter(word)).join('-');
  }

  /// Formats a DateTime into a readable string.
  /// Example: 2026-05-07T06:03:37.957Z -> 07 May 2026, 11:33 AM
  static String formatDateTimeReadable(
    DateTime dateTime, {
    bool useLocalTime = true,
    String pattern = 'dd MMM yyyy, hh:mm a',
  }) {
    final value = useLocalTime ? dateTime.toLocal() : dateTime;
    return DateFormat(pattern).format(value);
  }
}

/// Extension on String for easier usage
extension StringExtension on String {
  /// Capitalize first letter using extension
  String capitalizeFirst() {
    return StringFormatter.capitalizeFirstLetter(this);
  }

  /// Capitalize each hyphenated word using extension
  String capitalizeHyphenated() {
    return StringFormatter.capitalizeHyphenatedWords(this);
  }
}

/// Extension on DateTime for easier usage
extension DateTimeExtension on DateTime {
  /// Formats the DateTime into a readable string.
  String toReadableString({
    bool useLocalTime = true,
    String pattern = 'dd MMM yyyy, hh:mm a',
  }) {
    return StringFormatter.formatDateTimeReadable(
      this,
      useLocalTime: useLocalTime,
      pattern: pattern,
    );
  }
}
