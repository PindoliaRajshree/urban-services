// File: lib/routes/app_router.dart
// Purpose: go_router configuration — replaces GetX's getPages/initialRoute.
//
// Redirect rules:
// - Auth: once the session ends — manual logout or a 401 from the backend
//   (see AuthInterceptor) — any protected screen sends the user to Welcome.
// - Role: provider-only and user-only screens send the other role to
//   HomeMain.
// Everything else (splash → home/welcome, post-login role routing) is
// decided by the screens themselves.

import 'package:flutter/foundation.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:urban_services/core/navigation/app_keys.dart';
import 'package:urban_services/core/session/session_provider.dart';
import 'package:urban_services/features/address/add_address_screen.dart';
import 'package:urban_services/features/address/address_repository.dart';
import 'package:urban_services/features/address/address_screen.dart';
import 'package:urban_services/features/address/full_screen_map_picker.dart';
import 'package:urban_services/features/address/models/service_address_response.dart';
import 'package:urban_services/features/authentication/forgot_password/check_email_screen.dart';
import 'package:urban_services/features/authentication/forgot_password/forgot_password_screen.dart';
import 'package:urban_services/features/authentication/forgot_password/reset_password_screen.dart';
import 'package:urban_services/features/authentication/login/login_screen.dart';
import 'package:urban_services/features/authentication/register/register_screen.dart';
import 'package:urban_services/features/authentication/splash/splash_screen.dart';
import 'package:urban_services/features/authentication/splash/welcome_screen.dart';
import 'package:urban_services/features/booking_service/booking_service_screen.dart';
import 'package:urban_services/features/chat/chat_screen.dart';
import 'package:urban_services/features/chat/chat_search_screen.dart';
import 'package:urban_services/features/home/complete_profile/user_complete_profile_screen.dart';
import 'package:urban_services/features/home_main/home_main.dart';
import 'package:urban_services/features/home_provider/complete_profile/complete_profile_screen.dart';
import 'package:urban_services/features/home_provider/complete_profile/provider_profile_view_screen.dart';
import 'package:urban_services/features/home_provider/provider_home_screen.dart';
import 'package:urban_services/features/live_tracking/live_tracking_screen.dart';
import 'package:urban_services/features/my_bookings/my_bookings_screen.dart';
import 'package:urban_services/features/notification/notification_screen.dart';
import 'package:urban_services/features/payment/payment_screen.dart';
import 'package:urban_services/features/payment_success/payment_success_screen.dart';
import 'package:urban_services/features/service_category/service_category_screen.dart';
import 'package:urban_services/features/service_details/service_details_screen.dart';
import 'package:urban_services/routes/route_args.dart';
import 'package:urban_services/routes/route_names.dart';

/// Screens reachable without a session.
const _publicRoutes = {
  RouteNames.splashScreen,
  RouteNames.welcomeScreen,
  RouteNames.loginScreen,
  RouteNames.registerScreen,
  RouteNames.forgotPasswordScreen,
  RouteNames.checkEmailScreen,
  RouteNames.resetPasswordScreen,
};

/// Screens only providers may open.
const _providerOnlyRoutes = {
  RouteNames.completeProviderProfile,
  RouteNames.providerProfileView,
  RouteNames.providerHomeScreen,
};

/// Screens only users (customers) may open: address setup and the booking
/// flow.
const _userOnlyRoutes = {
  RouteNames.completeProfile,
  RouteNames.addressScreen,
  RouteNames.addAddressScreen,
  RouteNames.mapPicker,
  RouteNames.serviceCategoryScreen,
  RouteNames.serviceDetailsScreen,
  RouteNames.bookingServiceScreen,
  RouteNames.paymentScreen,
  RouteNames.paymentSuccessScreen,
  RouteNames.liveTrackingScreen,
};

/// The redirect rules (see the file header): where to send a navigation to
/// [location], or null to allow it.
@visibleForTesting
String? appRedirect(
  String location, {
  required bool isAuthenticated,
  required bool isProvider,
}) {
  if (!isAuthenticated) {
    return _publicRoutes.contains(location) ? null : RouteNames.welcomeScreen;
  }
  final blocked = isProvider
      ? _userOnlyRoutes.contains(location)
      : _providerOnlyRoutes.contains(location);
  return blocked ? RouteNames.homeMain : null;
}

/// Where to send someone who has just logged in (or signed up with
/// Google): providers go to Home; users go to Home when they already have
/// a saved address, otherwise to the Address screen first. Matches what a
/// restart does, where Splash sends a logged-in user straight to Home.
Future<String> postLoginRoute(Ref ref) async {
  if (ref.read(sessionProvider).effectiveRole.isProvider) {
    return RouteNames.homeMain;
  }
  final hasAddress = await ref
      .read(addressRepositoryProvider)
      .hasServiceAddress();
  return hasAddress ? RouteNames.homeMain : RouteNames.addressScreen;
}

