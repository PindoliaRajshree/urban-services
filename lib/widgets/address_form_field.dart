// File: lib/widgets/address_form_field.dart
// Purpose: A specialized input field with standardized styling for address-related forms.

import 'package:flutter/material.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_text_sizes.dart';
import 'package:urban_services/widgets/custom_text_style.dart';

class AddressFormField extends StatelessWidget {
  /// The descriptive label above the input field
  final String label;

  /// Placeholder text shown when the field is empty
  final String hintText;

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  /// Number of lines the input can expand to (useful for full address)
  final int? maxLines;

  final String? Function(String?)? validator;

  /// Reactive error text passed from the controller
  final String? errorText;

  const AddressFormField({
    super.key,
    required this.label,
    required this.hintText,
    this.controller,
    this.focusNode,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.validator,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label Text
        Text(
          label,
          style: customTextStyle(
            AppTextSizes.smallTextSize,
            AppColors.black,
            FontWeight.w400,
          ),
        ),
        SizedBox(height: AppDimensions.padding5h),
        // The core input field
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          maxLines: maxLines,
          validator: validator,
          style: customTextStyle(
            AppTextSizes.smallTextSize,
            AppColors.black,
            FontWeight.w400,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: customTextStyle(
              AppTextSizes.smallTextSize,
              AppColors.grey,
              FontWeight.w400,
            ),
            filled: true,
            fillColor: AppColors.white,
            errorText: errorText,
            errorStyle: customTextStyle(
              AppTextSizes.stableTextSize,
              AppColors.danger,
              FontWeight.w400,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppDimensions.padding15w,
              vertical: AppDimensions.padding12h,
            ),
            // Default border state
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radius10r),
              borderSide: BorderSide(
                color: errorText != null ? AppColors.danger : AppColors.grey,
                width: 1,
              ),
            ),
            // Normal state
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radius10r),
              borderSide: BorderSide(
                color: errorText != null ? AppColors.danger : AppColors.grey,
                width: 1,
              ),
            ),
            // Active/Focused state
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radius10r),
              borderSide: BorderSide(
                color: errorText != null ? AppColors.danger : AppColors.primary,
                width: 1.5,
              ),
            ),
            // Error state border
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radius10r),
              borderSide: const BorderSide(color: AppColors.danger, width: 1),
            ),
            // Focused state when there is an error
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radius10r),
              borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
