import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urban_services/core/constants/storage_keys.dart';
import 'package:urban_services/core/session/session_provider.dart';
import 'package:urban_services/core/session/token_store.dart';
import 'package:urban_services/core/session/user_role.dart';
import 'package:urban_services/features/authentication/login/models/login_response.dart';
import 'package:urban_services/features/authentication/register/models/register_response.dart';
import 'package:urban_services/shared_preferences/sharedpreference_helper.dart';

Map<String, dynamic> _payload({String? token}) => {
  'status': true,
  'message': 'ok',
  'data': {
    'token': ?token,
    'user': {
      'id': 3,
      'name': 'Asha',
      'email': 'asha@example.com',
      'mobile': '9876543210',
      'role': 'user',
    },
  },
};

void main() {
  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    await SharedPreferencesHelper.init();
    await TokenStore.init();
    container = ProviderContainer();
    // The helper caches its SharedPreferences instance across tests.
    await container.read(sessionProvider.notifier).logout();
  });

  tearDown(() => container.dispose());

  group('TokenStore', () {
    test(
      'moves a token saved by an older version into secure storage',
      () async {
        final prefs = SharedPreferencesHelper.instance.prefs;
        await prefs.setString(StorageKeys.authToken, 'legacy-token');

        await TokenStore.init();

        expect(TokenStore.instance.token, 'legacy-token');
        expect(prefs.getString(StorageKeys.authToken), isNull);
        expect(
          ProviderContainer().read(sessionProvider).isAuthenticated,
          isTrue,
        );
      },
    );

    test('clears a keychain token left over from a previous install', () async {
      final prefs = SharedPreferencesHelper.instance.prefs;
      await prefs.remove(StorageKeys.appInstalled);
      FlutterSecureStorage.setMockInitialValues({
        StorageKeys.authToken: 'old-install-token',
      });

      await TokenStore.init();

      expect(TokenStore.instance.token, isNull);
      expect(prefs.getBool(StorageKeys.appInstalled), isTrue);
    });
  });

  group('logout', () {
    test('clears the session but keeps device-level flags', () async {
      await container
          .read(sessionProvider.notifier)
          .saveLogin(LoginResponse.fromJson(_payload(token: 't1')));
      final prefs = SharedPreferencesHelper.instance.prefs;
      await prefs.setBool(StorageKeys.appInstalled, true);

      await container.read(sessionProvider.notifier).logout();

      expect(container.read(sessionProvider).isAuthenticated, isFalse);
      expect(TokenStore.instance.token, isNull);
      expect(prefs.getInt(StorageKeys.userId), isNull);
      expect(prefs.getBool(StorageKeys.appInstalled), isTrue);
    });
  });

  group('saveRegister', () {
    test('stores the full session, including the user ID', () async {
      final saved = await container
          .read(sessionProvider.notifier)
          .saveRegister(RegisterResponse.fromJson(_payload(token: 't1')));

      expect(saved, isTrue);
      final session = container.read(sessionProvider);
      expect(session.isAuthenticated, isTrue);
      expect(session.userId, 3);
      expect(session.name, 'Asha');
      expect(session.email, 'asha@example.com');
      expect(session.mobile, '9876543210');
      expect(session.role, UserRole.user);
    });

    test('returns false and saves nothing without a token', () async {
      final saved = await container
          .read(sessionProvider.notifier)
          .saveRegister(RegisterResponse.fromJson(_payload()));

      expect(saved, isFalse);
      final session = container.read(sessionProvider);
      expect(session.isAuthenticated, isFalse);
      expect(session.userId, isNull);
    });
  });

  group('saveLogin', () {
    test('stores the full session', () async {
      final saved = await container
          .read(sessionProvider.notifier)
          .saveLogin(LoginResponse.fromJson(_payload(token: 't1')));

      expect(saved, isTrue);
      expect(container.read(sessionProvider).userId, 3);
    });

    test('returns false and saves nothing without a token', () async {
      final saved = await container
          .read(sessionProvider.notifier)
          .saveLogin(LoginResponse.fromJson(_payload()));

      expect(saved, isFalse);
      expect(container.read(sessionProvider).isAuthenticated, isFalse);
    });
  });
}
