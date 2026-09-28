// File: lib/features/authentication/register/register_screen.dart
// Purpose: Screen for user registration, including name, email, and password fields with validation.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_images.dart';
import 'package:urban_services/core/constants/app_text_sizes.dart';
import 'package:urban_services/features/authentication/register/register_provider.dart';
import 'package:urban_services/routes/route_names.dart';
import 'package:urban_services/widgets/custom_text_field.dart';
import 'package:urban_services/widgets/custom_text_style.dart';
import 'package:urban_services/widgets/primary_button.dart';
import 'package:urban_services/widgets/secondary_button.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _nameFocusNode = FocusNode();
  final _mobileFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  @override
  void dispose() {
    for (final c in [
      _nameController,
      _mobileController,
      _emailController,
      _passwordController,
      _confirmPasswordController,
    ]) {
      c.dispose();
    }
    for (final f in [
      _nameFocusNode,
      _mobileFocusNode,
      _emailFocusNode,
      _passwordFocusNode,
      _confirmPasswordFocusNode,
    ]) {
      f.dispose();
    }
    super.dispose();
  }

  void _register() => ref
      .read(registerProvider.notifier)
      .register(
        RegisterForm(
          name: _nameController.text,
          mobile: _mobileController.text,
          email: _emailController.text,
          password: _passwordController.text,
          confirmPassword: _confirmPasswordController.text,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registerProvider);

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: SafeArea(
        child: SingleChildScrollView(
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

                    // Registration Form Card
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
                          // Name Input
                          CustomTextField(
                            hintText: 'Enter Name',
                            prefixIconPath: AppImages.name,
                            controller: _nameController,
                            focusNode: _nameFocusNode,
                            textInputAction: TextInputAction.next,
                            errorText: state.nameError,
                          ),
                          SizedBox(height: AppDimensions.padding20h),

                          // Mobile Number Input
                          CustomTextField(
                            hintText: 'Enter Mobile Number',
                            prefixIconPath: AppImages.mobile,
                            controller: _mobileController,
                            focusNode: _mobileFocusNode,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            errorText: state.mobileError,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                          SizedBox(height: AppDimensions.padding20h),

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
                            textInputAction: TextInputAction.next,
                            errorText: state.passwordError,
                          ),
                          SizedBox(height: AppDimensions.padding20h),

                          // Confirm Password Input
                          CustomTextField(
                            hintText: 'Confirm Password',
                            prefixIconPath: AppImages.password,
                            isPassword: true,
                            controller: _confirmPasswordController,
                            focusNode: _confirmPasswordFocusNode,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _register(),
                            errorText: state.confirmPasswordError,
                          ),

                          SizedBox(height: AppDimensions.padding10h),

                          // Terms and Conditions Section
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: state.agreeToTerms,
                                    onChanged: (val) => ref
                                        .read(registerProvider.notifier)
                                        .setAgreeToTerms(val ?? false),
                                    activeColor: AppColors.primary,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    visualDensity: const VisualDensity(
                                      horizontal: -4,
                                      vertical: -4,
                                    ),
                                  ),
                                  SizedBox(width: AppDimensions.padding5w),
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
                              if (state.termsError != null)
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: AppDimensions.padding10w,
                                  ),
                                  child: Text(
                                    state.termsError!,
                                    style: customTextStyle(
                                      AppTextSizes.smallTextSize,
                                      AppColors.danger,
                                      FontWeight.w400,
                                    ),
                                  ),
                                ),
                            ],
                          ),

                          SizedBox(height: AppDimensions.padding10h),

                          // Register Action
                          PrimaryButton(
                            text: 'Register',
                            isLoading: state.isLoading,
                            onPressed: _register,
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

                          // Social Registration Action
                          SecondaryButton(
                            text: 'Continue with Google',
                            iconPath: AppImages.google,
                            isLoading: state.isLoading,
                            onPressed: ref
                                .read(registerProvider.notifier)
                                .loginWithGoogle,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: AppDimensions.padding30h),

                    // Navigation to Login: Register is always opened from
                    // Login, so go back to it instead of stacking another.
                    Center(
                      child: InkWell(
                        onTap: () => context.canPop()
                            ? context.pop()
                            : context.go(RouteNames.loginScreen),
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
