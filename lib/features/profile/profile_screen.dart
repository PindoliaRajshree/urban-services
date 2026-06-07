// File: lib/features/profile/profile_screen.dart
// Purpose: Screen for displaying user profile details and account options.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_images.dart';
import 'package:urban_services/core/constants/app_text_sizes.dart';
import 'package:urban_services/features/profile/profile_controller.dart';
import 'package:urban_services/widgets/common_app_bar.dart';
import 'package:urban_services/widgets/custom_text_style.dart';
import 'package:urban_services/widgets/logout_dialog.dart';
import 'package:urban_services/widgets/profile_option_tile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Initialize ProfileController for logic management
  final controller = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.height < 720;
    
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: SafeArea(
        child: isSmall ? Padding(
          padding: EdgeInsets.only(
            top: AppDimensions.padding15h,
            left: AppDimensions.padding20w,
            right: AppDimensions.padding20w,
          ),
          child: ListView(
            children: [
              // Reusable AppBar with title and more icon
              CommonAppBar(
                title: 'Profile Screen',
                showMoreIcon: true,
                onMorePressed: () {
                  // Handle more action
                },
              ),
              SizedBox(height: AppDimensions.padding15h),

              // Profile Details Section: Avatar and User Info
              Row(
                children: [
                  // User Avatar Container
                  Container(
                    height: AppDimensions.containerHeight60h,
                    width: AppDimensions.containerWidth60w,
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage(AppImages.image),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  SizedBox(width: AppDimensions.padding15w),

                  // User Info: Name, Rating, and Category
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ram Kumar Yadav',
                          style: customTextStyle(
                            AppTextSizes.largeTextSize,
                            AppColors.text,
                            FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: AppDimensions.padding4h),
                        Row(
                          children: [
                            Image.asset(
                              AppImages.ratingStar,
                              height: AppDimensions.containerHeight15h,
                              width: AppDimensions.containerWidth15w,
                            ),
                            SizedBox(width: AppDimensions.padding2w),
                            Image.asset(
                              AppImages.ratingStar,
                              height: AppDimensions.containerHeight15h,
                              width: AppDimensions.containerWidth15w,
                            ),
                            SizedBox(width: AppDimensions.padding5w),
                            Text(
                              '4.7 (128)',
                              style: customTextStyle(
                                AppTextSizes.smallTextSize,
                                AppColors.darkGrey,
                                FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppDimensions.padding4h),
                        Text(
                          'Deep Cleaning',
                          style: customTextStyle(
                            AppTextSizes.largeMediumTextSize,
                            AppColors.text,
                            FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Action Icons: Call and Chat
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        AppImages.ringerVolume,
                        height: AppDimensions.containerHeight30h,
                        width: AppDimensions.containerWidth30w,
                      ),
                      SizedBox(width: AppDimensions.padding20w),
                      Image.asset(
                        AppImages.chatBubble,
                        height: AppDimensions.containerHeight30h,
                        width: AppDimensions.containerWidth30w,
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: AppDimensions.padding20h),

              // Account Options Menu
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: AppDimensions.padding15h,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppDimensions.radius18r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.15),
                      blurRadius: 4,
                      spreadRadius: 0,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    ProfileOptionTile(
                      icon: AppImages.person,
                      title: 'Profile',
                      onTap: () {},
                    ),
                    ProfileOptionTile(
                      icon: AppImages.savedAddress,
                      title: 'Saved Address',
                      onTap: () {},
                    ),
                    ProfileOptionTile(
                      icon: AppImages.paymentMethods,
                      title: 'Payment Methods',
                      onTap: () {},
                    ),
                    ProfileOptionTile(
                      icon: AppImages.helpSupport,
                      title: 'Help & Support',
                      onTap: () {},
                    ),
                    ProfileOptionTile(
                      icon: AppImages.referEarn,
                      title: 'Refer & Earn',
                      onTap: () {},
                    ),
                    ProfileOptionTile(
                      icon: AppImages.aboutUs,
                      title: 'About Us',
                      onTap: () {},
                    ),
                    ProfileOptionTile(
                      icon: AppImages.setting,
                      title: 'Settings',
                      onTap: () {},
                      showDivider: false,
                    ),
                    SizedBox(height: AppDimensions.padding10h),

                    // Logout Button: Triggers confirmation dialog
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: AppDimensions.padding10h,
                      ),
                      child: InkWell(
                        onTap: () {
                          // Show custom logout confirmation dialog
                          Get.dialog(
                            const LogoutDialog(),
                            barrierDismissible: false,
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              AppImages.logout,
                              height: AppDimensions.containerHeight25h,
                              width: AppDimensions.containerWidth25w,
                              color: AppColors.danger,
                            ),
                            SizedBox(width: AppDimensions.padding8w),
                            Text(
                              'Logout',
                              style: customTextStyle(
                                AppTextSizes.largeTextSize,
                                AppColors.danger,
                                FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppDimensions.containerHeight90h,)
            ],
          ),
        ) : Padding(
          padding: EdgeInsets.only(
            top: AppDimensions.padding15h,
            left: AppDimensions.padding20w,
            right: AppDimensions.padding20w,
          ),
          child: Column(
            children: [
              // Reusable AppBar with title and more icon
              CommonAppBar(
                title: 'Profile Screen',
                showMoreIcon: true,
                onMorePressed: () {
                  // Handle more action
                },
              ),
              SizedBox(height: AppDimensions.padding15h),

              // Profile Details Section: Avatar and User Info
              Row(
                children: [
                  // User Avatar Container
                  Container(
                    height: AppDimensions.containerHeight60h,
                    width: AppDimensions.containerWidth60w,
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage(AppImages.image),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  SizedBox(width: AppDimensions.padding15w),

                  // User Info: Name, Rating, and Category
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ram Kumar Yadav',
                          style: customTextStyle(
                            AppTextSizes.largeTextSize,
                            AppColors.text,
                            FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: AppDimensions.padding4h),
                        Row(
                          children: [
                            Image.asset(
                              AppImages.ratingStar,
                              height: AppDimensions.containerHeight15h,
                              width: AppDimensions.containerWidth15w,
                            ),
                            SizedBox(width: AppDimensions.padding2w),
                            Image.asset(
                              AppImages.ratingStar,
                              height: AppDimensions.containerHeight15h,
                              width: AppDimensions.containerWidth15w,
                            ),
                            SizedBox(width: AppDimensions.padding5w),
                            Text(
                              '4.7 (128)',
                              style: customTextStyle(
                                AppTextSizes.smallTextSize,
                                AppColors.darkGrey,
                                FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppDimensions.padding4h),
                        Text(
                          'Deep Cleaning',
                          style: customTextStyle(
                            AppTextSizes.largeMediumTextSize,
                            AppColors.text,
                            FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Action Icons: Call and Chat
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        AppImages.ringerVolume,
                        height: AppDimensions.containerHeight30h,
                        width: AppDimensions.containerWidth30w,
                      ),
                      SizedBox(width: AppDimensions.padding20w),
                      Image.asset(
                        AppImages.chatBubble,
                        height: AppDimensions.containerHeight30h,
                        width: AppDimensions.containerWidth30w,
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: AppDimensions.padding20h),

              // Account Options Menu
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: AppDimensions.padding15h,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppDimensions.radius18r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.15),
                      blurRadius: 4,
                      spreadRadius: 0,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    ProfileOptionTile(
                      icon: AppImages.person,
                      title: 'Profile',
                      onTap: () {},
                    ),
                    ProfileOptionTile(
                      icon: AppImages.savedAddress,
                      title: 'Saved Address',
                      onTap: () {},
                    ),
                    ProfileOptionTile(
                      icon: AppImages.paymentMethods,
                      title: 'Payment Methods',
                      onTap: () {},
                    ),
                    ProfileOptionTile(
                      icon: AppImages.helpSupport,
                      title: 'Help & Support',
                      onTap: () {},
                    ),
                    ProfileOptionTile(
                      icon: AppImages.referEarn,
                      title: 'Refer & Earn',
                      onTap: () {},
                    ),
                    ProfileOptionTile(
                      icon: AppImages.aboutUs,
                      title: 'About Us',
                      onTap: () {},
                    ),
                    ProfileOptionTile(
                      icon: AppImages.setting,
                      title: 'Settings',
                      onTap: () {},
                      showDivider: false,
                    ),
                    SizedBox(height: AppDimensions.padding10h),

                    // Logout Button: Triggers confirmation dialog
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: AppDimensions.padding10h,
                      ),
                      child: InkWell(
                        onTap: () {
                          // Show custom logout confirmation dialog
                          Get.dialog(
                            const LogoutDialog(),
                            barrierDismissible: false,
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              AppImages.logout,
                              height: AppDimensions.containerHeight25h,
                              width: AppDimensions.containerWidth25w,
                              color: AppColors.danger,
                            ),
                            SizedBox(width: AppDimensions.padding8w),
                            Text(
                              'Logout',
                              style: customTextStyle(
                                AppTextSizes.largeTextSize,
                                AppColors.danger,
                                FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
