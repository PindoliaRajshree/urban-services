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
}
