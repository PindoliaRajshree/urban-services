// File: lib/features/authentication/forgot_password/reset_password_screen.dart
// Purpose: Screen for users to set a new password after successful OTP verification.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_images.dart';
import 'package:urban_services/core/constants/app_text_sizes.dart';
import 'package:urban_services/features/authentication/forgot_password/reset_password_controller.dart';
import 'package:urban_services/widgets/custom_text_style.dart';
import 'package:urban_services/widgets/primary_button.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  // Initialize the logic controller
  final controller = Get.put(ResetPasswordController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppDimensions.padding20w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: AppDimensions.padding20h),

                // 3. Custom Circular Back Button
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    width: AppDimensions.containerWidth35w,
                    height: AppDimensions.containerHeight35h,
                    decoration: const BoxDecoration(
                      color: AppColors.lightGrey3,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Image.asset(
                        AppImages.back,
                        height: AppDimensions.containerHeight18h,
                        width: AppDimensions.containerWidth18w,
                        color: AppColors.darkBlack,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: AppDimensions.padding20h),

                // 5. Main Title
                Text(
                  'Set a new password',
                  style: customTextStyle(
                    AppTextSizes.extraLargeTextSize, // 20
                    AppColors.darkBlack,
                    FontWeight.w600,
                  ),
                ),

                SizedBox(height: AppDimensions.padding10h),

                // 6. Instruction Text
                Text(
                  'Create a new password. Ensure it differs from\nprevious ones for security',
                  style: customTextStyle(
                    AppTextSizes.largeMediumTextSize, // 14
                    AppColors.text,
                    FontWeight.w500,
                  ),
                ),

                SizedBox(height: AppDimensions.padding20h),

                // 7. Password Fields Section

                // Password Label
                Text(
                  'Password',
                  style: customTextStyle(
                    AppTextSizes.largeTextSize, // 16
                    AppColors.grey3,
                    FontWeight.w600,
                  ),
                ),
                SizedBox(height: AppDimensions.padding10h),
                // Password Input with eye icon
                _buildPasswordField(
                  controller: controller.passwordController,
                  focusNode: controller.passwordFocus,
                  obscureRx: controller.obscurePassword,
                  errorRx: controller.passwordError,
                  toggleVisibility: controller.togglePasswordVisibility,
                ),

                SizedBox(height: AppDimensions.padding20h),

                // Confirm Password Label
                Text(
                  'Confirm Password',
                  style: customTextStyle(
                    AppTextSizes.largeTextSize, // 16
                    AppColors.grey3,
                    FontWeight.w600,
                  ),
                ),
                SizedBox(height: AppDimensions.padding10h),
                // Confirm Password Input with eye icon
                _buildPasswordField(
                  controller: controller.confirmPasswordController,
                  focusNode: controller.confirmPasswordFocus,
                  obscureRx: controller.obscureConfirmPassword,
                  errorRx: controller.confirmPasswordError,
                  toggleVisibility: controller.toggleConfirmPasswordVisibility,
                  isLast: true,
                ),

                SizedBox(height: AppDimensions.padding20h),

                // 8. Update Password Button
                PrimaryButton(
                  text: 'Update Password',
                  onPressed: controller.updatePassword,
                ),

                SizedBox(height: AppDimensions.padding30h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Helper to build password input fields with validation and visibility toggle
  Widget _buildPasswordField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required RxBool obscureRx,
    required RxnString errorRx,
    required VoidCallback toggleVisibility,
    bool isLast = false,
  }) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppDimensions.radius10r),
              border: Border.all(
                color: errorRx.value != null
                    ? AppColors.danger
                    : AppColors.grey,
                width: AppDimensions.containerWidth1w,
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: AppDimensions.padding10w),
            child: TextField(
              textAlignVertical: .center,
              controller: controller,
              focusNode: focusNode,
              obscureText: obscureRx.value,
              textInputAction: isLast
                  ? TextInputAction.done
                  : TextInputAction.next,
              onSubmitted: (_) =>
                  isLast ? this.controller.updatePassword() : null,
              style: customTextStyle(
                AppTextSizes.smallTextSize, // 12
                AppColors.darkBlack,
                FontWeight.w400,
              ),
              decoration: InputDecoration(
                hintText: 'Enter your password',
                hintStyle: customTextStyle(
                  AppTextSizes.smallTextSize,
                  AppColors.grey,
                  FontWeight.w400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  vertical: AppDimensions.padding12h,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    obscureRx.value
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.grey,
                    size: AppDimensions.containerHeight20h,
                  ),
                  onPressed: toggleVisibility,
                ),
              ),
            ),
          ),
          if (errorRx.value != null)
            Padding(
              padding: EdgeInsets.only(
                top: AppDimensions.padding4h,
                left: AppDimensions.padding4w,
              ),
              child: Text(
                errorRx.value!,
                style: customTextStyle(
                  AppTextSizes.stableTextSize,
                  AppColors.danger,
                  FontWeight.w400,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
