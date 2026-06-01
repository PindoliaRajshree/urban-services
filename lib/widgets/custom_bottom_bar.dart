import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_images.dart';
import 'package:urban_services/features/home_main/main_navigation_controller.dart';
import 'package:urban_services/widgets/concave_bottom_bar_painter.dart';
import 'package:urban_services/widgets/custom_text_style.dart';

class CustomBottomBar extends StatelessWidget {
  const CustomBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MainNavigationController>();
    final screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      height: 60, // Height of the bar container
      child: Stack(
        children: [
          // Background Bar with Concave Notch
          CustomPaint(
            size: Size(screenWidth, 60),
            painter: ConcaveBottomBarPainter(gradient: AppColors.gradient),
          ),
          
          // Navigation Items
          Positioned(
            bottom: 5, // Positioned slightly above the bottom
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(context, 0, AppImages.settings, "Services", controller),
                _buildNavItem(context, 1, AppImages.booking, "Booking", controller),
                const SizedBox(width: 80), // Increased space for the concave notch
                _buildNavItem(context, 3, AppImages.chat, "Chat", controller),
                _buildNavItem(context, 4, AppImages.profile, "Profile", controller),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, String iconPath, String label, MainNavigationController controller) {
    return GestureDetector(
      onTap: () => controller.changeIndex(index),
      behavior: HitTestBehavior.opaque,
      child: Obx(() {
        final isSelected = controller.currentIndex.value == index;
        final color = isSelected ? AppColors.white : AppColors.white.withValues(alpha: 0.6);
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              iconPath,
              width: 22,
              height: 22,
              color: color,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: customTextStyle(
                10,
                color,
                isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        );
      }),
    );
  }
}
