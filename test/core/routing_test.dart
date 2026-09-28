import 'package:flutter_test/flutter_test.dart';
import 'package:urban_services/core/session/user_role.dart';
import 'package:urban_services/routes/app_router.dart';
import 'package:urban_services/routes/route_names.dart';

void main() {
  group('appRedirect', () {
    test('logged out: protected screens go to Welcome, public ones stay', () {
      expect(
        appRedirect(
          RouteNames.homeMain,
          isAuthenticated: false,
          isProvider: false,
        ),
        RouteNames.welcomeScreen,
      );
      expect(
        appRedirect(
          RouteNames.loginScreen,
          isAuthenticated: false,
          isProvider: false,
        ),
        isNull,
      );
    });

    test('a provider cannot open user-only screens', () {
      for (final route in [
        RouteNames.addressScreen,
        RouteNames.bookingServiceScreen,
        RouteNames.completeProfile,
      ]) {
        expect(
          appRedirect(route, isAuthenticated: true, isProvider: true),
          RouteNames.homeMain,
          reason: route,
        );
      }
      expect(
        appRedirect(
          RouteNames.completeProviderProfile,
          isAuthenticated: true,
          isProvider: true,
        ),
        isNull,
      );
    });

    test('a user cannot open provider-only screens', () {
      expect(
        appRedirect(
          RouteNames.completeProviderProfile,
          isAuthenticated: true,
          isProvider: false,
        ),
        RouteNames.homeMain,
      );
      expect(
        appRedirect(
          RouteNames.addressScreen,
          isAuthenticated: true,
          isProvider: false,
        ),
        isNull,
      );
    });

    test('shared screens are open to both roles', () {
      for (final isProvider in [true, false]) {
        expect(
          appRedirect(
            RouteNames.homeMain,
            isAuthenticated: true,
            isProvider: isProvider,
          ),
          isNull,
        );
        expect(
          appRedirect(
            RouteNames.chatScreen,
            isAuthenticated: true,
            isProvider: isProvider,
          ),
          isNull,
        );
      }
    });
  });

  group('roleMismatchMessage', () {
    test('is null when the roles match or the role is unknown', () {
      expect(roleMismatchMessage(UserRole.user, UserRole.user), isNull);
      expect(roleMismatchMessage(UserRole.provider, null), isNull);
    });

    test('names the account role when they differ', () {
      expect(
        roleMismatchMessage(UserRole.provider, UserRole.user),
        "This account is registered as a User, so you're continuing as a "
        "User.",
      );
    });
  });
}
