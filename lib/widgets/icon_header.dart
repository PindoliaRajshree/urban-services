// File: lib/widgets/icon_header.dart
// Purpose: A stylized section header with a primary-colored icon and gradient title.

import 'package:flutter/material.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_text_sizes.dart';
import 'package:urban_services/widgets/custom_text_style.dart';

class IconHeader extends StatelessWidget {
  final String icon;
  final String title;

  const IconHeader({super.key, required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppDimensions.padding15h),
      child: Row(
        children: [
          Image.asset(
            icon,
            height: AppDimensions.containerHeight20h,
            width: AppDimensions.containerWidth20w,
            color: AppColors.primaryDark,
          ),
          SizedBox(width: AppDimensions.padding10w),
          ShaderMask(
            shaderCallback: (bounds) =>
                AppColors.gradient.createShader(Offset.zero & bounds.size),
            child: Text(
              title,
              style: customTextStyle(
                AppTextSizes.largeMediumTextSize, // 14
                AppColors.white,
                FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
