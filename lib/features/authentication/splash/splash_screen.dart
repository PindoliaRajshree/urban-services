// File: lib/features/authentication/splash/splash_screen.dart
// Purpose: Initial animated entry screen. Routes to Home directly when a
// session is already stored (persistent login — the user stays logged in
// until they manually log out), otherwise transitions to Welcome.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_images.dart';
import 'package:urban_services/core/session/session_provider.dart';
import 'package:urban_services/routes/route_names.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
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

  /// If a session is stored (sessionProvider restores token + role from
  /// storage), go straight to Home — keeping the user logged in until they
  /// manually log out. Otherwise fall back to the Welcome screen.
  void _routeAfterSplash() {
    if (!mounted) return;

    if (ref.read(sessionProvider).isAuthenticated) {
      context.go(RouteNames.homeMain);
    } else {
      context.go(RouteNames.welcomeScreen);
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
