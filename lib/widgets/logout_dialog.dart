// File: lib/widgets/logout_dialog.dart
// Purpose: A confirmation dialog for logging out of the application.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_text_sizes.dart';
import 'package:urban_services/features/profile/profile_controller.dart';
import 'package:urban_services/widgets/custom_text_style.dart';

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    // Access ProfileController for logout logic
    final controller = Get.find<ProfileController>();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: AppDimensions.padding20w),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radius20r),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.17),
              blurRadius: 4,
              spreadRadius: 1,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        padding: EdgeInsets.all(AppDimensions.padding20h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              'Logout',
              style: customTextStyle(
                AppTextSizes.extraLargeTextSize, // 20
                AppColors.darkBlack,
                FontWeight.w600,
              ),
            ),
            SizedBox(height: AppDimensions.padding15h),
            // Message
            Text(
              'Are you sure you want to logout? You will need to login again to access your account.',
              textAlign: TextAlign.center,
              style: customTextStyle(
                AppTextSizes.largeMediumTextSize, // 14
                AppColors.text,
                FontWeight.w500,
              ),
            ),
            SizedBox(height: AppDimensions.padding30h),
            // Action Buttons
            Obx(
              () => Row(
                children: [
                  // Negative Action: Cancel
                  Expanded(
                    child: TextButton(
                      onPressed: controller.isLoggingOut
                          ? null
                          : controller.closeDialog,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: AppDimensions.padding12h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radius10r,
                          ),
                          side: const BorderSide(color: AppColors.grey),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: customTextStyle(
                          AppTextSizes.largeTextSize,
                          AppColors.text,
                          FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: AppDimensions.padding15w),
                  // Positive Action: Confirm Logout
                  Expanded(
                    child: ElevatedButton(
                      onPressed: controller.isLoggingOut
                          ? null
                          : controller.logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.danger,
                        padding: EdgeInsets.symmetric(
                          vertical: AppDimensions.padding12h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radius10r,
                          ),
                        ),
                        elevation: 0,
                      ),
                      child: controller.isLoggingOut
                          ? SizedBox(
                              height: AppDimensions.containerHeight20h,
                              width: AppDimensions.containerWidth20w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.white,
                                ),
                              ),
                            )
                          : Text(
                              'Logout',
                              style: customTextStyle(
                                AppTextSizes.largeTextSize,
                                AppColors.white,
                                FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
