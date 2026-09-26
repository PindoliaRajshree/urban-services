// File: lib/core/session/session_provider.dart
// Purpose: Single source of truth for "who is logged in" — token, basic
// user info and role. Replaces the permanent GetX LoginController's role
// and the scattered SharedPreferences reads. The router listens to this to
// send the user back to Welcome when the session ends (logout or 401).

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_services/core/constants/storage_keys.dart';
import 'package:urban_services/core/session/user_role.dart';
import 'package:urban_services/features/authentication/login/models/login_response.dart';
import 'package:urban_services/features/authentication/register/models/register_response.dart';
import 'package:urban_services/shared_preferences/sharedpreference_helper.dart';

class SessionState {
  const SessionState({
    this.token,
    this.userId,
    this.name,
    this.email,
    this.mobile,
    this.role,
    this.selectedRole = UserRole.user,
  });

  final String? token;
  final int? userId;
  final String? name;
  final String? email;
  final String? mobile;

  /// Role confirmed by the backend (login/register response, or restored
  /// from storage). Null until the user has authenticated.
  final UserRole? role;

  /// Role picked on the Welcome screen, used for /register and as the
  /// fallback before the backend has confirmed one.
  final UserRole selectedRole;

  bool get isAuthenticated => token != null && token!.isNotEmpty;

  /// The role the UI should act on.
  UserRole get effectiveRole => role ?? selectedRole;

  SessionState copyWith({UserRole? selectedRole}) => SessionState(
    token: token,
    userId: userId,
    name: name,
    email: email,
    mobile: mobile,
    role: role,
    selectedRole: selectedRole ?? this.selectedRole,
  );
}

class SessionNotifier extends Notifier<SessionState> {
  SharedPreferencesHelper get _prefs => SharedPreferencesHelper.instance;

  @override
  SessionState build() {
    // SharedPreferencesHelper.init() is awaited in main(), so this is safe
    // to read synchronously before the first frame.
    final p = _prefs.prefs;
    final storedRole = p.getString(StorageKeys.userRole);
    return SessionState(
      token: p.getString(StorageKeys.authToken),
      userId: p.getInt(StorageKeys.userId),
      name: p.getString(StorageKeys.userName),
      email: p.getString(StorageKeys.userEmail),
      mobile: p.getString(StorageKeys.userMobile),
      role: storedRole == null ? null : UserRole.fromString(storedRole),
      selectedRole: UserRole.fromString(storedRole),
    );
  }

  /// Welcome screen: "Continue as User / Provider".
  void selectRole(UserRole role) {
    state = state.copyWith(selectedRole: role);
  }

  /// Persists the /login response (same keys the GetX LoginController
  /// wrote) and marks the session authenticated.
  Future<void> saveLogin(LoginResponse data) async {
    final token = data.token;
    if (token != null && token.isNotEmpty) {
      await _prefs.setValue(StorageKeys.authToken, token);
    }

    final user = data.user;
    if (user?.id != null) await _prefs.setValue(StorageKeys.userId, user!.id!);
    if (user?.name != null) {
      await _prefs.setValue(StorageKeys.userName, user!.name!);
    }
    if (user?.email != null) {
      await _prefs.setValue(StorageKeys.userEmail, user!.email!);
    }
    if (user?.mobile != null) {
      await _prefs.setValue(StorageKeys.userMobile, user!.mobile!);
    }
    if (user?.role != null) {
      await _prefs.setValue(StorageKeys.userRole, user!.role!);
    }

    state = build();
  }

  /// Persists the /register response. Intentionally the same keys the GetX
  /// RegisterController wrote (token + role only) — see the audit report
  /// (docs/UI_FLOW_AUDIT.md, C1/C2) for why that is a bug.
  Future<void> saveRegister(RegisterResponse data) async {
    final token = data.token;
    if (token != null && token.isNotEmpty) {
      await _prefs.setValue(StorageKeys.authToken, token);
    }
    await _prefs.setValue(
      StorageKeys.userRole,
      data.role ?? state.selectedRole.apiValue,
    );
    state = build();
  }

  /// Wipes all local data and ends the session. The router reacts by
  /// sending the user to Welcome; providers that watch [sessionProvider]
  /// rebuild from scratch (replaces GetX's `Get.deleteAll(force: true)`).
  Future<void> logout() async {
    await _prefs.clear();
    state = const SessionState();
  }

  /// Called by the auth interceptor when the backend answers 401 — the
  /// stored token is no longer valid.
  Future<void> expire() => logout();
}

final sessionProvider = NotifierProvider<SessionNotifier, SessionState>(
  SessionNotifier.new,
);