final routerProvider = Provider<GoRouter>((ref) {
  // Re-run redirect only when logged-in/out flips, not on every session
  // field change.
  final authListenable = ValueNotifier<bool>(
    ref.read(sessionProvider).isAuthenticated,
  );
  ref.listen(
    sessionProvider.select((s) => s.isAuthenticated),
    (_, next) => authListenable.value = next,
  );

  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: RouteNames.splashScreen,
    debugLogDiagnostics: kDebugMode,
    refreshListenable: authListenable,
    redirect: (context, state) {
      final isAuthenticated = authListenable.value;
      return appRedirect(
        state.matchedLocation,
        isAuthenticated: isAuthenticated,
        isProvider: ref.read(sessionProvider).effectiveRole.isProvider,
      );
    },
    routes: [
      GoRoute(
        path: RouteNames.splashScreen,
        builder: (_, _) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.welcomeScreen,
        builder: (_, _) => const WelcomeScreen(),
      ),
      GoRoute(
        path: RouteNames.loginScreen,
        builder: (_, _) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.forgotPasswordScreen,
        builder: (_, _) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: RouteNames.checkEmailScreen,
        builder: (_, _) => const CheckEmailScreen(),
      ),
      GoRoute(
        path: RouteNames.resetPasswordScreen,
        builder: (_, _) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: RouteNames.registerScreen,
        builder: (_, _) => const RegisterScreen(),
      ),
      GoRoute(path: RouteNames.homeMain, builder: (_, _) => const HomeMain()),
      GoRoute(
        path: RouteNames.completeProfile,
        builder: (_, _) => const UserCompleteProfileScreen(),
      ),
      GoRoute(
        path: RouteNames.providerHomeScreen,
        builder: (_, _) => const ProviderHomeScreen(),
      ),
      GoRoute(
        path: RouteNames.completeProviderProfile,
        // No args (first-time completion) opens on the first page.
        builder: (_, state) => CompleteProfileScreen(
          initialStep:
              (state.extra as ProviderProfileEditArgs?)?.initialStep ?? 0,
        ),
      ),
      GoRoute(
        path: RouteNames.providerProfileView,
        builder: (_, _) => const ProviderProfileViewScreen(),
      ),
      GoRoute(
        path: RouteNames.addressScreen,
        builder: (_, state) =>
            AddressScreen(manage: _extra(state, const AddressArgs()).manage),
      ),
      GoRoute(
        path: RouteNames.addAddressScreen,
        builder: (_, state) => AddAddressScreen(
          initialAddress: state.extra as ServiceAddressResponse?,
        ),
      ),
      GoRoute(
        path: RouteNames.mapPicker,
        builder: (_, state) =>
            FullScreenMapPicker(initialPosition: state.extra as LatLng?),
      ),
      GoRoute(
        path: RouteNames.notificationScreen,
        builder: (_, _) => const NotificationScreen(),
      ),
      GoRoute(
        path: RouteNames.chatScreen,
        builder: (_, state) {
          final args = _extra(state, const ChatArgs());
          return ChatScreen(
            name: args.name,
            avatar: args.avatar,
            status: args.status,
          );
        },
      ),
      GoRoute(
        path: RouteNames.chatSearchScreen,
        builder: (_, _) => const ChatSearchScreen(),
      ),
      GoRoute(
        path: RouteNames.myBookingsScreen,
        builder: (_, _) => const MyBookingsScreen(),
      ),
      GoRoute(
        path: RouteNames.serviceCategoryScreen,
        builder: (_, state) {
          final args = _extra(state, const ServiceCategoryArgs());
          return ServiceCategoryScreen(
            categoryTitle: args.categoryTitle,
            serviceCount: args.serviceCount,
          );
        },
      ),
      GoRoute(
        path: RouteNames.serviceDetailsScreen,
        builder: (_, state) {
          final args = _extra(state, const ServiceDetailsArgs());
          return ServiceDetailsScreen(
            imagePath: args.imagePath,
            reviewCount: args.reviewCount,
            price: args.price,
            duration: args.duration,
            includes: args.includes,
          );
        },
      ),
      GoRoute(
        path: RouteNames.bookingServiceScreen,
        builder: (_, state) => BookingServiceScreen(
          price: _extra(state, const BookingArgs()).price,
        ),
      ),
      GoRoute(
        path: RouteNames.paymentScreen,
        builder: (_, state) {
          final args = _extra(state, const PaymentArgs());
          return PaymentScreen(
            price: args.price,
            dateTime: args.dateTime,
            address: args.address,
          );
        },
      ),
      GoRoute(
        path: RouteNames.paymentSuccessScreen,
        builder: (_, state) {
          final args = _extra(state, const PaymentSuccessArgs());
          return PaymentSuccessScreen(
            bookingId: args.bookingId,
            serviceName: args.serviceName,
            dateTime: args.dateTime,
            address: args.address,
          );
        },
      ),
      GoRoute(
        path: RouteNames.liveTrackingScreen,
        builder: (_, state) {
          final args = _extra(state, const LiveTrackingArgs());
          return LiveTrackingScreen(
            bookingId: args.bookingId,
            serviceName: args.serviceName,
            dateTime: args.dateTime,
          );
        },
      ),
    ],
  );

  ref.onDispose(() {
    router.dispose();
    authListenable.dispose();
  });
  return router;
});

/// The route's typed `extra`, or [fallback] when the caller didn't pass one.
/// The fallbacks are placeholder data (see route_args.dart), so a missing
/// argument is logged in debug builds to catch callers that forget it.
T _extra<T>(GoRouterState state, T fallback) {
  final extra = state.extra;
  if (extra is T) return extra;
  debugPrint(
    'Missing route args ($T) for ${state.matchedLocation}; using defaults.',
  );
  return fallback;
}
