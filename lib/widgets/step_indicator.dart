// File: lib/widgets/step_indicator.dart
// Purpose: A responsive 7-step progress tracker for the multi-section profile form.

import 'package:flutter/material.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/widgets/custom_text_style.dart';

class StepIndicator extends StatelessWidget {
  final int currentStep;
  final List<String> stepLabels;

  const StepIndicator({
    super.key,
    required this.currentStep,
    required this.stepLabels,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppDimensions.padding20h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(stepLabels.length, (index) {
          final bool isLast = index == stepLabels.length - 1;
          return Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    // Left line for intermediate steps
                    Expanded(
                      child: Container(
                        height: 1,
                        color: index == 0
                            ? Colors.transparent
                            : (index <= currentStep
                                  ? AppColors.successGreen
                                  : AppColors.lightGrey2),
                      ),
                    ),
                    // Step Circle
                    _buildStepCircle(index),
                    // Right line for intermediate steps
                    Expanded(
                      child: Container(
                        height: 1,
                        color: isLast
                            ? Colors.transparent
                            : (index < currentStep
                                  ? AppColors.successGreen
                                  : AppColors.lightGrey2),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppDimensions.padding8h),
                // Step Label centered below each indicator
                Text(
                  stepLabels[index],
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: customTextStyle(
                    8, // Smaller text to fit all 7 steps in a row
                    index == currentStep ? AppColors.black : AppColors.grey,
                    index == currentStep ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepCircle(int index) {
    final bool isCompleted = index < currentStep;
    final bool isCurrent = index == currentStep;

    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted
            ? AppColors.successGreen
            : (isCurrent ? AppColors.primary : AppColors.grey),
      ),
      child: isCompleted
          ? const Icon(Icons.check, size: 14, color: AppColors.white)
          : (isCurrent
                ? Center(
                    child: Text(
                      (index + 1).toString(),
                      style: customTextStyle(
                        10,
                        AppColors.white,
                        FontWeight.w600,
                      ),
                    ),
                  )
                : null),
    );
  }
}
