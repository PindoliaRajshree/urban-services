// File: lib/widgets/common_app_bar.dart
// Purpose: A reusable, standardized AppBar component with consistent branding and navigation.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_images.dart';
import 'package:urban_services/core/constants/app_text_sizes.dart';
import 'package:urban_services/widgets/custom_text_style.dart';

class CommonAppBar extends StatelessWidget {
  /// The title displayed in the center of the AppBar
  final String title;

  /// Optional widget to display on the far right (custom actions)
  final Widget? rightAction;

  /// Custom callback for the back button; defaults to [Get.back()]
  final VoidCallback? onBackPress;

  /// Whether to show the standard vertical more icon
  final bool showMoreIcon;

  /// Callback for the vertical more icon tap
  final VoidCallback? onMorePressed;

  const CommonAppBar({
    super.key,
    required this.title,
    this.rightAction,
    this.onBackPress,
    this.showMoreIcon = false,
    this.onMorePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppDimensions.padding15h),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Left: Standardized Back button from assets
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: onBackPress ?? () => Get.back(),
              child: Image.asset(
                AppImages.back,
                height: AppDimensions.containerHeight24h,
                width: AppDimensions.containerWidth24w,
                color: AppColors.text,
              ),
            ),
          ),

          // Center: Standardized Title text
          Text(
            title,
            style: customTextStyle(
              AppTextSizes.largeTextSize,
              AppColors.text,
              FontWeight.w600,
            ),
          ),

          // Right: Dynamic Action Section (Custom widget or standard 'More' icon)
          Align(
            alignment: Alignment.centerRight,
            child:
                rightAction ??
                (showMoreIcon
                    ? GestureDetector(
                        onTap: onMorePressed,
                        child: Icon(
                          Icons.more_vert,
                          color: AppColors.text,
                          size: AppDimensions.containerHeight24h,
                        ),
                      )
                    : const SizedBox.shrink()),
          ),
        ],
      ),
    );
  }
}
