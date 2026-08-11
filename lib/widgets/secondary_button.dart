// File: lib/widgets/secondary_button.dart
// Purpose: A custom reusable button with a transparent background and border.

import 'package:flutter/material.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_text_sizes.dart';
import 'package:urban_services/widgets/custom_text_style.dart';

class SecondaryButton extends StatelessWidget {
  /// The text to be displayed on the button
  final String text;

  /// Callback function when the button is pressed
  final VoidCallback onPressed;

  /// Optional custom width for the button
  final double? width;

  /// Optional custom height for the button
  final double? height;

  /// Optional prefix icon path for the button
  final String? iconPath;

  /// When true, the icon + label are swapped for a spinner and taps are
  /// ignored.
  final bool isLoading;

  const SecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width,
    this.height,
    this.iconPath,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final double spinnerSize = AppDimensions.containerHeight22h;

    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: AnimatedOpacity(
        opacity: isLoading ? 0.75 : 1,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: width ?? double.infinity,
          height: height ?? AppDimensions.containerHeight50h,
          decoration: BoxDecoration(
            color: Colors.transparent,
            // Outline border with darkGrey color
            border: Border.all(color: AppColors.darkGrey),
            borderRadius: BorderRadius.circular(AppDimensions.radius10r),
          ),
          alignment: Alignment.center,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: animation, child: child),
            ),
            child: isLoading
                ? SizedBox(
                    key: const ValueKey('loading'),
                    width: spinnerSize,
                    height: spinnerSize,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.darkGrey,
                      ),
                    ),
                  )
                : Row(
                    key: const ValueKey('label'),
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (iconPath != null) ...[
                        Image.asset(
                          iconPath!,
                          height: AppDimensions.containerHeight20h,
                          width: AppDimensions.containerWidth20w,
                        ),
                        SizedBox(width: AppDimensions.padding10w),
                      ],
                      Text(
                        text,
                        style: customTextStyle(
                          AppTextSizes.doubleLargeTextSize, // Font size 18
                          AppColors.text,
                          FontWeight.w600, // Medium weight
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
