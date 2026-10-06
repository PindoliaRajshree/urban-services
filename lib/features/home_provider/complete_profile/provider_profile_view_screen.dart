// File: lib/features/home_provider/complete_profile/provider_profile_view_screen.dart
// Purpose: Read-only view of a provider's saved profile, opened from the
// Profile tab once the profile is complete. Each section has an "Edit"
// action that opens the profile wizard on that section's page; the wizard
// refreshes providerProfileStatusProvider after saving, so this screen
// updates on return. Sensitive numbers (Aadhaar, PAN, account) are masked.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_images.dart';
import 'package:urban_services/core/constants/app_text_sizes.dart';
import 'package:urban_services/core/network/api_failure.dart';
import 'package:urban_services/features/home_provider/complete_profile/complete_profile_provider.dart';
import 'package:urban_services/features/home_provider/complete_profile/complete_profile_repository.dart';
import 'package:urban_services/features/home_provider/complete_profile/models/provider_profile.dart';
import 'package:urban_services/features/home_provider/complete_profile/service_type_provider.dart';
import 'package:urban_services/features/profile_common/basic_info.dart';
import 'package:urban_services/routes/route_args.dart';
import 'package:urban_services/routes/route_names.dart';
import 'package:urban_services/widgets/common_app_bar.dart';
import 'package:urban_services/widgets/custom_text_style.dart';
import 'package:urban_services/widgets/document_image_viewer.dart';
import 'package:urban_services/widgets/icon_header.dart';
import 'package:urban_services/widgets/primary_button.dart';
import 'package:urban_services/widgets/profile_avatar.dart';

/// Shows all but the last [visible] characters as "•", e.g. "•••• 4321".
String maskTail(String? value, {int visible = 4}) {
  final v = value?.replaceAll(' ', '') ?? '';
  if (v.isEmpty) return '';
  if (v.length <= visible) return v;
  return '•••• ${v.substring(v.length - visible)}';
}

/// Where tapping "my profile" (Home avatar, Profile tab) goes for a
/// provider: the read-only view once completed, otherwise the wizard.
String providerProfileRoute(ProviderProfile? profile) =>
    profile?.isProfileCompleted == true
    ? RouteNames.providerProfileView
    : RouteNames.completeProviderProfile;

class ProviderProfileViewScreen extends ConsumerWidget {
  const ProviderProfileViewScreen({super.key});

