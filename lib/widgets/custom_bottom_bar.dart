import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_images.dart';
import 'package:urban_services/core/constants/app_text_sizes.dart';
import 'package:urban_services/features/home_main/main_navigation_controller.dart';
import 'package:urban_services/widgets/concave_bottom_bar_painter.dart';
import 'package:urban_services/widgets/custom_text_style.dart';

class CustomBottomBar extends StatefulWidget {
  const CustomBottomBar({super.key});

  @override
  State<CustomBottomBar> createState() => _CustomBottomBarState();
}

class _CustomBottomBarState extends State<CustomBottomBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _notchXAnimation;
  final navigationController = Get.find<MainNavigationController>();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Initial position based on the current index
    _notchXAnimation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Listen for index changes to trigger animation
    ever(navigationController.currentIndex, (index) {
      if (mounted) {
        _animateTo(index);
      }
    });

    // Set initial animation value once layout is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animateTo(navigationController.currentIndex.value, isInitial: true);
    });
  }

  void _animateTo(int index, {bool isInitial = false}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double targetX = _getTabX(index, screenWidth);

    if (isInitial) {
      setState(() {
        _notchXAnimation = Tween<double>(begin: targetX, end: targetX).animate(
          _controller,
        );
      });
    } else {
      setState(() {
        _notchXAnimation = Tween<double>(
          begin: _notchXAnimation.value,
          end: targetX,
        ).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        );
      });
      _controller.forward(from: 0);
    }
  }

  double _getTabX(int index, double screenWidth) {
    // 5 tabs total
    double tabWidth = screenWidth / 5;
    return (index + 0.5) * tabWidth;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return AnimatedBuilder(
      animation: _notchXAnimation,
      builder: (context, child) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Background Bar with Moving Concave Notch
            SizedBox(
              height: AppDimensions.padding60h,
              child: CustomPaint(
                size: Size(screenWidth, AppDimensions.padding60h),
                painter: ConcaveBottomBarPainter(
                  gradient: AppColors.gradient,
                  notchX: _notchXAnimation.value,
                ),
              ),
            ),

            // Navigation Items
            Positioned(
              bottom: AppDimensions.padding5h,
              left: 0,
              right: 0,
              child: Row(
                children: [
                  _buildNavItem(0, AppImages.settings, "Services"),
                  _buildNavItem(1, AppImages.booking, "Booking"),
                  _buildNavItem(2, AppImages.home, "Home", isHome: true),
                  _buildNavItem(3, AppImages.chat, "Chat"),
                  _buildNavItem(4, AppImages.profile, "Profile"),
                ],
              ),
            ),

            // Animated Floating Button that follows the notch
            Positioned(
              top: -AppDimensions.padding30h, // Pop up above the bar
              left: _notchXAnimation.value - (AppDimensions.containerWidth60w / 2),
              child: _buildFloatingButton(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNavItem(int index, String iconPath, String label, {bool isHome = false}) {
    return Expanded(
      child: GestureDetector(
        onTap: () => navigationController.changeIndex(index),
        behavior: HitTestBehavior.opaque,
        child: Obx(() {
          final isSelected = navigationController.currentIndex.value == index;
          
          // Hide icon/label ONLY if it's the currently selected tab
          // (because the selected tab is always shown in the floating button/notch)
          final bool shouldShow = !isSelected;

          final color = AppColors.white.withValues(alpha: 0.6);

          return Opacity(
            opacity: shouldShow ? 1.0 : 0.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  iconPath,
                  width: AppDimensions.containerWidth22w,
                  height: AppDimensions.containerHeight22h,
                  color: color,
                ),
                SizedBox(height: AppDimensions.padding2h),
                Text(
                  label,
                  style: customTextStyle(
                    AppTextSizes.stableTextSize,
                    color,
                    FontWeight.w400,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildFloatingButton() {
    return Obx(() {
      final index = navigationController.currentIndex.value;
      String iconPath;
      String label;

      switch (index) {
        case 0:
          iconPath = AppImages.settings;
          label = "Services";
          break;
        case 1:
          iconPath = AppImages.booking;
          label = "Booking";
          break;
        case 3:
          iconPath = AppImages.chat;
          label = "Chat";
          break;
        case 4:
          iconPath = AppImages.profile;
          label = "Profile";
          break;
        default:
          iconPath = AppImages.home;
          label = "Home";
      }

      return Container(
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
            Image.asset(
              iconPath,
              width: AppDimensions.containerWidth24w,
              height: AppDimensions.containerHeight24h,
              color: AppColors.white,
            ),
            SizedBox(height: AppDimensions.padding2h),
            Text(
              label,
              style: customTextStyle(
                AppTextSizes.stableTextSize,
                AppColors.white,
                FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    });
  }
}
