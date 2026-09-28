// File: lib/core/constants/storage_keys.dart
// Purpose: Central list of SharedPreferences keys so string literals aren't
// duplicated (and risk drifting) across the app.

class StorageKeys {
  StorageKeys._();

  static const String authToken = 'auth_token';
  static const String userId = 'user_id';
  static const String userName = 'user_name';
  static const String userEmail = 'user_email';
  static const String userMobile = 'user_mobile';
  static const String userRole = 'user_role';

  /// Set on the first launch after install (see TokenStore.init). Not a
  /// session key, so it survives logout.
  static const String appInstalled = 'app_installed';

  /// Everything that belongs to the logged-in account. Logout removes only
  /// these, so device-level flags (like [appInstalled]) are kept. The
  /// token itself lives in secure storage (TokenStore); [authToken] is
  /// listed so a pre-migration copy is removed too.
  static const List<String> sessionKeys = [
    authToken,
    userId,
    userName,
    userEmail,
    userMobile,
    userRole,
  ];
}
