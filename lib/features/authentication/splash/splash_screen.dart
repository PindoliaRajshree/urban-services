// File: lib/features/authentication/splash/splash_screen.dart
// Purpose: Initial animated entry screen. Routes to Home directly when a
// session is already stored (persistent login — the user stays logged in
// until they manually log out), otherwise transitions to Welcome.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_images.dart';
import 'package:urban_services/core/constants/storage_keys.dart';
import 'package:urban_services/features/authentication/login/login_controller.dart';
import 'package:urban_services/routes/route_names.dart';
import 'package:urban_services/shared_preferences/sharedpreference_helper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  /// Controller to manage the timing of all animations
  late AnimationController _controller;

  /// Handles the elastic scaling effect of the logo
  late Animation<double> _scaleAnimation;

  /// Handles the smooth fade-in of the logo
  late Animation<double> _fadeAnimation;

  /// Handles the slide-up movement of the logo
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Initial logo pop-in with a bouncy elastic effect
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
    );

    // Initial opacity transition from transparent to visible
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    );

    // Logo slides up from 30% below its target position
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.0, 0.7, curve: Curves.easeInBack),
          ),
        );

    // Start the animation sequence
    _controller.forward();

    // After the intro animation, route straight into the app if a session
    // is already stored (persistent login), otherwise start at Welcome.
    Future.delayed(const Duration(seconds: 3), _routeAfterSplash);
  }

  /// Checks for a stored auth token and, if present, restores the saved
  /// role onto the shared LoginController and goes straight to Home —
  /// keeping the user logged in until they manually log out. Otherwise
  /// falls back to the Welcome screen.
  Future<void> _routeAfterSplash() async {
    final token = await SharedPreferencesHelper.instance.getValue<String>(
      StorageKeys.authToken,
    );

    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      final savedRole = await SharedPreferencesHelper.instance
          .getValue<String>(StorageKeys.userRole);

      final loginController = Get.isRegistered<LoginController>()
          ? Get.find<LoginController>()
          : Get.put(LoginController(), permanent: true);
      if (savedRole != null && savedRole.isNotEmpty) {
        loginController.setRole(savedRole);
      }

      if (!mounted) return;
      Get.offAllNamed(RouteNames.homeMain);
    } else {
      Get.offAllNamed(RouteNames.welcomeScreen);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // Immersive gradient
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(gradient: AppColors.gradient),
          child: SafeArea(
            child: Center(
              child: SlideTransition(
                position: _slideAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Image.asset(
                      AppImages.splash,
                      width: AppDimensions.containerWidth200w,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
