// File: lib/core/session/token_store.dart
// Purpose: Keeps the auth token in secure storage (Android Keystore / iOS
// Keychain) instead of plain SharedPreferences. The token is read once in
// main() via [TokenStore.init] and cached, so SessionNotifier can still
// build its state synchronously before the first frame.

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:urban_services/core/constants/storage_keys.dart';
import 'package:urban_services/shared_preferences/sharedpreference_helper.dart';

class TokenStore {
  TokenStore._();

  static final TokenStore instance = TokenStore._();

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  String? _token;

  /// The cached token, or null when logged out.
  String? get token => _token;

  /// Loads the token. Call once in main(), after
  /// SharedPreferencesHelper.init().
  ///
  /// - First launch after install: clears any keychain token left over from
  ///   a previous install (iOS keeps the keychain across uninstalls, but
  ///   SharedPreferences — which holds the name/ID/role — is wiped).
  /// - Moves a token saved by an older app version from SharedPreferences
  ///   into secure storage, so existing logins survive the update.
  static Future<void> init() => instance._init();

  Future<void> _init() async {
    final prefs = SharedPreferencesHelper.instance.prefs;

    if (!(prefs.getBool(StorageKeys.appInstalled) ?? false)) {
      final legacyToken = prefs.getString(StorageKeys.authToken);
      // An update from a version without this flag still has its token in
      // prefs, so it isn't a fresh install — keep that login.
      if (legacyToken == null) await _storage.delete(key: _tokenKey);
      await prefs.setBool(StorageKeys.appInstalled, true);
    }

    final legacyToken = prefs.getString(StorageKeys.authToken);
    if (legacyToken != null) {
      if (legacyToken.isNotEmpty) {
        await _storage.write(key: _tokenKey, value: legacyToken);
      }
      await prefs.remove(StorageKeys.authToken);
    }

    _token = await _storage.read(key: _tokenKey);
  }

  Future<void> write(String token) async {
    await _storage.write(key: _tokenKey, value: token);
    _token = token;
  }

  Future<void> delete() async {
    await _storage.delete(key: _tokenKey);
    _token = null;
  }

  static const String _tokenKey = StorageKeys.authToken;
}
