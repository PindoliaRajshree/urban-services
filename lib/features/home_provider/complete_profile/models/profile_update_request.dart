// File: lib/features/home_provider/complete_profile/models/profile_update_request.dart
// Purpose: Request payload for POST provider/provide-profile/update. Built
// as multipart/form-data (rather than a plain JSON map) because the form
// includes file uploads — profile photo, Aadhaar front/back and an optional
// PAN card.

import 'dart:io';

import 'package:dio/dio.dart';

class ProfileUpdateRequest {
  ProfileUpdateRequest({
    required this.fullName,
    required this.mobileNumber,
    required this.gender,
    required this.dob,
    required this.serviceTypeId,
    required this.subServiceTypeId,
    required this.experienceYears,
    required this.description,
    required this.startingPrice,
    required this.perHourRate,
    required this.city,
    required this.area,
    required this.serviceRadius,
    required this.workType,
    required this.accountHolderName,
    required this.accountNumber,
    required this.ifscCode,
    required this.profileImage,
    required this.aadhaarFront,
    required this.aadhaarBack,
    this.email,
    this.perVisitRate,
    this.customPricing,
    this.upiId,
    this.panCard,
  });

  final String fullName;
  final String mobileNumber;
  final String? email;
  final String gender;
  final String dob;

  final int serviceTypeId;
  final int subServiceTypeId;
  final String experienceYears;
  final String description;

  final String startingPrice;
  final String perHourRate;
  final String? perVisitRate;
  final String? customPricing;

  final String city;
  final String area;
  final String serviceRadius;
  final String workType;

  final String accountHolderName;
  final String accountNumber;
  final String ifscCode;
  final String? upiId;

  final File profileImage;
  final File aadhaarFront;
  final File aadhaarBack;
  final File? panCard;

  Future<FormData> toFormData() async {
    final map = <String, dynamic>{
      'full_name': fullName,
      'mobile_number': mobileNumber,
      'gender': gender,
      'dob': dob,
      'service_type_id': serviceTypeId,
      'sub_service_type_id': subServiceTypeId,
      'experience_years': experienceYears,
      'description': description,
      'starting_price': startingPrice,
      'per_hour_rate': perHourRate,
      'city': city,
      'area': area,
      'service_radius': serviceRadius,
      'work_type': workType,
      'account_holder_name': accountHolderName,
      'account_number': accountNumber,
      'ifsc_code': ifscCode,
      'profile_image': await MultipartFile.fromFile(profileImage.path),
      'aadhaar_front': await MultipartFile.fromFile(aadhaarFront.path),
      'aadhaar_back': await MultipartFile.fromFile(aadhaarBack.path),
    };

    if (email != null && email!.trim().isNotEmpty) {
      map['email'] = email!.trim();
    }
    if (perVisitRate != null && perVisitRate!.trim().isNotEmpty) {
      map['per_visit_rate'] = perVisitRate!.trim();
    }
    if (customPricing != null && customPricing!.trim().isNotEmpty) {
      map['custom_pricing'] = customPricing!.trim();
    }
    if (upiId != null && upiId!.trim().isNotEmpty) {
      map['upi_id'] = upiId!.trim();
    }
    if (panCard != null) {
      map['pan_card'] = await MultipartFile.fromFile(panCard!.path);
    }

    return FormData.fromMap(map);
  }
}
