// File: lib/features/authentication/forgot_password/forgot_password_screen.dart
// Purpose: Screen for users to initiate password recovery via their email —
// step 1 of the shared forgot-password flow (send OTP).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_images.dart';
import 'package:urban_services/core/constants/app_text_sizes.dart';
import 'package:urban_services/features/authentication/forgot_password/forgot_password_provider.dart';
import 'package:urban_services/widgets/custom_text_style.dart';
import 'package:urban_services/widgets/primary_button.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _emailFocusNode = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  void _sendOtp() =>
      ref.read(forgotPasswordProvider.notifier).sendOtp(_emailController.text);

  @override
  Widget build(BuildContext context) {
    // Watching keeps the flow's provider (and the email it captures) alive
    // while the OTP and Reset Password screens are pushed on top.
    final state = ref.watch(forgotPasswordProvider);

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
                onTap: () => context.pop(),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radius10r,
                      ),
                      border: Border.all(
                        color: state.emailError != null
                            ? AppColors.danger
                            : AppColors.grey,
                        width: AppDimensions.containerWidth1w,
                      ),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.padding10w,
                    ),
                    child: TextField(
                      controller: _emailController,
                      focusNode: _emailFocusNode,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _sendOtp(),
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
                  if (state.emailError != null)
                    Padding(
                      padding: EdgeInsets.only(
                        top: AppDimensions.padding4h,
                        left: AppDimensions.padding4w,
                      ),
                      child: Text(
                        state.emailError!,
                        style: customTextStyle(
                          AppTextSizes.stableTextSize,
                          AppColors.danger,
                          FontWeight.w400,
                        ),
                      ),
                    ),
                ],
              ),

              SizedBox(height: AppDimensions.padding30h),

              // 8. Reset Password Button
              PrimaryButton(
                text: 'Reset Password',
                isLoading: state.isLoading,
                onPressed: _sendOtp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
