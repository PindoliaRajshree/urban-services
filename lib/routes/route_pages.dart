// File: lib/routes/route_pages.dart
// Purpose: Configures the GetX route mapping between names and screens.

import 'package:get/get.dart';
import 'package:urban_services/features/authentication/login/login_screen.dart';
import 'package:urban_services/features/authentication/register/register_screen.dart';
import 'package:urban_services/features/authentication/splash/splash_screen.dart';
import 'package:urban_services/features/authentication/splash/welcome_screen.dart';
import 'package:urban_services/features/home_main/home_main.dart';
import 'package:urban_services/routes/route_names.dart';

List<GetPage> getRoutes() {
  return [
    GetPage(name: RouteNames.splashScreen, page: () => const SplashScreen()),
    GetPage(name: RouteNames.welcomeScreen, page: () => const WelcomeScreen()),
    GetPage(name: RouteNames.loginScreen, page: () => const LoginScreen()),
    GetPage(name: RouteNames.registerScreen, page: () => const RegisterScreen()),
    GetPage(name: RouteNames.homeMain, page: () => const HomeMain()),
  ];
}