// File: lib/routes/route_pages.dart
// Purpose: Configures the GetX route mapping between names and screens.

import 'package:get/get.dart';
import 'package:urban_services/features/authentication/splash/splash_screen.dart';
import 'package:urban_services/features/authentication/splash/welcome_screen.dart';
import 'package:urban_services/routes/route_names.dart';

List<GetPage> getRoutes() {
  return [
    GetPage(name: RouteNames.splashScreen, page: () => const SplashScreen()),
    GetPage(name: RouteNames.welcomeScreen, page: () => const WelcomeScreen()),
    // GetPage(name: Routes.loginScreen, page: () => const LoginScreen()),
    // GetPage(name: Routes.registerScreen, page: () => const RegisterScreen()),
    // GetPage(name: Routes.homeScreen, page: () => const HomeScreen()),
  ];
}