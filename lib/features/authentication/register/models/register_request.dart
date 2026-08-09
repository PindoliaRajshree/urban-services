// File: lib/features/authentication/register/models/register_request.dart
// Purpose: Request payload for POST /register. Supports both the manual
// (name/mobile/email/password) and Google (google_id + id_token) sign-up
// flows.

class RegisterRequest {
  RegisterRequest({
    required this.loginType,
    required this.role,
    this.name,
    this.mobile,
    this.email,
    this.password,
    this.googleId,
    this.idToken,
  });

  /// 'manual' or 'google'.
  final String loginType;

  /// 'user' or 'provider'. Required for both login types.
  final String role;

  final String? name;
  final String? mobile;
  final String? email;
  final String? password;

  /// Google account id (`GoogleSignInAccount.id`) — sent as `google_id`.
  /// Required when [loginType] is 'google', omitted otherwise.
  final String? googleId;

  /// Google auth token (ID token from the completed Google sign-in) — sent
  /// as `id_token`, alongside [googleId]. Required when [loginType] is
  /// 'google', omitted otherwise.
  final String? idToken;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'login_type': loginType, 'role': role};

    if (name != null && name!.trim().isNotEmpty) {
      map['name'] = name!.trim();
    }
    if (mobile != null && mobile!.trim().isNotEmpty) {
      map['mobile'] = mobile!.trim();
    }
    if (email != null && email!.trim().isNotEmpty) {
      map['email'] = email!.trim();
    }
    if (password != null && password!.isNotEmpty) {
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
