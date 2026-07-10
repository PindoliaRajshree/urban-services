// File: lib/widgets/custom_search_bar.dart
// Purpose: Reusable rounded search bar used across screens (Home, Chat List, etc.).

import 'package:flutter/material.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_text_sizes.dart';
import 'package:urban_services/widgets/custom_text_style.dart';

class CustomSearchBar extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;

  const CustomSearchBar({
    super.key,
    this.hintText = 'Search',
    this.controller,
    this.onChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppDimensions.containerHeight45h,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radius30r),
        border: Border.all(color: AppColors.white, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            offset: const Offset(0, 1),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: AppDimensions.padding15w),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColors.grey),
          SizedBox(width: AppDimensions.padding10w),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              onTap: onTap,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: customTextStyle(
                  AppTextSizes.smallTextSize, // 12
                  AppColors.darkGrey,
                  FontWeight.w400,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
              style: customTextStyle(
                AppTextSizes.smallTextSize, // 12
                AppColors.black,
                FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
