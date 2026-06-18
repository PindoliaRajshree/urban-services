// File: lib/widgets/custom_dropdown.dart
// Purpose: A standardized dropdown menu component for form consistency.

import 'package:flutter/material.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_text_sizes.dart';
import 'package:urban_services/widgets/custom_text_style.dart';

class CustomDropdown<T> extends StatelessWidget {
  final String hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String label;

  const CustomDropdown({
    super.key,
    required this.hint,
    required this.items,
    required this.onChanged,
    required this.label,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: customTextStyle(
            AppTextSizes.smallTextSize, // 12
            AppColors.black,
            FontWeight.w400,
          ),
        ),
        SizedBox(height: AppDimensions.padding5h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: AppDimensions.padding12w),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppDimensions.radius10r),
            border: Border.all(color: AppColors.grey, width: 1),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              isExpanded: true,
              value: value,
              style: customTextStyle(
                AppTextSizes.smallTextSize,
                AppColors.black,
                FontWeight.w400,
              ),
              hint: Text(
                hint,
                style: customTextStyle(
                  AppTextSizes.smallTextSize,
                  AppColors.grey,
                  FontWeight.w400,
                ),
              ),
              items: items,
              onChanged: onChanged,
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.grey,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
