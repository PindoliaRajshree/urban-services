// File: lib/widgets/top_rated_card.dart
// Purpose: A reusable card widget for displaying top-rated service providers.

import 'package:flutter/material.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_images.dart';
import 'package:urban_services/core/constants/app_text_sizes.dart';
import 'package:urban_services/widgets/custom_text_style.dart';

class TopRatedCard extends StatelessWidget {
  final String name;
  final String category;
  final String price;
  final String rating;
  final String image;

  const TopRatedCard({
    super.key,
    required this.name,
    required this.category,
    required this.price,
    required this.rating,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppDimensions.padding15h),
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.padding10w,
        vertical: AppDimensions.padding8h,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radius8r),
        border: Border.all(color: AppColors.primary, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            offset: const Offset(0, 2),
            blurRadius: 2,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          // Provider Image
          Container(
            width: AppDimensions.containerWidth75w,
            height: AppDimensions.containerHeight60h,
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
              image: DecorationImage(
                image: AssetImage(image),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: AppDimensions.padding12w),
          // Provider Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: customTextStyle(
                        AppTextSizes.largeMediumTextSize, // 14
                        AppColors.darkBlack,
                        FontWeight.w600,
                      ),
                    ),
                    // Rating Container
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.padding6w,
                        vertical: AppDimensions.padding2h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryDark,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radius5r,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            rating,
                            style: customTextStyle(
                              AppTextSizes.stableTextSize, // 10
                              AppColors.white,
                              FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Image.asset(
                            AppImages.ratingStar,
                            height: AppDimensions.containerHeight8h,
                            width: AppDimensions.containerWidth8w,
                          ),
                          Image.asset(
                            AppImages.ratingStar,
                            height: AppDimensions.containerHeight8h,
                            width: AppDimensions.containerWidth8w,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppDimensions.padding2h),
                Text(
                  category,
                  style: customTextStyle(
                    AppTextSizes.smallTextSize, // 12
                    AppColors.darkGrey,
                    FontWeight.w500,
                  ),
                ),
                SizedBox(height: AppDimensions.padding4h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      price,
                      style: customTextStyle(
                        AppTextSizes.largeMediumTextSize, // 14
                        AppColors.primaryDark,
                        FontWeight.w600,
                      ),
                    ),
                    // Visit Us Button
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.padding12w,
                        vertical: AppDimensions.padding4h,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppColors.gradient,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radius10r,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Visit Us',
                            style: customTextStyle(
                              AppTextSizes.smallTextSize, // 12
                              AppColors.white,
                              FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: AppDimensions.padding10w),
                          Image.asset(
                            AppImages.forwardArrow,
                            height: AppDimensions.containerHeight15h,
                            width: AppDimensions.containerWidth15w,
                            color: AppColors.white,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
