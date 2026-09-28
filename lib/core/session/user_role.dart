// File: lib/core/session/user_role.dart
// Purpose: The two account types the app supports. Replaces the raw
// 'User' / 'provider' strings that used to be compared with toLowerCase().

enum UserRole {
  user,
  provider;

  /// Parses the backend's `role` field (or a stored pref) case-insensitively.
  /// Anything unrecognised falls back to [UserRole.user].
  static UserRole fromString(String? value) =>
      value?.trim().toLowerCase() == 'provider' ? provider : user;

  /// The value the backend expects in requests (`role` in /register).
  String get apiValue => name;

  bool get isProvider => this == provider;

  /// "User" / "Provider", for messages.
  String get label => isProvider ? 'Provider' : 'User';
}

/// The message shown when the account's role (from the backend) differs
/// from the role picked on the Welcome screen, or null when they match.
String? roleMismatchMessage(UserRole picked, UserRole? actual) {
  if (actual == null || actual == picked) return null;
  return "This account is registered as a ${actual.label}, so you're "
      "continuing as a ${actual.label}.";
}
