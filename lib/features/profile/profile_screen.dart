// File: lib/features/profile/profile_screen.dart
// Purpose: Screen for displaying user profile details and account options.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_images.dart';
import 'package:urban_services/core/constants/app_text_sizes.dart';
import 'package:urban_services/core/session/session_provider.dart';
import 'package:urban_services/routes/route_args.dart';
import 'package:urban_services/routes/route_names.dart';
import 'package:urban_services/widgets/common_app_bar.dart';
import 'package:urban_services/widgets/custom_text_style.dart';
import 'package:urban_services/widgets/logout_dialog.dart';
import 'package:urban_services/widgets/profile_option_tile.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final isProvider = session.effectiveRole.isProvider;
    final subtitle = [
      session.email,
      session.mobile,
    ].firstWhere((v) => v != null && v.trim().isNotEmpty, orElse: () => null);

    final children = <Widget>[
      // Reusable AppBar with title and more icon. Profile is a tab root, so
      // there's no back button.
      CommonAppBar(
        title: 'Profile',
        showBackButton: false,
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

          // User Info: Name and email (or mobile)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.name?.trim().isNotEmpty == true
                      ? session.name!.trim()
                      : 'Your profile',
                  overflow: TextOverflow.ellipsis,
                  style: customTextStyle(
                    AppTextSizes.largeTextSize,
                    AppColors.text,
                    FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: AppDimensions.padding4h),
                  Text(
                    subtitle,
                    overflow: TextOverflow.ellipsis,
                    style: customTextStyle(
                      AppTextSizes.largeMediumTextSize,
                      AppColors.darkGrey,
                      FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      SizedBox(height: AppDimensions.padding20h),

      // Account Options Menu
      Container(
        padding: EdgeInsets.symmetric(vertical: AppDimensions.padding15h),
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
              onTap: () => context.push(
                isProvider
                    ? RouteNames.completeProviderProfile
                    : RouteNames.completeProfile,
              ),
            ),
            // Only users (customers) have a service address.
            if (!isProvider)
              ProfileOptionTile(
                icon: AppImages.savedAddress,
                title: 'Saved Address',
                onTap: () => context.push(
                  RouteNames.addressScreen,
                  extra: const AddressArgs(manage: true),
                ),
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
              padding: EdgeInsets.symmetric(vertical: AppDimensions.padding10h),
              child: InkWell(
                onTap: () {
                  // Show custom logout confirmation dialog
                  showDialog<void>(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => const LogoutDialog(),
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
    ];

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            top: AppDimensions.padding15h,
            left: AppDimensions.padding20w,
            right: AppDimensions.padding20w,
          ),
          // Always scrollable, so large system fonts can't overflow it. The
          // bottom spacer keeps the last item clear of the bottom bar.
          child: ListView(
            children: [
              ...children,
              SizedBox(height: AppDimensions.containerHeight90h),
            ],
          ),
        ),
      ),
    );
  }
}
