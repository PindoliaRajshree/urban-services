// File: lib/features/authentication/splash/welcome_screen.dart
// Purpose: Welcome landing page for choosing User or Provider role.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_images.dart';
import 'package:urban_services/core/constants/app_text_sizes.dart';
import 'package:urban_services/routes/route_names.dart';
import 'package:urban_services/widgets/custom_text_style.dart';
import 'package:urban_services/widgets/primary_button.dart';
import 'package:urban_services/widgets/secondary_button.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.height < 720;

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: SafeArea(
        child: isSmall
            ? SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: AppDimensions.padding20h,
                  ),
                  child: Column(
                    children: [
                      // --- Header Logo/Icon Section ---
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDimensions.padding30w,
                        ),
                        child: Row(
                          mainAxisAlignment: .start,
                          children: [
                            Image.asset(
                              AppImages.splashVector,
                              height: AppDimensions.containerHeight50h,
                              width: AppDimensions.containerWidth50w,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: AppDimensions.padding20h),

                      // --- Welcome Title Section ---
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDimensions.padding30w,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'All Home Services\nAt',
                                    style: customTextStyle(
                                      AppTextSizes.headingTextSize,
                                      AppColors.black,
                                      FontWeight.w600,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' One Place',
                                    style: customTextStyle(
                                      AppTextSizes.headingTextSize,
                                      AppColors.primary,
                                      FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: AppDimensions.padding10h),

                      // --- Accent Line / Indicator ---
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDimensions.padding30w,
                        ),
                        child: Row(
                          mainAxisAlignment: .start,
                          children: [
                            Container(
                              height: AppDimensions.containerHeight4h,
                              width: AppDimensions.containerWidth70w,
                              decoration: BoxDecoration(
                                gradient: AppColors.gradient,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: AppDimensions.padding10h),

                      // --- Description Section ---
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDimensions.padding30w,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Trusted professionals for your \nhome and office needs.',
                              style: customTextStyle(
                                AppTextSizes.largeTextSize,
                                AppColors.black,
                                FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: AppDimensions.padding10h),

                      // --- Main Illustration Section ---
                      Image.asset(AppImages.cleaning, fit: BoxFit.fill),
                      SizedBox(height: AppDimensions.padding20h),

                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDimensions.padding30w,
                        ),
                        child: PrimaryButton(
                          text: 'Continue as User',
                          onPressed: () {
                            Get.toNamed(RouteNames.loginScreen);
                          },
                        ),
                      ),
                      SizedBox(height: AppDimensions.padding15h),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDimensions.padding30w,
                        ),
                        child: SecondaryButton(
                          text: 'Continue as Provider',
                          onPressed: () {
                            Get.toNamed(RouteNames.loginScreen);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : Padding(
                padding: EdgeInsets.symmetric(
                  vertical: AppDimensions.padding20h,
                ),
                child: Column(
                  children: [
                    // --- Header Logo/Icon Section ---
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.padding30w,
                      ),
                      child: Row(
                        mainAxisAlignment: .start,
                        children: [
                          Image.asset(
                            AppImages.splashVector,
                            height: AppDimensions.containerHeight50h,
                            width: AppDimensions.containerWidth50w,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppDimensions.padding20h),

                    // --- Welcome Title Section ---
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.padding30w,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'All Home Services\nAt',
                                  style: customTextStyle(
                                    AppTextSizes.headingTextSize,
                                    AppColors.black,
                                    FontWeight.w600,
                                  ),
                                ),
                                TextSpan(
                                  text: ' One Place',
                                  style: customTextStyle(
                                    AppTextSizes.headingTextSize,
                                    AppColors.primary,
                                    FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppDimensions.padding10h),

                    // --- Accent Line / Indicator ---
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.padding30w,
                      ),
                      child: Row(
                        mainAxisAlignment: .start,
                        children: [
                          Container(
                            height: AppDimensions.containerHeight4h,
                            width: AppDimensions.containerWidth70w,
                            decoration: BoxDecoration(
                              gradient: AppColors.gradient,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppDimensions.padding10h),

                    // --- Description Section ---
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.padding30w,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Trusted professionals for your \nhome and office needs.',
                            style: customTextStyle(
                              AppTextSizes.largeTextSize,
                              AppColors.black,
                              FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppDimensions.padding10h),

                    // --- Main Illustration Section ---
                    Image.asset(AppImages.cleaning, fit: BoxFit.fill),
                    SizedBox(height: AppDimensions.padding20h),

                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.padding30w,
                      ),
                      child: PrimaryButton(
                        text: 'Continue as User',
                        onPressed: () {
                          Get.toNamed(RouteNames.loginScreen);
                        },
                      ),
                    ),
                    SizedBox(height: AppDimensions.padding15h),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.padding30w,
                      ),
                      child: SecondaryButton(
                        text: 'Continue as Provider',
                        onPressed: () {
                          Get.toNamed(RouteNames.loginScreen);
                        },
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
