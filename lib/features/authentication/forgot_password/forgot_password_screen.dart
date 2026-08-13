// File: lib/features/authentication/forgot_password/forgot_password_screen.dart
// Purpose: Screen for users to initiate password recovery via their email —
// step 1 of the shared forgot-password flow (send OTP).

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_images.dart';
import 'package:urban_services/core/constants/app_text_sizes.dart';
import 'package:urban_services/core/constants/api_status.dart';
import 'package:urban_services/features/authentication/forgot_password/forgot_password_controller.dart';
import 'package:urban_services/widgets/custom_text_style.dart';
import 'package:urban_services/widgets/primary_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // Marked permanent so this controller (and the email it captures) survives
  // navigation into the OTP and Reset Password screens further down the flow.
  final controller = Get.put(ForgotPasswordController(), permanent: true);

  @override
  Widget build(BuildContext context) {
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

              // 4. Main Title
              Text(
                'Forgot password',
                style: customTextStyle(
                  AppTextSizes.extraLargeTextSize, // 20
                  AppColors.darkBlack,
                  FontWeight.w600,
                ),
              ),

              SizedBox(height: AppDimensions.padding10h),

              // 5. Instruction Text
              Text(
                'Please enter your email to reset the password',
                style: customTextStyle(
                  AppTextSizes.largeMediumTextSize, // 14
                  AppColors.text,
                  FontWeight.w500,
                ),
              ),

              SizedBox(height: AppDimensions.padding20h),

              // 6. Email Label
              Text(
                'Your Email Address',
                style: customTextStyle(
                  AppTextSizes.largeTextSize, // 16
                  AppColors.grey3,
                  FontWeight.w600,
                ),
              ),

              SizedBox(height: AppDimensions.padding10h),

              // 7. Custom Styled Email TextField
              Obx(
                () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radius10r,
                        ),
                        border: Border.all(
                          color: controller.emailError.value != null
                              ? AppColors.danger
                              : AppColors.grey,
                          width: AppDimensions.containerWidth1w,
                        ),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.padding10w,
                      ),
                      child: TextField(
                        controller: controller.emailController,
                        focusNode: controller.emailFocusNode,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => controller.sendOtp(),
                        style: customTextStyle(
                          AppTextSizes.smallTextSize,
                          AppColors.black,
                          FontWeight.w400,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter your email',
                          hintStyle: customTextStyle(
                            AppTextSizes.smallTextSize, // 12
                            AppColors.darkGrey,
                            FontWeight.w400,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: AppDimensions.padding12h,
                          ),
                        ),
                      ),
                    ),
                    if (controller.emailError.value != null)
                      Padding(
                        padding: EdgeInsets.only(
                          top: AppDimensions.padding4h,
                          left: AppDimensions.padding4w,
                        ),
                        child: Text(
                          controller.emailError.value!,
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

              SizedBox(height: AppDimensions.padding30h),

              // 8. Reset Password Button
              Obx(
                () => PrimaryButton(
                  text: 'Reset Password',
                  isLoading: controller.status.value == ApiStatus.loading,
                  onPressed: controller.sendOtp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
