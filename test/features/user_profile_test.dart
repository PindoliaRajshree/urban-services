import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:urban_services/features/home/complete_profile/models/user_profile.dart';
import 'package:urban_services/features/home/complete_profile/models/user_profile_update_request.dart';
import 'package:urban_services/features/home/complete_profile/user_profile_view_screen.dart';
import 'package:urban_services/features/home_provider/complete_profile/models/provider_profile.dart';
import 'package:urban_services/routes/route_names.dart';

void main() {
  group('UserProfile.fromJson', () {
    test('parses the live POST user/get-user-profile response', () {
      const photo =
          'https://bhavishyodayinstitute.com/bhavishyodayinstitute2/'
          'UrbanService%20Project/public/storage/provider/documents/x.jpg';
      final profile = UserProfile.fromJson({
        'status': true,
        'message': 'User profile fetched successfully',
        'data': {
          'id': 32,
          'name': 'balaji',
          'email': 'abhay@gmail.com',
          'mobile': '9617527176',
          'login_type': 'manual',
          'profile_image': photo,
          'role': 'provider',
          'date_of_birth': null,
          'gender': null,
          'country': null,
          'state': null,
          'city': null,
          'pincode': null,
          'full_address': null,
          'is_mobile_verified': false,
          'mobile_verified_at': null,
          'email_verified_at': null,
          'status': 'active',
        },
      });

      expect(profile.name, 'balaji');
      expect(profile.email, 'abhay@gmail.com');
      expect(profile.mobile, '9617527176');
      expect(profile.isMobileVerified, isFalse);
      expect(profile.dateOfBirth, isNull);
      expect(profile.isProfileCompleted, isFalse);
      expect(ProviderProfile.fileUrl(profile.profileImage), photo);
      expect(userProfileRoute(profile), RouteNames.completeProfile);
    });

    test('is complete once every required field is saved', () {
      final profile = UserProfile.fromJson({
        'data': {
          'gender': 'Female',
          'date_of_birth': '1995-02-01T00:00:00.000000Z',
          'country': 'India',
          'state': 'Madhya Pradesh',
          'city': 'Indore',
          'pincode': 452003,
          'full_address': '12, MG Road',
          'is_mobile_verified': 1,
        },
      });

      expect(profile.gender, 'female');
      expect(profile.dateOfBirth, DateTime(1995, 2, 1));
      expect(profile.pincode, '452003');
      expect(profile.isMobileVerified, isTrue);
      expect(profile.isProfileCompleted, isTrue);
      expect(userProfileRoute(profile), RouteNames.userProfileView);
    });

    test('blank values count as missing', () {
      final profile = UserProfile.fromJson({
        'data': {'name': '  ', 'city': ''},
      });
      expect(profile.name, isNull);
      expect(profile.city, isNull);
    });
  });

  group('UserProfileUpdateRequest.toFormData', () {
    UserProfileUpdateRequest request({File? profileImage}) =>
        UserProfileUpdateRequest(
          name: 'balaji',
          email: '',
          mobile: '9617527176',
          gender: 'male',
          dateOfBirth: '1995-02-01',
          country: 'India',
          state: 'Madhya Pradesh',
          city: 'Indore',
          pincode: '452003',
          fullAddress: '12, MG Road',
          profileImage: profileImage,
        );

    test('sends exactly the backend keys', () async {
      final form = await request().toFormData();
      expect(form.fields.map((e) => e.key).toSet(), {
        'name',
        'email',
        'mobile',
        'gender',
        'date_of_birth',
        'country',
        'state',
        'city',
        'pincode',
        'full_address',
      });
      // No new photo picked: the stored one is kept.
      expect(form.files, isEmpty);
    });

    test('attaches a picked photo with name and content type', () async {
      final dir = await Directory.systemTemp.createTemp('user_profile_test');
      final file = File('${dir.path}/photo.jpg')..writeAsBytesSync([0]);
      addTearDown(() => dir.delete(recursive: true));

      final form = await request(profileImage: file).toFormData();
      final part = form.files.single;
      expect(part.key, 'profile_image');
      expect(part.value.filename, 'photo.jpg');
      expect(part.value.contentType.toString(), 'image/jpeg');
    });
  });
}
