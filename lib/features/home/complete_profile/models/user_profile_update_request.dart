// File: lib/features/home/complete_profile/models/user_profile_update_request.dart
// Purpose: Request payload for POST user/update-user-profile, sent as
// multipart/form-data because it may include a new profile photo.
//
// Keys match the get-user-profile response. The photo is only sent when a
// new one was picked; otherwise the backend keeps the stored one.

import 'dart:io';

import 'package:dio/dio.dart';

class UserProfileUpdateRequest {
  UserProfileUpdateRequest({
    required this.name,
    required this.email,
    required this.mobile,
    required this.gender,
    required this.dateOfBirth,
    required this.country,
    required this.state,
    required this.city,
    required this.pincode,
    required this.fullAddress,
    this.profileImage,
  });

  final String name;

  /// Optional on the form — sent empty when not given.
  final String email;
  final String mobile;

  /// `male` / `female` / `other`.
  final String gender;

  /// `yyyy-MM-dd`.
  final String dateOfBirth;
  final String country;
  final String state;
  final String city;
  final String pincode;
  final String fullAddress;
  final File? profileImage;

  Future<FormData> toFormData() async {
    final image = profileImage;
    return FormData.fromMap({
      'name': name,
      'email': email,
      'mobile': mobile,
      'gender': gender,
      'date_of_birth': dateOfBirth,
      'country': country,
      'state': state,
      'city': city,
      'pincode': pincode,
      'full_address': fullAddress,
      if (image != null) 'profile_image': await _imagePart(image),
    });
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
