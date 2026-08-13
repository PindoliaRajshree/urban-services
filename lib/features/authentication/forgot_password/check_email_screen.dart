// File: lib/features/authentication/forgot_password/check_email_screen.dart
// Purpose: Step 2 of the forgot-password flow — verify the OTP (see
// ForgotPasswordController.otpLength) sent to the user's email.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/api_status.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_images.dart';
import 'package:urban_services/core/constants/app_text_sizes.dart';
import 'package:urban_services/features/authentication/forgot_password/forgot_password_controller.dart';
import 'package:urban_services/widgets/custom_text_style.dart';
import 'package:urban_services/widgets/primary_button.dart';

class CheckEmailScreen extends StatefulWidget {
  const CheckEmailScreen({super.key});

  @override
  State<CheckEmailScreen> createState() => _CheckEmailScreenState();
}

class _CheckEmailScreenState extends State<CheckEmailScreen> {
  // Reuse the flow controller put (permanent) on ForgotPasswordScreen, so
  // the email captured in step 1 carries through here.
  final controller = Get.find<ForgotPasswordController>();

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.height < 720;

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: SafeArea(
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
                'Check your email',
                style: customTextStyle(
                  AppTextSizes.extraLargeTextSize, // 20
                  AppColors.darkBlack,
                  FontWeight.w600,
                ),
              ),

              SizedBox(height: AppDimensions.padding10h),

              // 6. Instruction Text
              Text(
                'We sent a reset code to ${controller.emailController.text}\nenter ${ForgotPasswordController.otpLength} digit code that mentioned in the email',
                style: customTextStyle(
                  AppTextSizes.largeMediumTextSize, // 14
                  AppColors.text,
                  FontWeight.w500,
                ),
              ),

              SizedBox(height: AppDimensions.padding20h),

              // 7. OTP Input Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  ForgotPasswordController.otpLength,
                  (index) => _buildOtpSlot(index, isSmall),
                ),
              ),

              SizedBox(height: AppDimensions.padding20h),

              // 8. Verify Action Button
              Obx(
                () => PrimaryButton(
                  text: 'Verify Code',
                  isLoading: controller.status.value == ApiStatus.loading,
                  onPressed: controller.verifyOtp,
                ),
              ),

              SizedBox(height: AppDimensions.padding10h),

              // 9. Resend Option (RichText)
              Center(
                child: GestureDetector(
                  onTap: controller.resendCode,
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Haven’t got the email yet? ',
                          style: customTextStyle(
                            AppTextSizes.largeTextSize, // 16
                            AppColors.grey,
                            FontWeight.w600,
                          ),
                        ),
                        TextSpan(
                          text: 'Resend code',
                          style: customTextStyle(
                            AppTextSizes.largeTextSize, // 16
                            AppColors.primaryDark,
                            FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper to build individual OTP input slots
  Widget _buildOtpSlot(int index, bool isSmall) {
    return Container(
      width: isSmall
          ? AppDimensions.containerWidth40w
          : AppDimensions.containerWidth47w,
      height: isSmall
          ? AppDimensions.containerHeight40h
          : AppDimensions.containerHeight47h,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radius12r),
        border: Border.all(
          color: AppColors.text,
          width: AppDimensions.containerWidth1w,
        ),
      ),
      child: TextField(
        controller: controller.otpControllers[index],
        focusNode: controller.otpFocusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (value) => controller.onDigitChanged(index, value),
        style: customTextStyle(
          AppTextSizes.doubleLargeTextSize, // 18
          AppColors.black,
          FontWeight.w600,
        ),
        decoration: InputDecoration(
          counterText: "",
          border: InputBorder.none,
          isDense: isSmall ? true : false,
          contentPadding: isSmall
              ? .only(top: AppDimensions.padding5h)
              : EdgeInsets.zero,
        ),
      ),
    );
  }
}
