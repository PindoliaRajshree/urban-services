// File: lib/features/home/complete_profile/user_profile_view_screen.dart
// Purpose: Read-only view of a user's saved profile, opened from Home and
// the Profile tab once the profile is complete. Each section's "Edit" opens
// the profile form; the form refreshes userProfileStatusProvider after
// saving, so this screen updates on return.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_images.dart';
import 'package:urban_services/core/constants/app_text_sizes.dart';
import 'package:urban_services/core/network/api_failure.dart';
import 'package:urban_services/features/home/complete_profile/models/user_profile.dart';
import 'package:urban_services/features/home/complete_profile/user_complete_profile_provider.dart';
import 'package:urban_services/features/home/complete_profile/user_profile_repository.dart';
import 'package:urban_services/features/home_provider/complete_profile/models/provider_profile.dart';
import 'package:urban_services/features/profile_common/basic_info.dart';
import 'package:urban_services/routes/route_names.dart';
import 'package:urban_services/widgets/common_app_bar.dart';
import 'package:urban_services/widgets/custom_text_style.dart';
import 'package:urban_services/widgets/profile_avatar.dart';
import 'package:urban_services/widgets/profile_view_widgets.dart';

/// Where tapping "my profile" (Home avatar, Profile tab) goes for a user:
/// the read-only view once completed, otherwise the form.
String userProfileRoute(UserProfile? profile) =>
    profile?.isProfileCompleted == true
    ? RouteNames.userProfileView
    : RouteNames.completeProfile;

class UserProfileViewScreen extends ConsumerWidget {
  const UserProfileViewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileStatusProvider);

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.padding20w,
              ),
              child: const CommonAppBar(
                title: 'My Profile',
                showMoreIcon: false,
              ),
            ),
            Expanded(
              child: switch (profile) {
                AsyncData(value: final p) when p.isProfileCompleted =>
                  _ProfileDetails(
                    profile: p,
                    onEdit: () => context.push(RouteNames.completeProfile),
                    onRefresh: () =>
                        ref.refresh(userProfileStatusProvider.future),
                  ),
                // Not complete yet — nothing to view.
                AsyncData() => ProfileMessage(
                  title: "Your profile isn't complete yet",
                  buttonText: 'Complete Profile',
                  onPressed: () =>
                      context.pushReplacement(RouteNames.completeProfile),
                ),
                AsyncError(:final error) when !profile.isLoading =>
                  ProfileMessage(
                    title: "Couldn't load your profile",
                    message: error is ApiFailure
                        ? error.message
                        : 'Something went wrong. Please try again.',
                    buttonText: 'Retry',
                    onPressed: () => ref.invalidate(userProfileStatusProvider),
                  ),
                _ => const Center(child: CircularProgressIndicator()),
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileDetails extends StatelessWidget {
  const _ProfileDetails({
    required this.profile,
    required this.onEdit,
    required this.onRefresh,
  });

  final UserProfile profile;
  final VoidCallback onEdit;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final p = profile;
    final mobile = p.mobile;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          AppDimensions.padding20w,
          AppDimensions.padding10h,
          AppDimensions.padding20w,
          AppDimensions.padding30h,
        ),
        children: [
          _Header(profile: p),
          ProfileSection(
            icon: AppImages.person,
            title: 'Basic Information',
            onEdit: onEdit,
            children: [
              ProfileInfoRow(
                label: 'Mobile',
                value: mobile == null ? null : '+91 $mobile',
                verified: mobile != null && p.isMobileVerified,
              ),
              ProfileInfoRow(label: 'Email', value: p.email),
              ProfileInfoRow(
                label: 'Gender',
                value: UserCompleteProfileNotifier.labelFor(
                  UserCompleteProfileNotifier.genderOptions,
                  p.gender,
                ),
              ),
              ProfileInfoRow(
                label: 'Date of Birth',
                value: p.dateOfBirth == null ? null : formatDob(p.dateOfBirth!),
              ),
            ],
          ),
          ProfileSection(
            icon: AppImages.location,
            title: 'Address Information',
            onEdit: onEdit,
            children: [
              ProfileInfoRow(
                label: 'Address',
                value: p.fullAddress,
                multiline: true,
              ),
              ProfileInfoRow(
                label: 'City / State',
                value: [p.city, p.state].whereType<String>().join(', '),
              ),
              ProfileInfoRow(label: 'Country', value: p.country),
              ProfileInfoRow(label: 'Pincode', value: p.pincode),
            ],
          ),
        ],
      ),
    );
  }
}

/// Photo, name and the "Profile completed" badge.
class _Header extends StatelessWidget {
  const _Header({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return ProfileCard(
      child: Row(
        children: [
          ProfileAvatar(
            height: AppDimensions.containerHeight70h,
            width: AppDimensions.containerWidth70w,
            imageUrl: ProviderProfile.fileUrl(profile.profileImage),
          ),
          SizedBox(width: AppDimensions.padding15w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name ?? 'Your profile',
                  overflow: TextOverflow.ellipsis,
                  style: customTextStyle(
                    AppTextSizes.largeTextSize,
                    AppColors.text,
                    FontWeight.w600,
                  ),
                ),
                SizedBox(height: AppDimensions.padding6h),
                const ProfileCompletedBadge(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