  // Wizard pages (see CompleteProfileScreen).
  static const int _basicInfoStep = 0;
  static const int _serviceDetailsStep = 1;
  static const int _bankDetailsStep = 2;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(providerProfileStatusProvider);

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
                AsyncData(value: final p?) => _ProfileDetails(
                  profile: p,
                  onEdit: (step) => context.push(
                    RouteNames.completeProviderProfile,
                    extra: ProviderProfileEditArgs(initialStep: step),
                  ),
                  onRefresh: () =>
                      ref.refresh(providerProfileStatusProvider.future),
                ),
                // Not submitted yet — nothing to view.
                AsyncData() => _Message(
                  title: "Your profile isn't complete yet",
                  buttonText: 'Complete Profile',
                  onPressed: () => context.pushReplacement(
                    RouteNames.completeProviderProfile,
                  ),
                ),
                AsyncError(:final error) when !profile.isLoading => _Message(
                  title: "Couldn't load your profile",
                  message: error is ApiFailure
                      ? error.message
                      : 'Something went wrong. Please try again.',
                  buttonText: 'Retry',
                  onPressed: () =>
                      ref.invalidate(providerProfileStatusProvider),
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

class _ProfileDetails extends ConsumerWidget {
  const _ProfileDetails({
    required this.profile,
    required this.onEdit,
    required this.onRefresh,
  });

  final ProviderProfile profile;
  final ValueChanged<int> onEdit;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = profile;
    final categoryId = p.serviceTypeId;
    final category = ref
        .watch(serviceTypesProvider)
        .value
        ?.where((s) => s.id == categoryId)
        .firstOrNull
        ?.name;
    final subService = categoryId == null
        ? null
        : ref
              .watch(subServiceTypesProvider(categoryId))
              .value
              ?.where((s) => s.id == p.subServiceTypeId)
              .firstOrNull
              ?.name;

    final years = p.experienceYears;
    final pricing = ProviderProfileNotifier.labelFor(
      ProviderProfileNotifier.pricingOptions,
      p.pricingType,
    );
    final price = p.startingPrice == null
        ? null
        : '₹${p.startingPrice}${pricing == null ? '' : ' ${pricing.toLowerCase()}'}';
    final mobile = p.preferredMobile;

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
          _Header(profile: p, category: category),

          _Section(
            icon: AppImages.person,
            title: 'Basic Information',
            onEdit: () => onEdit(ProviderProfileViewScreen._basicInfoStep),
            children: [
              _InfoRow(
                label: 'Mobile',
                value: mobile == null ? null : '+91 $mobile',
                verified: mobile != null && mobile == p.mobileNumber,
              ),
              _InfoRow(label: 'Email', value: p.email),
              _InfoRow(
                label: 'Gender',
                value: ProviderProfileNotifier.labelFor(
                  ProviderProfileNotifier.genderOptions,
                  p.gender?.toLowerCase(),
                ),
              ),
              _InfoRow(
                label: 'Date of Birth',
                value: p.dateOfBirth == null ? null : formatDob(p.dateOfBirth!),
              ),
              const _SubHeading('Documents'),
              _InfoRow(
                label: 'Aadhaar Number',
                value: maskTail(p.aadhaarNumber),
              ),
              _InfoRow(label: 'PAN Number', value: maskTail(p.panNumber)),
              SizedBox(height: AppDimensions.padding10h),
              Row(
                children: [
                  _DocumentThumb(
                    title: 'Aadhaar Front',
                    url: ProviderProfile.fileUrl(p.aadhaarFrontImage),
                  ),
                  SizedBox(width: AppDimensions.padding10w),
                  _DocumentThumb(
                    title: 'Aadhaar Back',
                    url: ProviderProfile.fileUrl(p.aadhaarBackImage),
                  ),
                  SizedBox(width: AppDimensions.padding10w),
                  _DocumentThumb(
                    title: 'PAN Card',
                    url: ProviderProfile.fileUrl(p.panImage),
                  ),
                ],
              ),
            ],
          ),

          _Section(
            icon: AppImages.service,
            title: 'Service Details',
            onEdit: () => onEdit(ProviderProfileViewScreen._serviceDetailsStep),
            children: [
              _InfoRow(label: 'Category', value: category),
              _InfoRow(label: 'Sub Service', value: subService),
              _InfoRow(
                label: 'Experience',
                value: years == null
                    ? null
                    : years >= 5
                    ? '5+ years'
                    : '$years ${years == 1 ? 'year' : 'years'}',
              ),
              _InfoRow(label: 'Starting Price', value: price),
              _InfoRow(
                label: 'Work Type',
                value: ProviderProfileNotifier.labelFor(
                  ProviderProfileNotifier.workTypeOptions,
                  p.availabilityType,
                ),
              ),
              _InfoRow(label: 'Team Size', value: p.teamSize?.toString()),
              _InfoRow(label: 'About', value: p.bio, multiline: true),
              const _SubHeading('Service Area'),
              _InfoRow(label: 'Address', value: p.address, multiline: true),
              _InfoRow(
                label: 'City / State',
                value: [p.city, p.state].whereType<String>().join(', '),
              ),
              _InfoRow(label: 'Pincode', value: p.pincode),
              _InfoRow(
                label: 'Service Radius',
                value: p.serviceAreaKm == null ? null : '${p.serviceAreaKm} km',
              ),
            ],
          ),

          _Section(
            icon: AppImages.creditDebitCard,
            title: 'Bank Details',
            onEdit: () => onEdit(ProviderProfileViewScreen._bankDetailsStep),
            children: [
              _InfoRow(label: 'Account Holder', value: p.accountHolderName),
              _InfoRow(label: 'Bank', value: p.bankName),
              _InfoRow(
                label: 'Account Number',
                value: maskTail(p.accountNumber),
              ),
              _InfoRow(label: 'IFSC Code', value: p.ifscCode?.toUpperCase()),
              _InfoRow(label: 'UPI ID', value: p.upiId),
            ],
          ),
        ],
      ),
    );
  }
}

