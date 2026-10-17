// File: lib/features/home/complete_profile/user_profile_repository.dart
// Purpose: Network calls for the user (customer) profile: fetch it and
// submit the profile form. Mobile OTP calls are shared with the provider
// side (CompleteProfileRepository).

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_services/core/constants/api_constants.dart';
import 'package:urban_services/core/network/api_call.dart';
import 'package:urban_services/core/network/api_result.dart';
import 'package:urban_services/core/network/network_providers.dart';
import 'package:urban_services/core/session/session_provider.dart';
import 'package:urban_services/features/home/complete_profile/models/user_profile.dart';
import 'package:urban_services/features/home/complete_profile/models/user_profile_update_request.dart';
import 'package:urban_services/features/home_provider/complete_profile/models/profile_update_response.dart';

final userProfileRepositoryProvider = Provider<UserProfileRepository>(
  (ref) => UserProfileRepository(ref.watch(dioProvider)),
);

class UserProfileRepository {
  UserProfileRepository(this._dio);

  final Dio _dio;

  /// Calls POST user/get-user-profile.
  Future<ApiResult<UserProfile>> fetchProfile() => safeApiCall(
    () => _dio.post(ApiConstants.userProfile),
    UserProfile.fromJson,
  );

  /// Calls POST user/update-user-profile with the form data built from
  /// [request]. The FormData is built inside [safeApiCall], so an
  /// unreadable photo becomes an [ApiError] instead of an uncaught exception.
  Future<ApiResult<ProfileUpdateResponse>> updateProfile(
    UserProfileUpdateRequest request,
  ) => safeApiCall(
    () async => _dio.post(
      ApiConstants.userProfileUpdate,
      data: await request.toFormData(),
      // A photo upload can outlast the default 30s on slow mobile networks.
      options: Options(sendTimeout: const Duration(minutes: 2)),
    ),
    ProfileUpdateResponse.fromJson,
  );
}

/// The logged-in user's saved profile. Home and Profile watch it for the
/// avatar and to decide whether to prompt for completion; invalidated after
/// a successful submit.
final userProfileStatusProvider = FutureProvider<UserProfile>((ref) async {
  // Re-fetch for a different login instead of reusing the previous result.
  ref.watch(sessionProvider.select((s) => s.token));
  final result = await ref.watch(userProfileRepositoryProvider).fetchProfile();
  return switch (result) {
    ApiSuccess(:final data) => data,
    ApiError(:final failure) => throw failure,
  };
});
