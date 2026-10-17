// File: lib/widgets/profile_view_widgets.dart
// Purpose: Building blocks of the read-only "My Profile" screens (user and
// provider): titled section cards with an Edit action, label/value rows and
// a centered message with one action.

import 'package:flutter/material.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_text_sizes.dart';
import 'package:urban_services/widgets/custom_text_style.dart';
import 'package:urban_services/widgets/icon_header.dart';
import 'package:urban_services/widgets/primary_button.dart';

/// A titled card of label/value rows with an "Edit" action.
class ProfileSection extends StatelessWidget {
  const ProfileSection({
    super.key,
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
        ProfileCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }
}

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key, required this.child});

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
class ProfileInfoRow extends StatelessWidget {
  const ProfileInfoRow({
    super.key,
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

/// The green "Profile completed" badge shown under the name.
class ProfileCompletedBadge extends StatelessWidget {
  const ProfileCompletedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}

/// Centered message with one action (load error / profile not complete).
class ProfileMessage extends StatelessWidget {
  const ProfileMessage({
    super.key,
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
