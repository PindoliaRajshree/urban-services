// File: lib/features/authentication/login/login_screen.dart
// Purpose: Screen for user authentication via email and password.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_images.dart';
import 'package:urban_services/core/constants/app_text_sizes.dart';
import 'package:urban_services/features/authentication/login/login_provider.dart';
import 'package:urban_services/routes/route_names.dart';
import 'package:urban_services/widgets/custom_text_field.dart';
import 'package:urban_services/widgets/custom_text_style.dart';
import 'package:urban_services/widgets/primary_button.dart';
import 'package:urban_services/widgets/secondary_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _login() => ref
      .read(loginProvider.notifier)
      .login(email: _emailController.text, password: _passwordController.text);

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginProvider);

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Image Section
            Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  children: [
                    Image.asset(AppImages.vector, fit: BoxFit.fill),
                    SizedBox(height: AppDimensions.containerHeight40h),
                  ],
                ),
                Positioned(
                  top: AppDimensions.padding70h,
                  child: Image.asset(AppImages.appLogo, fit: BoxFit.contain),
                ),
              ],
            ),

            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.padding20w,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Headers
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

                  // Login Form Card
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radius22r,
                      ),
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
                        // Email Input
                        CustomTextField(
                          hintText: 'Enter Email',
                          prefixIconPath: AppImages.email,
                          controller: _emailController,
                          focusNode: _emailFocusNode,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          errorText: state.emailError,
                        ),
                        SizedBox(height: AppDimensions.padding20h),

                        // Password Input
                        CustomTextField(
                          hintText: 'Enter Password',
                          prefixIconPath: AppImages.password,
                          isPassword: true,
                          controller: _passwordController,
                          focusNode: _passwordFocusNode,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _login(),
                          errorText: state.passwordError,
                        ),

                        // Forgot Password Link
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () =>
                                context.push(RouteNames.forgotPasswordScreen),
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

                        // Login Action
                        PrimaryButton(
                          text: 'Login',
                          isLoading: state.isLoading,
                          onPressed: _login,
                        ),

                        SizedBox(height: AppDimensions.padding10h),

                        // Divider Section
                        Row(
                          children: [
                            const Expanded(
                              child: Divider(
                                color: AppColors.grey,
                                thickness: 1.5,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppDimensions.padding10w,
                              ),
                              child: Container(
                                height: AppDimensions.containerHeight28h,
                                width: AppDimensions.containerWidth28w,
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
                                  style: customTextStyle(
                                    AppTextSizes.smallTextSize,
                                    AppColors.text,
                                    FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                            const Expanded(
                              child: Divider(
                                color: AppColors.grey,
                                thickness: 1.5,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: AppDimensions.padding20h),

                        // Social Login Action
                        SecondaryButton(
                          text: 'Continue with Google',
                          iconPath: AppImages.google,
                          isLoading: state.isLoading,
                          onPressed: ref
                              .read(loginProvider.notifier)
                              .loginWithGoogle,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: AppDimensions.padding30h),

                  // Navigation to Registration
                  Center(
                    child: InkWell(
                      onTap: () => context.push(RouteNames.registerScreen),
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
