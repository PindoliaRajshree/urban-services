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

  /// When true, the label is swapped for a spinner and taps are ignored.
  /// Callers no longer need to juggle their own "Please wait..." text /
  /// no-op callback while an API call is in flight — just pass the
  /// controller's loading flag straight through.
  final bool isLoading;

  /// Dimmed and ignores taps, without a spinner — e.g. while a different
  /// button's request is running.
  final bool isDisabled;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width,
    this.height,
    this.isLoading = false,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final double spinnerSize = AppDimensions.containerHeight22h;

    return GestureDetector(
      onTap: isLoading || isDisabled ? null : onPressed,
      child: AnimatedOpacity(
        opacity: isDisabled
            ? 0.5
            : isLoading
            ? 0.75
            : 1,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: width ?? double.infinity,
          height: height ?? AppDimensions.containerHeight50h,
          decoration: BoxDecoration(
            // Uses the primary brand gradient
            gradient: AppColors.gradient,
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
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.4,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.white,
                      ),
                    ),
                  )
                // Shrinks rather than overflowing with large system fonts.
                : Padding(
                    key: const ValueKey('label'),
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.padding12w,
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        text,
                        maxLines: 1,
                        style: customTextStyle(
                          AppTextSizes.doubleLargeTextSize, // Font size 18
                          AppColors.white,
                          FontWeight.w600, // Medium weight
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
