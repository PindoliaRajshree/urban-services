// File: lib/features/home_provider/provider_home_screen.dart
// Purpose: Primary dashboard for service providers to manage jobs, earnings, and availability.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_images.dart';
import 'package:urban_services/core/constants/app_text_sizes.dart';
import 'package:urban_services/features/home_provider/provider_home_controller.dart';
import 'package:urban_services/widgets/custom_text_style.dart';
import 'package:urban_services/widgets/section_heading.dart';

class ProviderHomeScreen extends StatefulWidget {
  const ProviderHomeScreen({super.key});

  @override
  State<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends State<ProviderHomeScreen> {
  // Initialize dashboard logic controller
  final controller = Get.put(ProviderHomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: Stack(
        children: [
          // 1. Vector Background Image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(AppImages.vector, fit: BoxFit.fitWidth),
          ),

          // Main Scrollable Content
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.padding20w,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: AppDimensions.padding15h),

                  // 3. User Profile and Location Header
                  Row(
                    children: [
                      // User Avatar with Shadow
                      Container(
                        width: AppDimensions.containerWidth45w,
                        height: AppDimensions.containerHeight45h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primaryDark,
                            width: 1,
                          ),
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
                      SizedBox(width: AppDimensions.padding10w),
                      // Greeting and Location
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hi, Anamika',
                            style: customTextStyle(
                              AppTextSizes.smallTextSize, // 10
                              AppColors.text,
                              FontWeight.w600,
                            ),
                          ),
                          Row(
                            children: [
                              Image.asset(
                                AppImages.placeMarker,
                                height: AppDimensions.containerHeight15h,
                                width: AppDimensions.containerWidth15w,
                              ),
                              SizedBox(width: AppDimensions.padding4w),
                              Text(
                                'Indore, MP',
                                style: customTextStyle(
                                  AppTextSizes.smallTextSize, // 10
                                  AppColors.text,
                                  FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Action Icons
                      Image.asset(
                        AppImages.homeLocation,
                        height: AppDimensions.containerHeight50h,
                        width: AppDimensions.containerWidth50w,
                      ),
                      SizedBox(width: AppDimensions.padding15w),
                      Image.asset(
                        AppImages.addToCart,
                        height: AppDimensions.containerHeight50h,
                        width: AppDimensions.containerWidth50w,
                      ),
                    ],
                  ),

                  SizedBox(height: AppDimensions.padding20h),

                  // 4. Availability Toggle Container
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radius30r,
                      ),
                      border: Border.all(color: AppColors.white, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          offset: const Offset(0, 1),
                          blurRadius: 4,
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.19),
                          offset: const Offset(0, 1),
                          blurRadius: 3.2,
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(AppDimensions.padding8w),
                    child: Row(
                      children: [
                        // Status Indicator (Green dot)
                        Container(
                          height: 13,
                          width: 13,
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: AppColors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: AppDimensions.padding10w),
                        // Status Text
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Available for Work',
                                style: customTextStyle(
                                  AppTextSizes.mediumTextSize, // 12
                                  AppColors.text,
                                  FontWeight.w600,
                                ),
                              ),
                              Row(
                                children: [
                                  SizedBox(width: AppDimensions.padding8w),
                                  Text(
                                    'You will receive new service requests',
                                    style: customTextStyle(
                                      AppTextSizes.mediumTextSize, // 10
                                      AppColors.text,
                                      FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Toggle Switch
                        Obx(
                          () => Switch(
                            value: controller.isAvailable.value,
                            onChanged: controller.toggleAvailability,
                            activeThumbColor: AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: AppDimensions.padding20h),

                  // 5. Today's Summary Section
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark,
                      borderRadius: BorderRadius.circular(1),
                    ),
                    padding: EdgeInsets.all(AppDimensions.padding8h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Today's Summary",
                          style: customTextStyle(
                            AppTextSizes.stableTextSize, // 10
                            AppColors.white,
                            FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: AppDimensions.padding8h),
                        // Horizontal list of summary cards covering full width
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: _buildSummaryCard('3', 'Active Jobs'),
                            ),
                            SizedBox(width: AppDimensions.padding8w),
                            Expanded(
                              child: _buildSummaryCard(
                                '₹1,250',
                                'Earnings Today',
                              ),
                            ),
                            SizedBox(width: AppDimensions.padding8w),
                            Expanded(
                              child: _buildSummaryCard('5', 'Pending Requests'),
                            ),
                            SizedBox(width: AppDimensions.padding8w),
                            Expanded(
                              child: _buildSummaryCard('4.8', 'Your Rating'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: AppDimensions.padding20h),

                  // 6. New Service Request Section
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardWhite,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radius8r,
                      ),
                      border: Border.all(color: AppColors.primary, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          offset: const Offset(0, 2),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(AppDimensions.padding8w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(AppDimensions.padding8w),
                          child: Text(
                            'New Service Request',
                            style: customTextStyle(
                              AppTextSizes.largeMediumTextSize, // 14
                              AppColors.headingGrey,
                              FontWeight.w500,
                            ),
                          ),
                        ),
                        // Internal Request Card
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radius8r,
                            ),
                            border: Border.all(
                              color: AppColors.primary,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.18),
                                offset: const Offset(0, 2),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(AppDimensions.padding10w),
                          child: Row(
                            children: [
                              // Service Image
                              _buildBorderedImage(AppImages.serviceProvider),
                              SizedBox(width: AppDimensions.padding12w),
                              // Request details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Deep Cleaning',
                                      style: customTextStyle(
                                        AppTextSizes.largeTextSize, // 16
                                        AppColors.black,
                                        FontWeight.w700,
                                      ),
                                    ),
                                    _buildIconTextRow(
                                      AppImages.locationOutlined,
                                      'Vijay Nagar, Indore',
                                      isBold: false,
                                    ),
                                    _buildIconTextRow(
                                      AppImages.clockOutlined,
                                      'Today At 2:00PM',
                                      isBold: true,
                                    ),
                                    Text(
                                      '₹ 699',
                                      style: customTextStyle(
                                        AppTextSizes.smallTextSize, // 10
                                        AppColors.primaryDark,
                                        FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: AppDimensions.padding20h),

                  // 7. Upcoming Bookings Section
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardWhite,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radius8r,
                      ),
                      border: Border.all(color: AppColors.primary, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          offset: const Offset(0, 2),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(AppDimensions.padding8w),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(AppDimensions.padding8w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Upcoming Bookings',
                                style: customTextStyle(
                                  12,
                                  AppColors.headingGrey,
                                  FontWeight.w500,
                                ),
                              ),
                              ShaderMask(
                                shaderCallback: (bounds) => AppColors.gradient
                                    .createShader(Offset.zero & bounds.size),
                                child: Text(
                                  'View All',
                                  style: customTextStyle(
                                    AppTextSizes.smallTextSize,
                                    AppColors.white,
                                    FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Booking Card
                        Stack(
                          children: [
                            Row(
                              children: [
                                _buildBorderedImage(AppImages.serviceProvider),
                                SizedBox(width: AppDimensions.padding12w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Bathroom Cleaning',
                                        style: customTextStyle(
                                          AppTextSizes.largeTextSize, // 16
                                          AppColors.black,
                                          FontWeight.w700,
                                        ),
                                      ),
                                      Text(
                                        'Customer: Rahul Sharma',
                                        style: customTextStyle(
                                          AppTextSizes.smallTextSize,
                                          AppColors.black,
                                          FontWeight.w400,
                                        ),
                                      ),
                                      _buildIconTextRow(
                                        AppImages.clockOutlined,
                                        'Today At 2:00PM',
                                        isBold: true,
                                      ),
                                      _buildIconTextRow(
                                        AppImages.locationOutlined,
                                        'Vijay Nagar, Indore',
                                        isBold: true,
                                      ),
                                      SizedBox(height: AppDimensions.padding4h),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            // Status Badge
                            Positioned(
                              bottom: 25,
                              right: 20,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppDimensions.padding8w,
                                  vertical: AppDimensions.padding2h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.lightSuccess,
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.radius10r,
                                  ),
                                ),
                                child: Text(
                                  'Confirmed',
                                  style: customTextStyle(
                                    AppTextSizes.stableTextSize,
                                    AppColors.success,
                                    FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                            // Price at top right
                            Positioned(
                              bottom: 0,
                              right: 50,
                              child: Text(
                                '₹ 699',
                                style: customTextStyle(
                                  AppTextSizes.smallTextSize,
                                  AppColors.primaryDark,
                                  FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: AppDimensions.padding20h),

                  // 8. Quick Actions Section
                  const SectionHeading(title: 'Quick Actions'),
                  SizedBox(height: AppDimensions.padding15h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildActionCard(AppImages.editServices, 'Edit Services'),
                      _buildActionCard(
                        AppImages.updatePricing,
                        'Update Pricing',
                      ),
                      _buildActionCard(AppImages.availability, 'Availability'),
                      _buildActionCard(AppImages.documents, 'Documents'),
                    ],
                  ),

                  SizedBox(height: AppDimensions.padding20h),

                  // 10. Recent Reviews / Featured Feedback
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radius8r,
                      ),
                      border: Border.all(color: AppColors.darkGrey, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          offset: const Offset(0, 2),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(AppDimensions.padding10w),
                    child: Row(
                      children: [
                        Image.asset(
                          AppImages.image,
                          height: 54,
                          width: 54,
                          fit: BoxFit.cover,
                        ),
                        SizedBox(width: AppDimensions.padding12w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 5-Star Row
                              Row(
                                children: List.generate(
                                  5,
                                  (index) => Image.asset(
                                    AppImages.ratingStar,
                                    height: 12,
                                    width: 12,
                                  ),
                                ),
                              ),
                              SizedBox(height: AppDimensions.padding4h),
                              Text(
                                'Excellent cleaning service. Very professional and on time!',
                                style: customTextStyle(
                                  AppTextSizes.stableTextSize,
                                  AppColors.text,
                                  FontWeight.w500,
                                ),
                              ),
                              Text(
                                '- Priya S.',
                                style: customTextStyle(
                                  AppTextSizes.smallestTextSize,
                                  AppColors.darkGrey,
                                  FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: AppDimensions.padding70h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Helper to build summary statistic cards
  Widget _buildSummaryCard(String value, String label) {
    return Container(
      padding: .symmetric(
        horizontal: AppDimensions.padding5w,
        vertical: AppDimensions.padding5h,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimensions.radius5r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: customTextStyle(
              AppTextSizes.largeTextSize,
              AppColors.primaryDark,
              FontWeight.w700,
            ),
          ),
          Text(
            label,
            maxLines: 2,
            textAlign: TextAlign.center,
            style: customTextStyle(
              AppTextSizes.smallTextSize,
              AppColors.black,
              FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Helper to build quick action cards with gradient borders
  Widget _buildActionCard(String icon, String title) {
    return Container(
      width: 80,
      height: 85,
      padding: EdgeInsets.all(AppDimensions.padding8w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radius10r),
        // Simplification of gradient border as solid primary light
        border: Border.all(color: AppColors.primaryLight, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            offset: const Offset(0, 3),
            blurRadius: 3,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: .center,
        children: [
          Image.asset(icon, height: 30, width: 30),
          SizedBox(height: AppDimensions.padding4h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: customTextStyle(
              AppTextSizes.stableTextSize,
              AppColors.text,
              FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Helper for building service request images with shadows and borders
  Widget _buildBorderedImage(String image) {
    return Container(
      width: 75,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radius6r),
        border: Border.all(color: AppColors.primaryLight, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            offset: const Offset(0, 3),
            blurRadius: 3,
            spreadRadius: -1,
          ),
        ],
        image: DecorationImage(image: AssetImage(image), fit: BoxFit.cover),
      ),
    );
  }

  /// Helper to build icon + text rows for address and time details
  Widget _buildIconTextRow(String icon, String text, {required bool isBold}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppDimensions.padding2h),
      child: Row(
        children: [
          Image.asset(icon, height: 14, width: 14),
          SizedBox(width: AppDimensions.padding4w),
          Expanded(
            child: Text(
              text,
              style: customTextStyle(
                AppTextSizes.smallTextSize,
                AppColors.black,
                isBold ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
