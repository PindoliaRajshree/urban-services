// File: lib/features/home_provider/complete_profile/complete_profile_repository.dart
// Purpose: Network call for submitting the provider profile-completion form.

import 'package:urban_services/core/constants/api_constants.dart';
import 'package:urban_services/core/services/api_result.dart';
import 'package:urban_services/core/services/api_service.dart';
import 'package:urban_services/features/home_provider/complete_profile/models/profile_update_request.dart';
import 'package:urban_services/features/home_provider/complete_profile/models/profile_update_response.dart';

class CompleteProfileRepository {
  CompleteProfileRepository({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  /// Calls POST provider/provide-profile/update with the form data (fields
  /// + files) built from [request].
  Future<ApiResult<ProfileUpdateResponse>> updateProfile(
    ProfileUpdateRequest request,
  ) async {
    return _apiService.post<ProfileUpdateResponse>(
      ApiConstants.providerProfileUpdate,
      data: await request.toFormData(),
      fromJson: ProfileUpdateResponse.fromJson,
    );
  }
}