/// Divides two groups of rows inside one section card.
class _SubHeading extends StatelessWidget {
  const _SubHeading(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: AppDimensions.padding6h,
        bottom: AppDimensions.padding4h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1, color: AppColors.lightGrey),
          SizedBox(height: AppDimensions.padding10h),
          Text(
            title,
            style: customTextStyle(
              AppTextSizes.smallTextSize,
              AppColors.darkBlueText,
              FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Photo, name, category and the "Profile completed" badge.
class _Header extends StatelessWidget {
  const _Header({required this.profile, this.category});

  final ProviderProfile profile;
  final String? category;

  @override
  Widget build(BuildContext context) {
    return _Card(
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
                if (category != null) ...[
                  SizedBox(height: AppDimensions.padding4h),
                  Text(
                    category!,
                    style: customTextStyle(
                      AppTextSizes.smallTextSize,
                      AppColors.darkGrey,
                      FontWeight.w500,
                    ),
                  ),
                ],
                if (profile.isProfileCompleted) ...[
                  SizedBox(height: AppDimensions.padding6h),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified,
                        color: AppColors.success,
                        size: AppDimensions.containerHeight16h,
                      ),
                      SizedBox(width: AppDimensions.padding4w),
                      Text(
                        'Profile completed',
                        style: customTextStyle(
                          AppTextSizes.stableTextSize,
                          AppColors.success,
                          FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A titled card of label/value rows with an "Edit" action.
class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.title,
    required this.onEdit,
    required this.children,
  });

  final String icon;
  final String title;
  final VoidCallback onEdit;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: IconHeader(icon: icon, title: title),
            ),
            InkWell(
              onTap: onEdit,
              borderRadius: BorderRadius.circular(AppDimensions.radius8r),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.padding8w,
                  vertical: AppDimensions.padding4h,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      color: AppColors.primaryDark,
                      size: AppDimensions.containerHeight16h,
                    ),
                    SizedBox(width: AppDimensions.padding4w),
                    Text(
                      'Edit',
                      style: customTextStyle(
                        AppTextSizes.smallTextSize,
                        AppColors.primaryDark,
                        FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.padding15w,
        vertical: AppDimensions.padding12h,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radius12r),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// One label/value line; an empty value shows "—".
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    this.value,
    this.verified = false,
    this.multiline = false,
  });

  final String label;
  final String? value;
  final bool verified;

  /// Long text (bio, address) goes under the label instead of beside it.
  final bool multiline;

  @override
  Widget build(BuildContext context) {
    final text = value?.trim().isNotEmpty == true ? value!.trim() : '—';
    final labelText = Text(
      label,
      style: customTextStyle(
        AppTextSizes.smallTextSize,
        AppColors.darkGrey,
        FontWeight.w400,
      ),
    );
    final valueStyle = customTextStyle(
      AppTextSizes.smallTextSize,
      AppColors.text,
      FontWeight.w500,
    );

    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppDimensions.padding6h),
      child: multiline
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                labelText,
                SizedBox(height: AppDimensions.padding4h),
                Text(text, style: valueStyle),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: labelText),
                SizedBox(width: AppDimensions.padding10w),
                Expanded(
                  flex: 3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Text(
                          text,
                          textAlign: TextAlign.end,
                          style: valueStyle,
                        ),
                      ),
                      if (verified) ...[
                        SizedBox(width: AppDimensions.padding4w),
                        Icon(
                          Icons.verified,
                          color: AppColors.success,
                          size: AppDimensions.containerHeight16h,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

/// A document image preview; tap to view it full screen.
class _DocumentThumb extends StatelessWidget {
  const _DocumentThumb({required this.title, this.url});

  final String title;
  final String? url;

  @override
  Widget build(BuildContext context) {
    final url = this.url;
    final placeholder = Center(
      child: Icon(
        Icons.image_not_supported_outlined,
        color: AppColors.grey,
        size: AppDimensions.containerHeight20h,
      ),
    );

    return Expanded(
      child: Column(
        children: [
          GestureDetector(
            onTap: url == null
                ? null
                : () =>
                      DocumentImageViewer.show(context, title: title, url: url),
            child: Container(
              height: AppDimensions.containerHeight60h,
              decoration: BoxDecoration(
                color: AppColors.uploadBg,
                borderRadius: BorderRadius.circular(AppDimensions.radius8r),
              ),
              clipBehavior: Clip.antiAlias,
              child: url == null
                  ? placeholder
                  : Image.network(
                      url,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, _, _) => placeholder,
                    ),
            ),
          ),
          SizedBox(height: AppDimensions.padding4h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: customTextStyle(
              AppTextSizes.stableTextSize,
              AppColors.darkGrey,
              FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

/// Centered message with one action (load error / profile not submitted).
class _Message extends StatelessWidget {
  const _Message({
    required this.title,
    required this.buttonText,
    required this.onPressed,
    this.message,
  });

  final String title;
  final String? message;
  final String buttonText;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppDimensions.padding20w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: customTextStyle(
              AppTextSizes.largeTextSize,
              AppColors.darkBlueText,
              FontWeight.w700,
            ),
          ),
          if (message != null) ...[
            SizedBox(height: AppDimensions.padding10h),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: customTextStyle(
                AppTextSizes.smallTextSize,
                AppColors.darkGrey,
                FontWeight.w400,
              ),
            ),
          ],
          SizedBox(height: AppDimensions.padding20h),
          PrimaryButton(text: buttonText, onPressed: onPressed),
        ],
      ),
    );
  }
}
