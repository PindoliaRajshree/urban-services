// File: lib/features/authentication/forgot_password/models/resend_otp_request.dart
// Purpose: Request payload for POST /resend-otp — resends the OTP for the
// email captured in step 1 of the forgot-password flow. Kept as its own
// model (rather than reusing ForgotPasswordRequest) since this hits a
// separate endpoint with a single required field.
//
// Common to both 'user' and 'provider' accounts — no role field needed.

class ResendOtpRequest {
  ResendOtpRequest({required this.email});

  final String email;

  Map<String, dynamic> toJson() => {'email': email.trim()};
}
