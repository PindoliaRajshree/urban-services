// File: lib/features/authentication/login/models/login_request.dart
// Purpose: Request payload for POST /login. Supports both the manual
// (email/password) and Google (google_id + id_token) sign-in flows — same
// shape as RegisterRequest, minus name/mobile/role which login doesn't need.

class LoginRequest {
  LoginRequest({
    required this.loginType,
    this.email,
    this.password,
    this.googleId,
    this.idToken,
  });

  /// 'manual' or 'google'.
  final String loginType;

  final String? email;

  /// Required when [loginType] is 'manual', omitted for 'google'.
  final String? password;

  /// Google account id (`GoogleSignInAccount.id`) — sent as `google_id`.
  /// Required when [loginType] is 'google', omitted otherwise.
  final String? googleId;

  /// Google auth token (ID token from the completed Google sign-in) — sent
  /// as `id_token`, alongside [googleId]. Required when [loginType] is
  /// 'google', omitted otherwise.
  final String? idToken;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'login_type': loginType};

    if (email != null && email!.trim().isNotEmpty) {
      map['email'] = email!.trim();
    }
    if (loginType == 'manual' && password != null && password!.isNotEmpty) {
      map['password'] = password;
    }
    if (googleId != null && googleId!.trim().isNotEmpty) {
      map['google_id'] = googleId!.trim();
    }
    if (idToken != null && idToken!.trim().isNotEmpty) {
      map['id_token'] = idToken!.trim();
    }

    return map;
  }
}
