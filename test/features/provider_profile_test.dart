import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:urban_services/core/constants/api_constants.dart';
import 'package:urban_services/features/home_provider/complete_profile/models/profile_update_request.dart';
import 'package:urban_services/features/home_provider/complete_profile/models/provider_profile.dart';

void main() {
  group('ProviderProfile.fromJson', () {
    test('parses the live GET provider/provider-profile response', () {
      final profile = ProviderProfile.fromJson({
        'status': true,
        'message': 'Provider profile fetched successfully',
        'data': {
          'user': {
            'id': 15,
            'name': 'abhay',
            'email': 'abhay@gmail.com',
            'mobile_number': null,
          },
          'provider': {
            'experience_years': 1,
            'gender': 'male',
            'date_of_birth': '1995-02-01 00:00:00.000',
            'service_types': '1',
            'sub_service_types': 2,
            'pricing_type': 'per_hour',
            'starting_price': '5.00',
            'service_area_km': 10,
            'availability_type': 'full_time',
            'team_size': 11,
            'latitude': '12.00000000',
            'longitude': '11.00000000',
            'profile_image': 'provider/documents/p.jpg',
            'mobile_number': '9617527178',
            'is_profile_completed': true,
          },
        },
      });

      expect(profile.name, 'abhay');
      expect(profile.experienceYears, 1);
      expect(profile.dateOfBirth, DateTime(1995, 2, 1));
      expect(profile.serviceTypeId, 1);
      expect(profile.subServiceTypeId, 2);
      expect(profile.startingPrice, '5');
      expect(profile.serviceAreaKm, 10);
      expect(profile.teamSize, 11);
      expect(profile.latitude, 12.0);
      expect(profile.preferredMobile, '9617527178');
      expect(profile.isProfileCompleted, isTrue);
      expect(
        ProviderProfile.fileUrl(profile.profileImage),
        '${ApiConstants.storageBaseUrl}provider/documents/p.jpg',
      );
    });

    test('update-response string types parse the same way', () {
      final profile = ProviderProfile.fromJson({
        'data': {
          'user': {'mobile': '9000000000'},
          'provider': {
            'experience_years': '1',
            'service_area_km': '10',
            'starting_price': '5',
            'is_profile_completed': false,
          },
        },
      });
      expect(profile.experienceYears, 1);
      expect(profile.serviceAreaKm, 10);
      expect(profile.startingPrice, '5');
      expect(profile.preferredMobile, '9000000000');
      expect(profile.isProfileCompleted, isFalse);
    });
  });

  group('ProfileUpdateRequest.toFormData', () {
    ProfileUpdateRequest request({File? profileImage}) => ProfileUpdateRequest(
      mobileNumber: '9617527178',
      email: 'abhay@gmail.com',
      gender: 'male',
      dateOfBirth: '1995-02-01',
      serviceTypeId: 1,
      subServiceTypeId: 2,
      experienceYears: 1,
      bio: 'bio',
      pricingType: 'per_hour',
      startingPrice: '5',
      address: 'indore',
      city: 'indore',
      state: 'Madhya pradesh',
      pincode: '452003',
      latitude: 12,
      longitude: 11,
      serviceAreaKm: 10,
      availabilityType: 'full_time',
      teamSize: 11,
      aadhaarNumber: '123412341234',
      accountHolderName: 'dsd',
      bankName: 'SBI',
      accountNumber: '1212121212',
      ifscCode: 'SBIN0001234',
      profileImage: profileImage,
      upiId: 'upi@ok',
    );

    test('sends exactly the backend keys', () async {
      final form = await request().toFormData();
      final keys = form.fields.map((e) => e.key).toSet();
      expect(keys, {
        'mobile_number',
        'email',
        'gender',
        'date_of_birth',
        'service_types',
        'sub_service_types',
        'experience_years',
        'bio',
        'pricing_type',
        'starting_price',
        'address',
        'city',
        'state',
        'pincode',
        'latitude',
        'longitude',
        'service_area_km',
        'availability_type',
        'team_size',
        'aadhaar_number',
        'account_holder_name',
        'bank_name',
        'account_number',
        'ifsc_code',
      });
      // Unchanged documents aren't re-sent.
      expect(form.files, isEmpty);

      // Coordinates go out as plain decimals, never exponent form.
      String field(String key) =>
          form.fields.firstWhere((e) => e.key == key).value;
      expect(field('latitude'), '12.00000000');
      expect(field('longitude'), '11.00000000');
    });

    test('attaches a picked image with name and content type', () async {
      final dir = await Directory.systemTemp.createTemp('profile_test');
      final file = File('${dir.path}/photo.png')..writeAsBytesSync([0]);
      addTearDown(() => dir.delete(recursive: true));

      final form = await request(profileImage: file).toFormData();
      final part = form.files.single;
      expect(part.key, 'profile_image');
      expect(part.value.filename, 'photo.png');
      expect(part.value.contentType.toString(), 'image/png');
    });
  });
}
