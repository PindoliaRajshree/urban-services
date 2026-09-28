// File: lib/features/authentication/register/register_repository.dart
// Purpose: Auth-related network calls — registration (manual + Google),
// login, logout and forgot-password.

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_services/core/constants/api_constants.dart';
import 'package:urban_services/core/network/api_call.dart';
import 'package:urban_services/core/network/api_result.dart';
import 'package:urban_services/core/network/auth_interceptor.dart';
import 'package:urban_services/core/network/network_providers.dart';
import 'package:urban_services/features/authentication/forgot_password/models/forgot_password_request.dart';
import 'package:urban_services/features/authentication/forgot_password/models/resend_otp_request.dart';
import 'package:urban_services/features/authentication/login/models/login_request.dart';
import 'package:urban_services/features/authentication/login/models/login_response.dart';
import 'package:urban_services/features/authentication/register/models/register_request.dart';
import 'package:urban_services/features/authentication/register/models/register_response.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(dioProvider)),
);

class AuthRepository {
  AuthRepository(this._dio);

  final Dio _dio;

  /// Pre-login endpoints: a 401 here means bad credentials, not an expired
  /// session, so the auth interceptor must not log the user out.
  static Options get _publicOptions =>
      Options(extra: {AuthInterceptor.skipAuthKey: true});

  Future<ApiResult<RegisterResponse>> register(RegisterRequest request) =>
      safeApiCall(
        () => _dio.post(
          ApiConstants.register,
          data: request.toJson(),
          options: _publicOptions,
        ),
        RegisterResponse.fromJson,
      );

  Future<ApiResult<LoginResponse>> login(LoginRequest request) => safeApiCall(
    () => _dio.post(
      ApiConstants.login,
      data: request.toJson(),
      options: _publicOptions,
    ),
    LoginResponse.fromJson,
  );

  /// Calls POST /logout. The token is sent both ways: automatically as an
  /// `Authorization: Bearer <token>` header (via AuthInterceptor) and
  /// explicitly in the body as `token`, so this works regardless of how
  /// the backend expects to read it.
  Future<ApiResult<String>> logout(String? token) => safeApiCall(
    () => _dio.post(
      ApiConstants.logout,
      data: {'token': token},
      // Logging out with an already-expired token shouldn't re-trigger the
      // expiry flow; the caller clears the session either way.
      options: _publicOptions,
    ),
    (json) => (json['message'] ?? 'Logged out successfully').toString(),
  );

  /// Calls POST /forgot-password — shared across all three steps of the
  /// flow (send OTP / verify OTP / reset password); see
  /// [ForgotPasswordRequest] for the exact shape of each step.
  Future<ApiResult<String>> forgotPassword(ForgotPasswordRequest request) =>
      safeApiCall(
        () => _dio.post(
          ApiConstants.forgotPassword,
          data: request.toJson(),
          options: _publicOptions,
        ),
        (json) => (json['message'] ?? 'Success').toString(),
      );

  /// Calls POST /resend-otp — resends the OTP for the email captured in
  /// step 1 of the forgot-password flow.
  Future<ApiResult<String>> resendOtp(ResendOtpRequest request) => safeApiCall(
    () => _dio.post(
      ApiConstants.resendOtp,
      data: request.toJson(),
      options: _publicOptions,
    ),
    (json) => (json['message'] ?? 'OTP sent successfully').toString(),
  );
}
