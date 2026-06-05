import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_images.dart';
import 'package:urban_services/core/constants/app_text_sizes.dart';
import 'package:urban_services/features/authentication/login/login_controller.dart';
import 'package:urban_services/routes/route_names.dart';
import 'package:urban_services/widgets/custom_text_field.dart';
import 'package:urban_services/widgets/custom_text_style.dart';
import 'package:urban_services/widgets/primary_button.dart';
import 'package:urban_services/widgets/secondary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final controller = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: SingleChildScrollView(
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
                    'Welcome Back',
                    style: customTextStyle(
                      AppTextSizes.headingTextSize,
                      AppColors.black,
                      FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: AppDimensions.padding5h),
                  Text(
                    'Login to continue',
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
                      borderRadius: .circular(AppDimensions.radius22r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.1),
                          blurRadius: 6,
                          spreadRadius: 2,
                          offset: Offset(0,3),
                        ),
                      ]
                    ),
                    padding: .all(AppDimensions.radius20r),
                    child: Column(
                      children: [
                        Obx(() => CustomTextField(
                          hintText: 'Enter Mobile Number',
                          prefixIconPath: AppImages.mobile,
                          controller: controller.mobileController,
                          focusNode: controller.mobileFocusNode,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          errorText: controller.mobileError.value,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        )),
                        SizedBox(height: AppDimensions.padding20h),
                        Obx(() => CustomTextField(
                          hintText: 'Enter Password',
                          prefixIconPath: AppImages.password,
                          isPassword: true,
                          controller: controller.passwordController,
                          focusNode: controller.passwordFocusNode,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => controller.login(),
                          errorText: controller.passwordError.value,
                        )),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {

                            },
                            child: Text(
                              'Forgot Password?',
                              style: customTextStyle(
                                AppTextSizes.largeMediumTextSize,
                                AppColors.primaryOrange,
                                FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        PrimaryButton(
                          text: 'Login',
                          onPressed: controller.login,
                        ),
                        SizedBox(height: AppDimensions.padding10h),
                        Row(
                          children: [
                            const Expanded(child: Divider(color: AppColors.grey,thickness: 1.5,)),
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
                                padding: .all(AppDimensions.radius2r),
                                child: Text(
                                  'OR',
                                  style: customTextStyle(
                                    12,
                                    AppColors.text,
                                    FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                            const Expanded(child: Divider(color: AppColors.grey,thickness: 1.5,)),
                          ],
                        ),
                        SizedBox(height: AppDimensions.padding20h),
                        SecondaryButton(
                          text: 'Continue with Google',
                          iconPath: AppImages.google,
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppDimensions.padding30h),
                  Center(
                    child: InkWell(
                      onTap: () => Get.toNamed(RouteNames.registerScreen),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Don't have an account? ",
                              style: customTextStyle(
                                AppTextSizes.largeTextSize,
                                AppColors.text,
                                FontWeight.w400,
                              ),
                            ),
                            TextSpan(
                              text: 'Sign Up',
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
    );
  }
}
