// File: lib/features/home_main/home_main.dart
// Purpose: Main entry point screen after login/registration, featuring the primary navigation structure.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_images.dart';
import 'package:urban_services/core/constants/app_text_sizes.dart';
import 'package:urban_services/features/home_main/main_navigation_controller.dart';
import 'package:urban_services/features/home/home_screen.dart';
import 'package:urban_services/features/profile/profile_screen.dart';
import 'package:urban_services/widgets/custom_bottom_bar.dart';
import 'package:urban_services/widgets/custom_text_style.dart';

class HomeMain extends StatefulWidget {
  const HomeMain({super.key});

  @override
  State<HomeMain> createState() => _HomeMainState();
}

class _HomeMainState extends State<HomeMain> {
  // Navigation controller to manage active tab state
  final controller = Get.put(MainNavigationController());

  // List of screens corresponding to each navigation tab
  final List<Widget> _screens = [
    const Center(child: Text('Services')),
    const Center(child: Text('Booking')),
    const HomeScreen(),
    const Center(child: Text('Chat')),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: SafeArea(
        child: Stack(
          children: [
            // Current Screen Content based on selection
            Positioned.fill(
              child: SafeArea(
                bottom: false,
                child: Obx(() => _screens[controller.currentIndex.value]),
              ),
            ),

            // Standardized Custom Bottom Bar
            const Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: CustomBottomBar(),
            ),

            // Floating Central 'Home' Button
            Positioned(
              bottom:
                  AppDimensions.padding30h, // Aligned with the concave notch
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () => controller.changeIndex(2),
                  child: Container(
                    width: AppDimensions.containerWidth60w,
                    height: AppDimensions.containerHeight60h,
                    decoration: const BoxDecoration(
                      gradient: AppColors.gradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Home Icon
                        Image.asset(
                          AppImages.home,
                          width: AppDimensions.containerWidth24w,
                          height: AppDimensions.containerHeight24h,
                          color: AppColors.white,
                        ),
                        SizedBox(height: AppDimensions.padding2h),
                        // Tab Label
                        Text(
                          'Home',
                          style: customTextStyle(
                            AppTextSizes.stableTextSize,
                            AppColors.white,
                            FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
