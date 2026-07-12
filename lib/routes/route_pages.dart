// File: lib/routes/route_pages.dart
// Purpose: Configures the GetX route mapping between names and screens.

import 'package:get/get.dart';
import 'package:urban_services/core/constants/app_images.dart';
import 'package:urban_services/features/authentication/login/login_screen.dart';
import 'package:urban_services/features/authentication/register/register_screen.dart';
import 'package:urban_services/features/authentication/forgot_password/forgot_password_screen.dart';
import 'package:urban_services/features/authentication/forgot_password/check_email_screen.dart';
import 'package:urban_services/features/authentication/forgot_password/reset_password_screen.dart';
import 'package:urban_services/features/authentication/splash/splash_screen.dart';
import 'package:urban_services/features/authentication/splash/welcome_screen.dart';
import 'package:urban_services/features/home_main/home_main.dart';
import 'package:urban_services/features/address/address_screen.dart';
import 'package:urban_services/features/address/add_address_screen.dart';
import 'package:urban_services/features/home_provider/complete_profile/complete_profile_screen.dart';
import 'package:urban_services/features/home_provider/provider_home_screen.dart';
import 'package:urban_services/features/notification/notification_screen.dart';
import 'package:urban_services/features/chat/chat_screen.dart';
import 'package:urban_services/features/chat/chat_search_screen.dart';
import 'package:urban_services/features/my_bookings/my_bookings_screen.dart';
import 'package:urban_services/routes/route_names.dart';

List<GetPage> getRoutes() {
  return [
    GetPage(name: RouteNames.splashScreen, page: () => const SplashScreen()),
    GetPage(name: RouteNames.welcomeScreen, page: () => const WelcomeScreen()),
    GetPage(name: RouteNames.loginScreen, page: () => const LoginScreen()),
    GetPage(
      name: RouteNames.forgotPasswordScreen,
      page: () => const ForgotPasswordScreen(),
    ),
    GetPage(
      name: RouteNames.checkEmailScreen,
      page: () => const CheckEmailScreen(),
    ),
    GetPage(
      name: RouteNames.resetPasswordScreen,
      page: () => const ResetPasswordScreen(),
    ),
    GetPage(
      name: RouteNames.registerScreen,
      page: () => const RegisterScreen(),
    ),
    GetPage(name: RouteNames.homeMain, page: () => const HomeMain()),
    GetPage(
      name: RouteNames.providerHomeScreen,
      page: () => const ProviderHomeScreen(),
    ),
    GetPage(
      name: RouteNames.completeProviderProfile,
      page: () => const CompleteProfileScreen(),
    ),
    GetPage(name: RouteNames.addressScreen, page: () => const AddressScreen()),
    GetPage(
      name: RouteNames.addAddressScreen,
      page: () => const AddAddressScreen(),
    ),
    GetPage(
      name: RouteNames.notificationScreen,
      page: () => const NotificationScreen(),
    ),
    GetPage(
      name: RouteNames.chatScreen,
      page: () {
        final args = Get.arguments as Map<String, dynamic>? ?? {};
        return ChatScreen(
          name: args['name'] as String? ?? 'Devon Lane',
          avatar: args['avatar'] as String? ?? AppImages.serviceProvider,
          status: args['status'] as String? ?? 'Online',
        );
      },
    ),
    GetPage(
      name: RouteNames.chatSearchScreen,
      page: () => const ChatSearchScreen(),
    ),
    GetPage(
      name: RouteNames.myBookingsScreen,
      page: () => const MyBookingsScreen(),
    ),
  ];
}
