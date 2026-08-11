// File: lib/features/authentication/login/models/login_request.dart
// Purpose: Request payload for POST /login. Google login isn't wired up
// yet, so [loginType] is always 'manual' for now — the field exists so
// this doesn't need to change shape once Google login is added.

class LoginRequest {
  LoginRequest({
    required this.email,
    required this.password,
    this.loginType = 'manual',
  });

  final String email;
  final String password;

  /// 'manual' (only supported value right now).
  final String loginType;

  Map<String, dynamic> toJson() {
    return {'email': email.trim(), 'password': password, 'login_type': loginType};
  }
}
