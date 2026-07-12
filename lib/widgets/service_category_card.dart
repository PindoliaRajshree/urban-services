// File: lib/widgets/service_category_card.dart
// Purpose: A reusable card for displaying a single service within a category listing.

import 'package:flutter/material.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_images.dart';
import 'package:urban_services/widgets/custom_text_style.dart';

class ServiceCategoryCard extends StatelessWidget {
  /// Service title, e.g. "Deep Cleaning"
  final String title;

  /// Short description, e.g. "Full home deep cleaning"
  final String subtitle;

  /// Rating value, e.g. "4.6"
  final String rating;

  /// Number of reviews, e.g. "256"
  final String reviewCount;

  /// Starting price amount, e.g. "699"
  final String price;

  /// Path of the service image asset
  final String imagePath;

  /// Callback when the card is tapped
  final VoidCallback? onTap;

  const ServiceCategoryCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.rating,
    required this.reviewCount,
    required this.price,
    required this.imagePath,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppDimensions.radius20r),
        ),
        child: IntrinsicHeight(
          child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Column 1: Details
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.padding15w,
                  vertical: AppDimensions.padding5h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: customTextStyle(
                        16,
                        AppColors.black,
                        FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: AppDimensions.padding4h),
                    Text(
                      subtitle,
                      style: customTextStyle(
                        12,
                        AppColors.grey,
                        FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: AppDimensions.padding8h),
                    Row(
                      children: [
                        Image.asset(
                          AppImages.ratingStar,
                          width: AppDimensions.containerWidth14w,
                          height: AppDimensions.containerHeight14h,
                        ),
                        SizedBox(width: AppDimensions.padding4w),
                        Text(
                          '$rating ($reviewCount)',
                          style: customTextStyle(
                            12,
                            AppColors.black,
                            FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppDimensions.padding8h),
                    Text(
                      'Starting from',
                      style: customTextStyle(
                        12,
                        AppColors.black,
                        FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: AppDimensions.padding2h),
                    Text(
                      '₹ $price',
                      style: customTextStyle(
                        12,
                        AppColors.primary,
                        FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Column 2: Image (flush top & bottom, no vertical padding)
            ClipRRect(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(AppDimensions.radius20r),
                bottomRight: Radius.circular(AppDimensions.radius20r),
              ),
              child: Image.asset(
                imagePath,
                width: AppDimensions.containerWidth110w,
                fit: BoxFit.cover,
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }
}
