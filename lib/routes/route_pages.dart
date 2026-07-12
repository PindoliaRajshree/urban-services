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
import 'package:urban_services/features/service_category/service_category_screen.dart';
import 'package:urban_services/features/service_details/service_details_screen.dart';
import 'package:urban_services/features/booking_service/booking_service_screen.dart';
import 'package:urban_services/features/payment/payment_screen.dart';
import 'package:urban_services/features/payment_success/payment_success_screen.dart';
import 'package:urban_services/features/live_tracking/live_tracking_screen.dart';
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
    GetPage(
      name: RouteNames.serviceCategoryScreen,
      page: () {
        final args = Get.arguments as Map<String, dynamic>? ?? {};
        return ServiceCategoryScreen(
          categoryTitle: args['categoryTitle'] as String? ?? 'Cleaning Service',
          serviceCount: args['serviceCount'] as String? ?? '30+ Services',
        );
      },
    ),
    GetPage(
      name: RouteNames.serviceDetailsScreen,
      page: () {
        final args = Get.arguments as Map<String, dynamic>? ?? {};
        return ServiceDetailsScreen(
          imagePath: args['imagePath'] as String? ?? AppImages.serviceDeep,
          reviewCount: args['reviewCount'] as String? ?? '256',
          price: args['price'] as String? ?? '699',
          duration: args['duration'] as String? ?? '2-3 Hours',
          includes:
              args['includes'] as List<String>? ??
              const [
                'Full home deep cleaning',
                'Dusting all areas',
                'Floor cleaning & mopping',
                'Kitchen platform cleaning',
                'Bathroom sanitization',
              ],
        );
      },
    ),
    GetPage(
      name: RouteNames.bookingServiceScreen,
      page: () {
        final args = Get.arguments as Map<String, dynamic>? ?? {};
        return BookingServiceScreen(
          price: args['price'] as String? ?? '699',
        );
      },
    ),
    GetPage(
      name: RouteNames.paymentScreen,
      page: () {
        final args = Get.arguments as Map<String, dynamic>? ?? {};
        return PaymentScreen(
          price: args['price'] as String? ?? '699',
          dateTime:
              args['dateTime'] as String? ?? '20 May 2024, 11:00 AM',
          address:
              args['address'] as String? ??
              '123, Green Park, Main Road, New Delhi-110016',
        );
      },
    ),
    GetPage(
      name: RouteNames.paymentSuccessScreen,
      page: () {
        final args = Get.arguments as Map<String, dynamic>? ?? {};
        return PaymentSuccessScreen(
          bookingId: args['bookingId'] as String? ?? 'US123456789',
          serviceName: args['serviceName'] as String? ?? 'Deep Cleaning',
          dateTime:
              args['dateTime'] as String? ?? '20 May 2024, 11:00 AM',
          address:
              args['address'] as String? ??
              '123, Green Park, Main Road, New Delhi-110016',
        );
      },
    ),
    GetPage(
      name: RouteNames.liveTrackingScreen,
      page: () {
        final args = Get.arguments as Map<String, dynamic>? ?? {};
        return LiveTrackingScreen(
          bookingId: args['bookingId'] as String? ?? 'US123456789',
          serviceName: args['serviceName'] as String? ?? 'Deep Cleaning',
          dateTime:
              args['dateTime'] as String? ?? '20 May 2024, 11:00 AM',
        );
      },
    ),
  ];
}
