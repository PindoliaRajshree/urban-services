// File: lib/widgets/complete_profile_card.dart
// Purpose: A card encouraging users to complete their profile with a progress indicator and animation.

import 'package:flutter/material.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_text_sizes.dart';
import 'package:urban_services/widgets/custom_text_style.dart';

class CompleteProfileCard extends StatefulWidget {
  final VoidCallback onFinish;

  const CompleteProfileCard({super.key, required this.onFinish});

  @override
  State<CompleteProfileCard> createState() => _CompleteProfileCardState();
}

class _CompleteProfileCardState extends State<CompleteProfileCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize animation controller for the entrance effect
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Fade in animation
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    // Slide up animation with a slight bounce
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutBack,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: AppDimensions.padding15h),
          padding: EdgeInsets.all(AppDimensions.padding15h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppDimensions.radius20r),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Circular Progress Indicator representing 60% completion
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        height: AppDimensions.containerHeight60h,
                        width: AppDimensions.containerWidth60w,
                        child: CircularProgressIndicator(
                          value: 0.6,
                          strokeWidth: 6,
                          backgroundColor: AppColors.lightGrey,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                        ),
                      ),
                      Text(
                        '60%',
                        style: customTextStyle(
                          AppTextSizes.smallTextSize,
                          AppColors.black,
                          FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: AppDimensions.padding15w),
                  // Informational Text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Profile 60% Complete',
                          style: customTextStyle(
                            AppTextSizes.largeTextSize,
                            AppColors.black,
                            FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: AppDimensions.padding4h),
                        Text(
                          'Only 2 steps left to get better recommendations & faster bookings',
                          style: customTextStyle(
                            AppTextSizes.smallTextSize,
                            AppColors.text,
                            FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppDimensions.padding15h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Horizontal Progress Stepper with 5 blocks
                  Expanded(
                    child: Row(
                      children: List.generate(5, (index) {
                        final isActive = index < 3; // 60% of 5 is 3
                        return Expanded(
                          child: Container(
                            height: AppDimensions.containerHeight4h,
                            margin: EdgeInsets.only(
                              right: index == 4 ? 0 : AppDimensions.padding4w,
                            ),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AppColors.primary
                                  : AppColors.lightGrey,
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radius2r,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  SizedBox(width: AppDimensions.padding20w),
                  // "Finish" action to trigger profile completion flow
                  GestureDetector(
                    onTap: widget.onFinish,
                    child: Row(
                      children: [
                        Text(
                          'Finish',
                          style: customTextStyle(
                            AppTextSizes.smallTextSize,
                            AppColors.primary,
                            FontWeight.w600,
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
