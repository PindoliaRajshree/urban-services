// File: lib/widgets/category_item.dart
// Purpose: A reusable widget representing a service category item on the Home screen.

import 'package:flutter/material.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_text_sizes.dart';
import 'package:urban_services/widgets/custom_text_style.dart';

class CategoryItem extends StatelessWidget {
  final String icon;
  final String title;

  const CategoryItem({super.key, required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Category Icon Container
        Container(
          width:
              AppDimensions.containerWidth74w, // Fixed size for category items
          height: AppDimensions.containerHeight74h,
          padding: EdgeInsets.all(AppDimensions.padding10w),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppDimensions.radius10r),
            // Gradient Border effect (simplified using a stack or colored border)
            border: Border.all(color: AppColors.primaryLight, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                offset: const Offset(0, 3),
                blurRadius: 3,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Center(child: Image.asset(icon, fit: BoxFit.contain)),
        ),
        SizedBox(height: AppDimensions.padding8h),
        // Category Label
        Text(
          title,
          style: customTextStyle(
            AppTextSizes.smallTextSize, // 12
            AppColors.text,
            FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
