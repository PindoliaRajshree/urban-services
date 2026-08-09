// File: lib/features/authentication/register/register_repository.dart
// Purpose: Auth-related network calls. Currently just registration (manual
// + Google), but this is the natural place to add login/OTP/etc. later.

import 'package:urban_services/core/constants/api_constants.dart';
import 'package:urban_services/core/services/api_result.dart';
import 'package:urban_services/core/services/api_service.dart';
import 'package:urban_services/features/authentication/register/models/register_request.dart';
import 'package:urban_services/features/authentication/register/models/register_response.dart';

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
}
