import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urban_services/core/network/api_result.dart';
import 'package:urban_services/core/session/token_store.dart';
import 'package:urban_services/features/home_provider/complete_profile/complete_profile_provider.dart';
import 'package:urban_services/features/home_provider/complete_profile/complete_profile_repository.dart';
import 'package:urban_services/features/home_provider/complete_profile/models/provider_profile.dart';
import 'package:urban_services/shared_preferences/sharedpreference_helper.dart';

class _FakeRepository extends CompleteProfileRepository {
  _FakeRepository(this.provider) : super(Dio());

  final Map<String, dynamic> provider;

  @override
  Future<ApiResult<ProviderProfile?>> fetchProfile() async => ApiSuccess(
    ProviderProfile.fromJson({
      'data': {'user': <String, dynamic>{}, 'provider': provider},
    }),
  );
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    await SharedPreferencesHelper.init();
    await TokenStore.init();
  });

  Future<ProviderProfileNotifier> load(Map<String, dynamic> provider) async {
    final container = ProviderContainer(
      overrides: [
        completeProfileRepositoryProvider.overrideWithValue(
          _FakeRepository(provider),
        ),
      ],
    );
    addTearDown(container.dispose);
    // Keep the autoDispose provider alive for the test.
    container.listen(providerProfileProvider, (_, _) {});
    final notifier = container.read(providerProfileProvider.notifier);
    await notifier.loadInitial();
    return notifier;
  }

  test('saved Aadhaar and PAN are locked and cannot be removed', () async {
    final notifier = await load({
      'aadhaar_number': '123412341234',
      'aadhaar_front_image': 'provider/documents/front.jpg',
      'aadhaar_back_image': 'provider/documents/back.jpg',
      'pan_number': 'ABCDE1234F',
      'pan_image': 'provider/documents/pan.jpg',
    });

    expect(notifier.state.isAadhaarLocked, isTrue);
    expect(notifier.state.isPanLocked, isTrue);

    notifier.removeDocument('aadhaarFront');
    notifier.removeDocument('aadhaarBack');
    notifier.removeDocument('pan');
    // Picking is ignored too (returns before opening the picker).
    await notifier.pickPhotoFor('pan', ImageSource.gallery);

    final s = notifier.state;
    expect(s.adhaarFrontUrl, isNotNull);
    expect(s.adhaarBackUrl, isNotNull);
    expect(s.panCardUrl, isNotNull);
    expect(s.aadhaarNumber, '123412341234');
    expect(s.panNumber, 'ABCDE1234F');
  });

  test('locks each document separately', () async {
    final notifier = await load({
      'aadhaar_number': '123412341234',
      'aadhaar_front_image': 'provider/documents/front.jpg',
    });

    expect(notifier.state.isAadhaarLocked, isTrue);
    expect(notifier.state.isPanLocked, isFalse);
  });

  test('nothing is locked without saved documents', () async {
    final notifier = await load({'aadhaar_number': null, 'pan_number': ''});

    expect(notifier.state.isAadhaarLocked, isFalse);
    expect(notifier.state.isPanLocked, isFalse);
  });
}
