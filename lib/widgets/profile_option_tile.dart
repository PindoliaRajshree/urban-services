import 'package:flutter/material.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_images.dart';
import 'package:urban_services/core/constants/app_text_sizes.dart';
import 'package:urban_services/widgets/custom_text_style.dart';

class ProfileOptionTile extends StatelessWidget {
  final String icon;
  final String title;
  final VoidCallback onTap;
  final bool showDivider;

  const ProfileOptionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.padding20w,
              vertical: AppDimensions.padding12h,
            ),
            child: Row(
              children: [
                Image.asset(
                  icon,
                  height: AppDimensions.containerHeight30h,
                  width: AppDimensions.containerWidth30w,
                ),
                SizedBox(width: AppDimensions.padding15w),
                Expanded(
                  child: Text(
                    title,
                    style: customTextStyle(
                      AppTextSizes.largeTextSize,
                      AppColors.text,
                      FontWeight.w500,
                    ),
                  ),
                ),
                Image.asset(
                  AppImages.forward,
                  height: AppDimensions.containerHeight15h,
                  width: AppDimensions.containerWidth15w,
                  color: AppColors.text,
                ),
              ],
            ),
          ),
          if (showDivider)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppDimensions.padding20w),
              child: Divider(
                color: AppColors.darkGrey,
                height: AppDimensions.containerHeight1h,
                thickness: 0.5,
              ),
            ),
        ],
      ),
    );
  }
}
