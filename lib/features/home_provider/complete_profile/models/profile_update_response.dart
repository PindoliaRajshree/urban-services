// File: lib/features/home_provider/complete_profile/models/profile_update_response.dart
// Purpose: Parses POST provider/provider-profile/update.
//
// Response is `{status, message, data: {user, provider}}` — the same
// provider fields as GET provider/provider-profile (see provider_profile.dart).
// Only the message is used; Home re-fetches the profile after a save.

class ProfileUpdateResponse {
  ProfileUpdateResponse({this.message, this.data});

  final String? message;
  final Map<String, dynamic>? data;

  factory ProfileUpdateResponse.fromJson(Map<String, dynamic> json) {
    return ProfileUpdateResponse(
      message: json['message']?.toString(),
      data: json['data'] is Map<String, dynamic>
          ? json['data'] as Map<String, dynamic>
          : null,
    );
  }
}
