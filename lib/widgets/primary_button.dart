// File: lib/widgets/primary_button.dart
// Purpose: A custom reusable button with a gradient background.

import 'package:flutter/material.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_text_sizes.dart';
import 'package:urban_services/widgets/custom_text_style.dart';

class PrimaryButton extends StatelessWidget {
  /// The text to be displayed on the button
  final String text;

  /// Callback function when the button is pressed
  final VoidCallback onPressed;

  /// Optional custom width for the button
  final double? width;

  /// Optional custom height for the button
  final double? height;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width ?? double.infinity,
        height: height ?? AppDimensions.containerHeight50h,
        decoration: BoxDecoration(
          // Uses the primary brand gradient
          gradient: AppColors.gradient,
          borderRadius: BorderRadius.circular(AppDimensions.radius10r),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: customTextStyle(
            AppTextSizes.doubleLargeTextSize, // Font size 18
            AppColors.white,
            FontWeight.w600, // Medium weight
          ),
        ),
      ),
    );
  }
}
