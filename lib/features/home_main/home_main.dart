// File: lib/features/home_main/home_main.dart
// Purpose: Main entry point screen after login/registration, featuring the primary navigation structure.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/features/authentication/login/login_controller.dart';
import 'package:urban_services/features/chat/chat_list_screen.dart';
import 'package:urban_services/features/home_main/main_navigation_controller.dart';
import 'package:urban_services/features/home/home_screen.dart';
import 'package:urban_services/features/home_provider/provider_home_screen.dart';
import 'package:urban_services/features/my_bookings/my_bookings_screen.dart';
import 'package:urban_services/features/profile/profile_screen.dart';
import 'package:urban_services/widgets/custom_bottom_bar.dart';

class HomeMain extends StatefulWidget {
  const HomeMain({super.key});

  @override
  State<HomeMain> createState() => _HomeMainState();
}

class _HomeMainState extends State<HomeMain> {
  // Navigation controller to manage active tab state
  final controller = Get.put(MainNavigationController());
  // Login controller to determine the user's role; ensure it exists
  late final LoginController loginController;

  @override
  void initState() {
    super.initState();
    // Safely retrieve or initialize the LoginController
    if (Get.isRegistered<LoginController>()) {
      loginController = Get.find<LoginController>();
    } else {
      loginController = Get.put(LoginController(), permanent: true);
    }
  }

  /// Returns the appropriate list of screens based on the current user role
  List<Widget> _getScreens() {
    return [
      const Center(child: Text('Services')),
      const MyBookingsScreen(),
      // Dynamically load the dashboard based on role
      loginController.userRole.value == 'Provider'
          ? const ProviderHomeScreen()
          : const HomeScreen(),
      const ChatListScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      resizeToAvoidBottomInset: false, // Prevents resizing which could break bottom bar
      body: SafeArea(
        child: Stack(
          children: [
            // Current Screen Content based on selection
            Positioned.fill(
              child: SafeArea(
                bottom: false,
                child: Obx(() {
                  final screens = _getScreens();
                  return screens[controller.currentIndex.value];
                }),
              ),
            ),

            // Standardized Custom Bottom Bar with integrated floating button
            if (!isKeyboardVisible)
              const Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: CustomBottomBar(),
              ),
          ],
        ),
      ),
    );
  }
}
