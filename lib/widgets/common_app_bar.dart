import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_images.dart';
import 'package:urban_services/core/constants/app_text_sizes.dart';
import 'package:urban_services/widgets/custom_text_style.dart';

class CommonAppBar extends StatelessWidget {
  final String title;
  final Widget? rightAction;
  final VoidCallback? onBackPress;
  final bool showMoreIcon;
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
          // Left: Back button from asset
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
          
          // Center: Title
          Text(
            title,
            style: customTextStyle(
              AppTextSizes.largeTextSize,
              AppColors.text,
              FontWeight.w600,
            ),
          ),
          
          // Right: Optional Action or More Icon
          Align(
            alignment: Alignment.centerRight,
            child: rightAction ?? (showMoreIcon 
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
