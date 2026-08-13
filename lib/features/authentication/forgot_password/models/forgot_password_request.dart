// File: lib/features/authentication/forgot_password/models/forgot_password_request.dart
// Purpose: Request payload for POST /forgot-password — one shared endpoint
// used for all three steps of the flow, distinguished by which fields are
// present:
//   1. Send OTP:      { email }
//   2. Verify OTP:     { email, otp }
//   3. Reset password: { email, otp, password, password_confirmation }
//
// Common to both 'user' and 'provider' accounts — no role field needed.

class ForgotPasswordRequest {
  ForgotPasswordRequest({
    required this.email,
    this.otp,
    this.password,
    this.passwordConfirmation,
  });

  final String email;
  final String? otp;
  final String? password;

  /// Laravel's `confirmed` validation rule expects this as
  /// `password_confirmation`.
  final String? passwordConfirmation;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'email': email.trim()};

    if (otp != null && otp!.trim().isNotEmpty) {
      map['otp'] = otp!.trim();
    }
    if (password != null && password!.isNotEmpty) {
      map['password'] = password;
    }
    if (passwordConfirmation != null && passwordConfirmation!.isNotEmpty) {
      map['password_confirmation'] = passwordConfirmation;
    }

    return map;
  }
}
