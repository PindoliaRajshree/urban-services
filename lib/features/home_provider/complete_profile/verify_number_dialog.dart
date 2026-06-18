// File: lib/features/home_provider/complete_profile/verify_number_dialog.dart
// Purpose: OTP verification dialog with masked mobile number display and inline validation.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_text_sizes.dart';
import 'package:urban_services/features/home_provider/complete_profile/complete_profile_controller.dart';
import 'package:urban_services/widgets/custom_text_style.dart';
import 'package:urban_services/widgets/primary_button.dart';

class VerifyNumberDialog extends StatelessWidget {
  final String phoneNumber;

  const VerifyNumberDialog({super.key, required this.phoneNumber});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CompleteProfileController>();

    // Simple masking: show first 5 and last 2, rest *
    final masked = phoneNumber.length > 7
        ? "${phoneNumber.substring(0, 5)}***${phoneNumber.substring(phoneNumber.length - 2)}"
        : phoneNumber;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(AppDimensions.padding20h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radius16r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Verify Number',
              style: customTextStyle(
                AppTextSizes.largeTextSize, // 16
                AppColors.darkBlueText,
                FontWeight.w700,
              ),
            ),
            SizedBox(height: AppDimensions.padding10h),
            Text(
              'We sent a OTP to $masked',
              style: customTextStyle(
                AppTextSizes.smallTextSize, // 12
                AppColors.greyText,
                FontWeight.w400,
              ),
            ),
            SizedBox(height: AppDimensions.padding20h),
            // Standardized OTP Input Field
            Obx(
              () => Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: AppDimensions.containerHeight50h,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      border: Border.all(
                        color: controller.otpError.value != null
                            ? AppColors.danger
                            : AppColors.lightGreyBorder,
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: controller.otpController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: customTextStyle(
                        AppTextSizes.headingTextSize, // 24
                        AppColors.darkBlueText,
                        FontWeight.w400,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "- - - - -",
                      ),
                    ),
                  ),
                  if (controller.otpError.value != null)
                    Padding(
                      padding: EdgeInsets.only(top: AppDimensions.padding4h),
                      child: Text(
                        controller.otpError.value!,
                        style: customTextStyle(
                          AppTextSizes.stableTextSize,
                          AppColors.danger,
                          FontWeight.w400,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: AppDimensions.padding15h),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "Didn't receive code? ",
                    style: customTextStyle(
                      AppTextSizes.smallTextSize,
                      AppColors.lightGreyBorder,
                      FontWeight.w400,
                    ),
                  ),
                  TextSpan(
                    text: "Resend",
                    style: customTextStyle(
                      AppTextSizes.largeMediumTextSize, // 14
                      AppColors.primaryDark,
                      FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppDimensions.padding25h),
            // Adjusted Verify Button
            PrimaryButton(
              text: 'Verify',
              width: AppDimensions.containerWidth150w,
              height: AppDimensions.containerHeight40h,
              onPressed: controller.verifyOtp,
            ),
          ],
        ),
      ),
    );
  }
}
