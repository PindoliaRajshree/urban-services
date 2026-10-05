// File: lib/features/home_provider/complete_profile/models/profile_update_request.dart
// Purpose: Request payload for POST provider/provider-profile/update. Built
// as multipart/form-data (rather than a plain JSON map) because the form
// includes file uploads — profile photo, Aadhaar front/back and an optional
// PAN card.
//
// Keys match the backend exactly (confirmed with Postman). Files are
// nullable: when editing a saved profile, a document the provider didn't
// replace is simply not sent and the backend keeps the stored one.

import 'dart:io';

import 'package:dio/dio.dart';

class ProfileUpdateRequest {
  ProfileUpdateRequest({
    required this.mobileNumber,
    required this.email,
    required this.gender,
    required this.dateOfBirth,
    required this.serviceTypeId,
    required this.subServiceTypeId,
    required this.experienceYears,
    required this.bio,
    required this.pricingType,
    required this.startingPrice,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    required this.latitude,
    required this.longitude,
    required this.serviceAreaKm,
    required this.availabilityType,
    required this.teamSize,
    required this.aadhaarNumber,
    required this.accountHolderName,
    required this.bankName,
    required this.accountNumber,
    required this.ifscCode,
    required this.upiId,
    this.panNumber,
    this.profileImage,
    this.aadhaarFrontImage,
    this.aadhaarBackImage,
    this.panImage,
  });

  final String mobileNumber;
  final String email;

  /// `male` / `female` / `other`.
  final String gender;

  /// `yyyy-MM-dd`.
  final String dateOfBirth;

  final int serviceTypeId;
  final int subServiceTypeId;
  final int experienceYears;
  final String bio;

  /// `per_hour` / `per_visit`.
  final String pricingType;
  final String startingPrice;

  final String address;
  final String city;
  final String state;
  final String pincode;
  final double latitude;
  final double longitude;
  final int serviceAreaKm;

  /// `full_time` / `part_time`.
  final String availabilityType;
  final int teamSize;

  final String aadhaarNumber;
  final String? panNumber;

  final String accountHolderName;
  final String bankName;
  final String accountNumber;
  final String ifscCode;
  final String upiId;

  final File? profileImage;
  final File? aadhaarFrontImage;
  final File? aadhaarBackImage;
  final File? panImage;

  Future<FormData> toFormData() async {
    final map = <String, dynamic>{
      'mobile_number': mobileNumber,
      'email': email,
      'gender': gender,
      'date_of_birth': dateOfBirth,
      'service_types': serviceTypeId,
      'sub_service_types': subServiceTypeId,
      'experience_years': experienceYears,
      'bio': bio,
      'pricing_type': pricingType,
      'starting_price': startingPrice,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      // Multipart fields are always text on the wire, so send a plain
      // decimal the backend's `numeric` rule parses — never Dart's
      // exponent form (e.g. 1e-7). 8 places matches the DB column.
      'latitude': latitude.toStringAsFixed(8),
      'longitude': longitude.toStringAsFixed(8),
      'service_area_km': serviceAreaKm,
      'availability_type': availabilityType,
      'team_size': teamSize,
      'aadhaar_number': aadhaarNumber,
      'account_holder_name': accountHolderName,
      'bank_name': bankName,
      'account_number': accountNumber,
      'ifsc_code': ifscCode,
      'upi_id': upiId.trim(),
    };

    if (panNumber != null && panNumber!.trim().isNotEmpty) {
      map['pan_number'] = panNumber!.trim();
    }

    final files = {
      'profile_image': profileImage,
      'aadhaar_front_image': aadhaarFrontImage,
      'aadhaar_back_image': aadhaarBackImage,
      'pan_image': panImage,
    };
    for (final MapEntry(:key, :value) in files.entries) {
      if (value != null) map[key] = await _imagePart(value);
    }

    return FormData.fromMap(map);
  }

  /// Sends the file with its name and an image content type, so Laravel's
  /// `mimes:jpg,jpeg,png` / `image` rules recognise it.
  static Future<MultipartFile> _imagePart(File file) {
    final name = file.path.split(RegExp(r'[/\\]')).last;
    final isPng = name.toLowerCase().endsWith('.png');
    return MultipartFile.fromFile(
      file.path,
      filename: name,
      contentType: DioMediaType('image', isPng ? 'png' : 'jpeg'),
    );
  }
}
