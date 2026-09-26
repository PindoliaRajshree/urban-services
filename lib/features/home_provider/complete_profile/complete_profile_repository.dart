// File: lib/features/home_provider/complete_profile/complete_profile_repository.dart
// Purpose: Network call for submitting the provider profile-completion form.

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_services/core/constants/api_constants.dart';
import 'package:urban_services/core/network/api_call.dart';
import 'package:urban_services/core/network/api_result.dart';
import 'package:urban_services/core/network/network_providers.dart';
import 'package:urban_services/features/home_provider/complete_profile/models/profile_update_request.dart';
import 'package:urban_services/features/home_provider/complete_profile/models/profile_update_response.dart';

final completeProfileRepositoryProvider = Provider<CompleteProfileRepository>(
  (ref) => CompleteProfileRepository(ref.watch(dioProvider)),
);

class CompleteProfileRepository {
  CompleteProfileRepository(this._dio);

  final Dio _dio;

  /// Calls POST provider/provide-profile/update with the form data (fields
  /// + files) built from [request].
  ///
  /// The FormData is built inside [safeApiCall], so a missing or unreadable
  /// file becomes an [ApiError] instead of an uncaught exception.
  Future<ApiResult<ProfileUpdateResponse>> updateProfile(
    ProfileUpdateRequest request,
  ) => safeApiCall(
    () async => _dio.post(
      ApiConstants.providerProfileUpdate,
      data: await request.toFormData(),
      // Up to 4 documents + a photo: the default 30s send timeout is too
      // short on slow mobile networks.
      options: Options(sendTimeout: const Duration(minutes: 2)),
    ),
    ProfileUpdateResponse.fromJson,
  );
}
