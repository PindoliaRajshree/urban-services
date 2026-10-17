// File: lib/features/home/complete_profile/models/user_profile.dart
// Purpose: Parses POST user/get-user-profile.
//
// Confirmed shape (live response):
// {
//   "status": true,
//   "message": "User profile fetched successfully",
//   "data": {
//     "id": 32, "name": "balaji", "email": "abhay@gmail.com",
//     "mobile": "9617527176", "login_type": "manual",
//     "profile_image": "https://…/public/storage/provider/documents/x.jpg",
//     "role": "provider", "date_of_birth": null, "gender": null,
//     "country": null, "state": null, "city": null, "pincode": null,
//     "full_address": null, "is_mobile_verified": false, ...
//   }
// }
//
// Unlike the provider profile, `data` is flat and always present — the
// backend has no "profile completed" flag, so see [isProfileCompleted].

class UserProfile {
  UserProfile({
    this.name,
    this.email,
    this.mobile,
    this.profileImage,
    this.dateOfBirth,
    this.gender,
    this.country,
    this.state,
    this.city,
    this.pincode,
    this.fullAddress,
    this.isMobileVerified = false,
  });

  final String? name;
  final String? email;
  final String? mobile;

  /// Full URL or relative storage path; turn into a loadable URL with
  /// ProviderProfile.fileUrl.
  final String? profileImage;
  final DateTime? dateOfBirth;

  /// `male` / `female` / `other`.
  final String? gender;
  final String? country;
  final String? state;
  final String? city;
  final String? pincode;
  final String? fullAddress;
  final bool isMobileVerified;

  /// The backend doesn't report completion, so it's every field the form
  /// requires (besides name and photo, which may come from registration).
  bool get isProfileCompleted => [
    gender,
    dateOfBirth,
    country,
    state,
    city,
    pincode,
    fullAddress,
  ].every((v) => v != null);

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final d = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final verified = d['is_mobile_verified'];
    return UserProfile(
      name: _str(d['name']),
      email: _str(d['email']),
      mobile: _str(d['mobile']) ?? _str(d['mobile_number']),
      profileImage: _str(d['profile_image']),
      dateOfBirth: _date(d['date_of_birth']),
      gender: _str(d['gender'])?.toLowerCase(),
      country: _str(d['country']),
      state: _str(d['state']),
      city: _str(d['city']),
      pincode: _str(d['pincode']),
      fullAddress: _str(d['full_address']),
      isMobileVerified: verified == true || verified == 1 || verified == '1',
    );
  }

  static String? _str(Object? v) {
    final s = v?.toString().trim();
    return (s == null || s.isEmpty) ? null : s;
  }

  /// Accepts "yyyy-MM-dd", "yyyy-MM-dd HH:mm:ss" or ISO-8601.
  static DateTime? _date(Object? v) {
    final s = _str(v);
    if (s == null) return null;
    final parsed =
        DateTime.tryParse(s) ??
        (s.length >= 10 ? DateTime.tryParse(s.substring(0, 10)) : null);
    // Keep the calendar date only: an ISO timestamp in UTC must not shift
    // the birthday by a day in local time.
    return parsed == null
        ? null
        : DateTime(parsed.year, parsed.month, parsed.day);
  }
}
