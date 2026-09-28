// File: lib/widgets/home_header.dart
// Purpose: The header row shared by the user and provider Home screens:
// the avatar (spotlighted with a "complete your profile" showcase), the
// greeting, an optional location line and trailing action icons.

import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_images.dart';
import 'package:urban_services/core/constants/app_text_sizes.dart';
import 'package:urban_services/widgets/custom_text_style.dart';

class HomeHeader extends StatefulWidget {
  const HomeHeader({
    super.key,
    required this.firstName,
    required this.showcaseDescription,
    required this.onAvatarTap,
    this.location,
    this.onLocationTap,
    this.actions = const [],
  });

  /// Shown as "Hi, [firstName]" ("Hi, there" when null).
  final String? firstName;

  /// Text of the "Complete Your Profile" spotlight on the avatar.
  final String showcaseDescription;

  /// Opens the role's profile-completion screen.
  final VoidCallback onAvatarTap;

  /// The location line under the greeting. Hidden when null.
  final String? location;
  final VoidCallback? onLocationTap;

  /// Icons at the end of the row.
  final List<Widget> actions;

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  // Spotlights the avatar with a "complete your profile" callout.
  final GlobalKey _profileShowcaseKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Runs once per Home screen (HomeMain keeps its tabs alive). There's
    // no "seen it already" flag yet, so it shows on every app start.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ShowCaseWidget.of(context).startShowCase([_profileShowcaseKey]);
    });
  }

  /// `disableDefaultTargetGestures: true` below means the package's own tap
  /// handling (and its `disposeOnTap` logic) never runs, so the showcase is
  /// dismissed explicitly here before navigating.
  void _onAvatarTap() {
    ShowCaseWidget.of(context).dismiss();
    widget.onAvatarTap();
  }

  @override
  Widget build(BuildContext context) {
    final location = widget.location;

    return Row(
      children: [
        Showcase(
          key: _profileShowcaseKey,
          title: 'Complete Your Profile',
          description: widget.showcaseDescription,
          targetShapeBorder: const CircleBorder(),
          tooltipBackgroundColor: AppColors.primaryDark,
          textColor: AppColors.white,
          titleTextStyle: customTextStyle(
            AppTextSizes.largeTextSize,
            AppColors.white,
            FontWeight.w700,
          ),
          descTextStyle: customTextStyle(
            AppTextSizes.smallTextSize,
            AppColors.white,
            FontWeight.w400,
          ),
          disableDefaultTargetGestures: true,
          onTargetClick: _onAvatarTap,
          disposeOnTap: true,
          child: GestureDetector(
            onTap: _onAvatarTap,
            child: Container(
              width: AppDimensions.containerWidth45w,
              height: AppDimensions.containerHeight45h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryDark, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    offset: const Offset(0, 1),
                    blurRadius: 2.9,
                    spreadRadius: 0,
                  ),
                ],
                image: const DecorationImage(
                  image: AssetImage(AppImages.image),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: AppDimensions.padding10w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi, ${widget.firstName ?? 'there'}',
                overflow: TextOverflow.ellipsis,
                style: customTextStyle(
                  AppTextSizes.smallTextSize,
                  AppColors.text,
                  FontWeight.w600,
                ),
              ),
              if (location != null)
                GestureDetector(
                  onTap: widget.onLocationTap,
                  child: Row(
                    children: [
                      Image.asset(
                        AppImages.placeMarker,
                        height: AppDimensions.containerHeight15h,
                        width: AppDimensions.containerWidth15w,
                      ),
                      SizedBox(width: AppDimensions.padding4w),
                      Flexible(
                        child: Text(
                          location,
                          overflow: TextOverflow.ellipsis,
                          style: customTextStyle(
                            AppTextSizes.smallTextSize,
                            AppColors.text,
                            FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        ...widget.actions,
      ],
    );
  }
}
