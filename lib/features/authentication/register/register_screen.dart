import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_images.dart';
import 'package:urban_services/core/constants/app_text_sizes.dart';
import 'package:urban_services/features/authentication/register/register_controller.dart';
import 'package:urban_services/widgets/custom_text_field.dart';
import 'package:urban_services/widgets/custom_text_style.dart';
import 'package:urban_services/widgets/primary_button.dart';
import 'package:urban_services/widgets/secondary_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final controller = Get.put(RegisterController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    children: [
                      Image.asset(
                        AppImages.vector,
                        fit: BoxFit.fill,
                      ),
                      SizedBox(height: AppDimensions.containerHeight40h),
                    ],
                  ),
                  Positioned(
                    top: AppDimensions.padding70h,
                    child: Image.asset(
                      AppImages.appLogo,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppDimensions.padding20w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create your account',
                      style: customTextStyle(
                        AppTextSizes.headingTextSize,
                        AppColors.black,
                        FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: AppDimensions.padding5h),
                    Text(
                      'Register to get started',
                      style: customTextStyle(
                        AppTextSizes.largeTextSize,
                        AppColors.text,
                        FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: AppDimensions.padding15h),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(AppDimensions.radius22r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withValues(alpha: 0.1),
                            blurRadius: 6,
                            spreadRadius: 2,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(AppDimensions.radius20r),
                      child: Column(
                        children: [
                          Obx(() => CustomTextField(
                            hintText: 'Enter Name',
                            prefixIconPath: AppImages.name,
                            controller: controller.nameController,
                            focusNode: controller.nameFocusNode,
                            textInputAction: TextInputAction.next,
                            errorText: controller.nameError.value,
                          )),
                          SizedBox(height: AppDimensions.padding20h),
                          Obx(() => CustomTextField(
                            hintText: 'Enter Email (Optional)',
                            prefixIconPath: AppImages.email,
                            controller: controller.emailController,
                            focusNode: controller.emailFocusNode,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            errorText: controller.emailError.value,
                          )),
                          SizedBox(height: AppDimensions.padding20h),
                          Obx(() => CustomTextField(
                            hintText: 'Enter Password',
                            prefixIconPath: AppImages.password,
                            isPassword: true,
                            controller: controller.passwordController,
                            focusNode: controller.passwordFocusNode,
                            textInputAction: TextInputAction.next,
                            errorText: controller.passwordError.value,
                          )),
                          SizedBox(height: AppDimensions.padding20h),
                          Obx(() => CustomTextField(
                            hintText: 'Confirm Password',
                            prefixIconPath: AppImages.password,
                            isPassword: true,
                            controller: controller.confirmPasswordController,
                            focusNode: controller.confirmPasswordFocusNode,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => controller.register(),
                            errorText: controller.confirmPasswordError.value,
                          )),
                          SizedBox(height: AppDimensions.padding10h),
                          Obx(() => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: controller.agreeToTerms.value,
                                    onChanged: (val) => controller.agreeToTerms.value = val ?? false,
                                    activeColor: AppColors.primary,
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                                  ),
                                  SizedBox(width: AppDimensions.padding5w,),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'I agree to the',
                                          style: customTextStyle(
                                            AppTextSizes.smallTextSize,
                                            AppColors.text,
                                            FontWeight.w400,
                                          ),
                                        ),
                                        TextSpan(
                                          text: ' Terms & Conditions',
                                          style: customTextStyle(
                                            AppTextSizes.smallTextSize,
                                            AppColors.primaryOrange,
                                            FontWeight.w400,
                                          ),
                                        ),
                                        TextSpan(
                                          text: ' and ',
                                          style: customTextStyle(
                                            AppTextSizes.smallTextSize,
                                            AppColors.text,
                                            FontWeight.w400,
                                          ),
                                        ),
                                        TextSpan(
                                          text: 'Policy',
                                          style: customTextStyle(
                                            AppTextSizes.smallTextSize,
                                            AppColors.primaryOrange,
                                            FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if (controller.termsError.value != null)
                                Padding(
                                  padding: EdgeInsets.only(left: AppDimensions.padding10w),
                                  child: Text(
                                    controller.termsError.value!,
                                    style: customTextStyle(
                                      AppTextSizes.smallTextSize,
                                      AppColors.danger,
                                      FontWeight.w400,
                                    ),
                                  ),
                                ),
                            ],
                          )),
                          SizedBox(height: AppDimensions.padding10h),
                          PrimaryButton(
                            text: 'Register',
                            onPressed: controller.register,
                          ),
                          SizedBox(height: AppDimensions.padding10h),
                          Row(
                            children: [
                              const Expanded(child: Divider(color: AppColors.grey, thickness: 1.5)),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: AppDimensions.padding10w),
                                child: Container(
                                  height: 28,
                                  width: 28,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.grey,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Text(
                                    'OR',
                                    style: customTextStyle(12, AppColors.text, FontWeight.w400),
                                  ),
                                ),
                              ),
                              const Expanded(child: Divider(color: AppColors.grey, thickness: 1.5)),
                            ],
                          ),
                          SizedBox(height: AppDimensions.padding20h),
                          SecondaryButton(
                            text: 'Continue with Google',
                            iconPath: AppImages.google,
                            onPressed: controller.loginWithGoogle,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppDimensions.padding30h),
                    Center(
                      child: InkWell(
                        onTap: controller.goToLogin,
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "Already have an account? ",
                                style: customTextStyle(
                                  AppTextSizes.largeTextSize,
                                  AppColors.text,
                                  FontWeight.w400,
                                ),
                              ),
                              TextSpan(
                                text: 'Login',
                                style: customTextStyle(
                                  AppTextSizes.largeTextSize,
                                  AppColors.primaryOrange,
                                  FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: AppDimensions.padding30h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
