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
}
