// File: lib/features/home_provider/complete_profile/models/profile_update_response.dart
// Purpose: Parses POST provider/provide-profile/update.
//
// Shape not yet confirmed against a live response — kept loose (message +
// the raw `data` map) until we've tested against the real API. Update this
// once the actual response is known, following the pattern in
// service_address_response.dart (parse the confirmed fields explicitly).

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
