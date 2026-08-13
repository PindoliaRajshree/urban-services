// File: lib/features/authentication/register/register_repository.dart
// Purpose: Auth-related network calls — registration (manual + Google),
// login, logout and forgot-password.

import 'package:urban_services/core/constants/api_constants.dart';
import 'package:urban_services/core/constants/storage_keys.dart';
import 'package:urban_services/core/services/api_result.dart';
import 'package:urban_services/core/services/api_service.dart';
import 'package:urban_services/features/authentication/forgot_password/models/forgot_password_request.dart';
import 'package:urban_services/features/authentication/login/models/login_request.dart';
import 'package:urban_services/features/authentication/login/models/login_response.dart';
import 'package:urban_services/features/authentication/register/models/register_request.dart';
import 'package:urban_services/features/authentication/register/models/register_response.dart';
import 'package:urban_services/shared_preferences/sharedpreference_helper.dart';

class AuthRepository {
  AuthRepository({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  Future<ApiResult<RegisterResponse>> register(RegisterRequest request) {
    return _apiService.post<RegisterResponse>(
      ApiConstants.register,
      data: request.toJson(),
      fromJson: RegisterResponse.fromJson,
    );
  }

  Future<ApiResult<LoginResponse>> login(LoginRequest request) {
    return _apiService.post<LoginResponse>(
      ApiConstants.login,
      data: request.toJson(),
      fromJson: LoginResponse.fromJson,
    );
  }

  /// Calls POST /logout. The token is sent both ways: automatically as an
  /// `Authorization: Bearer <token>` header (via DioClient's interceptor)
  /// and explicitly in the body as `token`, so this works regardless of how
  /// the backend expects to read it.
  Future<ApiResult<String>> logout() async {
    final token = await SharedPreferencesHelper.instance.getValue<String>(
      StorageKeys.authToken,
    );

    return _apiService.post<String>(
      ApiConstants.logout,
      data: {'token': token},
      fromJson: (json) =>
          (json['message'] ?? 'Logged out successfully').toString(),
    );
  }

  /// Calls POST /forgot-password — shared across all three steps of the
  /// flow (send OTP / verify OTP / reset password); see
  /// [ForgotPasswordRequest] for the exact shape of each step.
  Future<ApiResult<String>> forgotPassword(ForgotPasswordRequest request) {
    return _apiService.post<String>(
      ApiConstants.forgotPassword,
      data: request.toJson(),
      fromJson: (json) => (json['message'] ?? 'Success').toString(),
    );
  }
}
