// File: lib/features/service_details/service_details_screen.dart
// Purpose: Shows full details of a single service (opened from a service card
// on the Service Category screen).

import 'package:flutter/material.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_images.dart';
import 'package:urban_services/widgets/common_app_bar.dart';
import 'package:urban_services/widgets/custom_text_style.dart';

class ServiceDetailsScreen extends StatelessWidget {
  /// Path of the hero service image
  final String imagePath;

  /// Number of reviews, e.g. "256"
  final String reviewCount;

  /// Starting price amount, e.g. "699"
  final String price;

  /// Duration text, e.g. "2-3 Hours"
  final String duration;

  /// List of things the service includes
  final List<String> includes;

  const ServiceDetailsScreen({
    super.key,
    this.imagePath = AppImages.serviceDeep,
    this.reviewCount = '256',
    this.price = '699',
    this.duration = '2-3 Hours',
    this.includes = const [
      'Full home deep cleaning',
      'Dusting all areas',
      'Floor cleaning & mopping',
      'Kitchen platform cleaning',
      'Bathroom sanitization',
    ],
  });

  Widget _sectionDivider() {
    return Container(
      height: 0.5,
      width: double.infinity,
      color: const Color.fromRGBO(160, 162, 166, 1),
    );
  }

  Widget _priceColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '₹ $price',
          style: customTextStyle(21, AppColors.primaryDark, FontWeight.w700),
        ),
        Text(
          'Starting from',
          style: customTextStyle(10, AppColors.darkGrey, FontWeight.w500),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(244, 249, 253, 1),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.padding20w,
              ),
              child: CommonAppBar(
                title: 'Service Details',
                showMoreIcon: true,
              ),
            ),
            SizedBox(height: AppDimensions.padding15h),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero Image (edge-to-edge, top corners rounded)
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(AppDimensions.radius20r),
                            topRight: Radius.circular(
                              AppDimensions.radius20r,
                            ),
                          ),
                          child: Image.asset(
                            imagePath,
                            width: double.infinity,
                            height: AppDimensions.containerHeight315h,
                            fit: BoxFit.cover,
                          ),
                        ),
                        // Rating + Reviews + Top Rated badge overlay
                        Positioned(
                          left: AppDimensions.padding20w,
                          right: AppDimensions.padding20w,
                          bottom: AppDimensions.padding15h,
                          child: Row(
                            children: [
                              Image.asset(
                                AppImages.ratingStar,
                                width: AppDimensions.containerWidth16w,
                                height: AppDimensions.containerHeight16h,
                              ),
                              Image.asset(
                                AppImages.ratingStar,
                                width: AppDimensions.containerWidth16w,
                                height: AppDimensions.containerHeight16h,
                              ),
                              SizedBox(width: AppDimensions.padding6w),
                              Text(
                                '($reviewCount reviews)',
                                style: customTextStyle(
                                  14,
                                  AppColors.darkGrey,
                                  FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              // Top Rated Badge
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppDimensions.padding10w,
                                  vertical: AppDimensions.padding4h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.radius20r,
                                  ),
                                ),
                                child: ShaderMask(
                                  shaderCallback: (bounds) => AppColors
                                      .gradient
                                      .createShader(Offset.zero & bounds.size),
                                  child: Text(
                                    'Top Rated',
                                    style: customTextStyle(
                                      12,
                                      AppColors.white,
                                      FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Details content
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.padding20w,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: AppDimensions.padding15h),
                          _priceColumn(),
                          SizedBox(height: AppDimensions.padding15h),
                          _sectionDivider(),
                          SizedBox(height: AppDimensions.padding15h),

                          // Service includes
                          Text(
                            'Service includes:',
                            style: customTextStyle(
                              15,
                              AppColors.black,
                              FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: AppDimensions.padding10h),
                          ...includes.map(
                            (item) => Padding(
                              padding: EdgeInsets.only(
                                bottom: AppDimensions.padding10h,
                              ),
                              child: Row(
                                children: [
                                  Image.asset(
                                    AppImages.forwardArrow,
                                    width: AppDimensions.containerWidth14w,
                                    height: AppDimensions.containerHeight14h,
                                    color: AppColors.darkGrey,
                                  ),
                                  SizedBox(width: AppDimensions.padding8w),
                                  Expanded(
                                    child: Text(
                                      item,
                                      style: customTextStyle(
                                        14,
                                        AppColors.darkGrey,
                                        FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: AppDimensions.padding5h),
                          _sectionDivider(),
                          SizedBox(height: AppDimensions.padding15h),

                          // Duration & Professional
                          Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Image.asset(
                                      AppImages.clock,
                                      width: AppDimensions.containerWidth24w,
                                      height: AppDimensions.containerHeight24h,
                                    ),
                                    SizedBox(width: AppDimensions.padding8w),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Duration',
                                          style: customTextStyle(
                                            15,
                                            AppColors.black,
                                            FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          duration,
                                          style: customTextStyle(
                                            15,
                                            AppColors.black,
                                            FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  children: [
                                    Image.asset(
                                      AppImages.person,
                                      width: AppDimensions.containerWidth24w,
                                      height: AppDimensions.containerHeight24h,
                                    ),
                                    SizedBox(width: AppDimensions.padding8w),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Professional',
                                          style: customTextStyle(
                                            15,
                                            AppColors.black,
                                            FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          'Trained & Verified',
                                          style: customTextStyle(
                                            15,
                                            AppColors.black,
                                            FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: AppDimensions.padding15h),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Sticky Bottom Bar: Price + Book Now
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.padding20w,
              ),
              child: _sectionDivider(),
            ),
            Padding(
              padding: EdgeInsets.all(AppDimensions.padding20w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _priceColumn(),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.padding30w,
                        vertical: AppDimensions.padding12h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryDark,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radius10r,
                        ),
                      ),
                      child: Text(
                        'Book Now',
                        style: customTextStyle(
                          20,
                          AppColors.white,
                          FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
