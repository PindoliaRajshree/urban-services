// File: lib/features/home_provider/complete_profile/complete_profile_repository.dart
// Purpose: Network calls for the provider profile: fetch the saved profile,
// send a mobile OTP, and submit the profile-completion form.

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_services/core/constants/api_constants.dart';
import 'package:urban_services/core/network/api_call.dart';
import 'package:urban_services/core/network/api_failure.dart';
import 'package:urban_services/core/network/api_result.dart';
import 'package:urban_services/core/network/network_providers.dart';
import 'package:urban_services/core/session/session_provider.dart';
import 'package:urban_services/features/home_provider/complete_profile/models/profile_update_request.dart';
import 'package:urban_services/features/home_provider/complete_profile/models/profile_update_response.dart';
import 'package:urban_services/features/home_provider/complete_profile/models/provider_profile.dart';

final completeProfileRepositoryProvider = Provider<CompleteProfileRepository>(
  (ref) => CompleteProfileRepository(ref.watch(dioProvider)),
);

class CompleteProfileRepository {
  CompleteProfileRepository(this._dio);

  final Dio _dio;

  /// The backend's message for "this provider hasn't submitted a profile
  /// yet" (sent with HTTP 404).
  static const String _profileNotFoundMessage = 'provider profile not found';

  /// Calls GET provider/provider-profile.
  ///
  /// Success with `null` means the provider has no profile yet. The
  /// backend reports that as a 404 with message "Provider profile not
  /// found"; the message is checked too so a wrong URL (Laravel's own 404)
  /// still surfaces as an error instead of silently looking like "no
  /// profile".
  Future<ApiResult<ProviderProfile?>> fetchProfile() async {
    final result = await safeApiCall(
      () => _dio.get(ApiConstants.providerProfile),
      ProviderProfile.fromJson,
    );
    if (result case ApiError(:final failure)
        when failure.type == ApiFailureType.notFound &&
            failure.message.trim().toLowerCase() == _profileNotFoundMessage) {
      return const ApiSuccess(null);
    }
    return result;
  }

  /// Calls POST provider/provider/send-otp (fields as query parameters, as
  /// the backend documents it). Returns the OTP the backend echoes back in
  /// `data.otp` (null if it stops sending it).
  Future<ApiResult<String?>> sendOtp(String mobile) => safeApiCall(
    () => _dio.post(
      ApiConstants.providerSendOtp,
      queryParameters: {'mobile_number': mobile, 'role': 'provider'},
    ),
    (json) {
      final data = json['data'];
      return data is Map ? data['otp']?.toString() : null;
    },
  );

  /// Calls POST add-mobile-number. Without [otp] it sends an OTP to
  /// [mobile]; with [otp] it verifies it and saves [mobile] on the account.
  /// Returns the server's message.
  Future<ApiResult<String?>> addMobileNumber(String mobile, {String? otp}) =>
      safeApiCall(
        () => _dio.post(
          ApiConstants.addMobileNumber,
          data: FormData.fromMap({'mobile': mobile, 'otp': ?otp}),
        ),
        (json) => json['message']?.toString(),
      );

  /// Calls POST provider/provider-profile/update with the form data
  /// (fields + files) built from [request].
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

/// The logged-in provider's saved profile (null = not submitted yet). Home
/// watches it to decide whether to prompt for profile completion;
/// invalidated after a successful submit.
final providerProfileStatusProvider = FutureProvider<ProviderProfile?>((
  ref,
) async {
  // Re-fetch for a different login instead of reusing the previous result.
  ref.watch(sessionProvider.select((s) => s.token));
  final result = await ref
      .watch(completeProfileRepositoryProvider)
      .fetchProfile();
  return switch (result) {
    ApiSuccess(:final data) => data,
    ApiError(:final failure) => throw failure,
  };
});
