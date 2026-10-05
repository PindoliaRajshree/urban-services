// File: lib/features/home_provider/complete_profile/models/provider_profile.dart
// Purpose: Parses GET provider/provider-profile.
//
// Confirmed shape (live response):
// {
//   "status": true,
//   "message": "Provider profile fetched successfully",
//   "data": {
//     "user": {"id": 15, "name": "...", "email": "...", "mobile_number": null, ...},
//     "provider": {
//       "experience_years": 1, "gender": "male",
//       "date_of_birth": "0200-02-01 00:00:00.000",
//       "service_types": "1", "sub_service_types": 2,
//       "pricing_type": "per_hour", "starting_price": "5.00",
//       "service_area_km": 10, "availability_type": "full_time",
//       "team_size": 11, "bio": "...", "address": "...", "city": "...",
//       "state": "...", "pincode": "452003",
//       "latitude": "12.00000000", "longitude": "11.00000000",
//       "aadhaar_number": "...", "aadhaar_front_image": "provider/documents/x.jpg",
//       "aadhaar_back_image": "...", "profile_image": "...",
//       "pan_number": "...", "pan_image": "...",
//       "account_holder_name": "...", "bank_name": "...",
//       "account_number": "...", "mobile_number": "...", "ifsc_code": "...",
//       "upi_id": "...", "is_profile_completed": true, ...
//     }
//   }
// }
//
// Numbers arrive as either strings or numbers (and differ from the update
// response), so every field is read leniently. A provider who has never
// submitted the profile gets a 404 instead — see
// CompleteProfileRepository.fetchProfile.

import 'package:urban_services/core/constants/api_constants.dart';

class ProviderProfile {
  ProviderProfile({
    this.name,
    this.email,
    this.userMobile,
    this.experienceYears,
    this.gender,
    this.dateOfBirth,
    this.serviceTypeId,
    this.subServiceTypeId,
    this.pricingType,
    this.startingPrice,
    this.serviceAreaKm,
    this.availabilityType,
    this.teamSize,
    this.bio,
    this.address,
    this.city,
    this.state,
    this.pincode,
    this.latitude,
    this.longitude,
    this.aadhaarNumber,
    this.aadhaarFrontImage,
    this.aadhaarBackImage,
    this.profileImage,
    this.panNumber,
    this.panImage,
    this.accountHolderName,
    this.bankName,
    this.accountNumber,
    this.mobileNumber,
    this.ifscCode,
    this.upiId,
    this.isProfileCompleted = false,
  });

  // From `data.user`
  final String? name;
  final String? email;
  final String? userMobile;

  // From `data.provider`
  final int? experienceYears;
  final String? gender;
  final DateTime? dateOfBirth;
  final int? serviceTypeId;
  final int? subServiceTypeId;
  final String? pricingType;
  final String? startingPrice;
  final int? serviceAreaKm;
  final String? availabilityType;
  final int? teamSize;
  final String? bio;
  final String? address;
  final String? city;
  final String? state;
  final String? pincode;
  final double? latitude;
  final double? longitude;
  final String? aadhaarNumber;

  /// Relative storage paths (e.g. `provider/documents/x.jpg`); turn into
  /// a loadable URL with [fileUrl].
  final String? aadhaarFrontImage;
  final String? aadhaarBackImage;
  final String? profileImage;
  final String? panImage;

  final String? panNumber;
  final String? accountHolderName;
  final String? bankName;
  final String? accountNumber;
  final String? mobileNumber;
  final String? ifscCode;
  final String? upiId;
  final bool isProfileCompleted;

  /// The number to prefill: the provider's saved one, else the one given
  /// at registration.
  String? get preferredMobile =>
      _nonEmpty(mobileNumber) ?? _nonEmpty(userMobile);

  /// Full URL for a stored file path, or null when there is none. Paths
  /// that are already absolute URLs are returned as-is.
  static String? fileUrl(String? path) {
    final p = _nonEmpty(path);
    if (p == null) return null;
    if (p.startsWith('http://') || p.startsWith('https://')) return p;
    return '${ApiConstants.storageBaseUrl}${p.startsWith('/') ? p.substring(1) : p}';
  }

  factory ProviderProfile.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final user = data['user'] is Map<String, dynamic>
        ? data['user'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final p = data['provider'] is Map<String, dynamic>
        ? data['provider'] as Map<String, dynamic>
        : const <String, dynamic>{};

    return ProviderProfile(
      name: _str(user['name']),
      email: _str(user['email']),
      userMobile: _str(user['mobile_number']) ?? _str(user['mobile']),
      experienceYears: _int(p['experience_years']),
      gender: _str(p['gender']),
      dateOfBirth: _date(p['date_of_birth']),
      serviceTypeId: _int(p['service_types']),
      subServiceTypeId: _int(p['sub_service_types']),
      pricingType: _str(p['pricing_type']),
      startingPrice: _amount(p['starting_price']),
      serviceAreaKm: _int(p['service_area_km']),
      availabilityType: _str(p['availability_type']),
      teamSize: _int(p['team_size']),
      bio: _str(p['bio']),
      address: _str(p['address']),
      city: _str(p['city']),
      state: _str(p['state']),
      pincode: _str(p['pincode']),
      latitude: _double(p['latitude']),
      longitude: _double(p['longitude']),
      aadhaarNumber: _str(p['aadhaar_number']),
      aadhaarFrontImage: _str(p['aadhaar_front_image']),
      aadhaarBackImage: _str(p['aadhaar_back_image']),
      profileImage: _str(p['profile_image']),
      panNumber: _str(p['pan_number']),
      panImage: _str(p['pan_image']),
      accountHolderName: _str(p['account_holder_name']),
      bankName: _str(p['bank_name']),
      accountNumber: _str(p['account_number']),
      mobileNumber: _str(p['mobile_number']),
      ifscCode: _str(p['ifsc_code']),
      upiId: _str(p['upi_id']),
      isProfileCompleted:
          p['is_profile_completed'] == true ||
          p['is_profile_completed'] == 1 ||
          p['is_profile_completed'] == '1',
    );
  }

  static String? _nonEmpty(String? v) =>
      (v == null || v.trim().isEmpty) ? null : v.trim();

  static String? _str(Object? v) => _nonEmpty(v?.toString());

  static int? _int(Object? v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    final s = _str(v);
    if (s == null) return null;
    return int.tryParse(s) ?? double.tryParse(s)?.toInt();
  }

  static double? _double(Object? v) {
    if (v is num) return v.toDouble();
    final s = _str(v);
    return s == null ? null : double.tryParse(s);
  }

  /// "5.00" -> "5", "5.50" -> "5.5" (the price field takes whole rupees,
  /// so a fractional amount is rounded).
  static String? _amount(Object? v) {
    final d = _double(v);
    return d?.round().toString();
  }

  /// Accepts "yyyy-MM-dd", "yyyy-MM-dd HH:mm:ss.SSS" or ISO-8601.
  static DateTime? _date(Object? v) {
    final s = _str(v);
    if (s == null) return null;
    return DateTime.tryParse(s) ??
        (s.length >= 10 ? DateTime.tryParse(s.substring(0, 10)) : null);
  }
}
