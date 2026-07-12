// File: lib/features/live_tracking/live_tracking_screen.dart
// Purpose: Shows live tracking of the assigned professional for a booking
// (opened from the "Track Booking" button on the Payment Success screen).

import 'package:flutter/material.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_images.dart';
import 'package:urban_services/widgets/common_app_bar.dart';
import 'package:urban_services/widgets/custom_text_style.dart';

class LiveTrackingScreen extends StatelessWidget {
  /// Unique booking identifier
  final String bookingId;

  /// Name of the booked service
  final String serviceName;

  /// Booking date & time text
  final String dateTime;

  /// Name of the assigned professional
  final String providerName;

  /// Provider photo asset path
  final String providerImage;

  /// Provider rating, e.g. "4.7"
  final String rating;

  /// Provider review count, e.g. "128"
  final String reviewCount;

  const LiveTrackingScreen({
    super.key,
    this.bookingId = 'US123456789',
    this.serviceName = 'Deep Cleaning',
    this.dateTime = '20 May 2024, 11:00 AM',
    this.providerName = 'Ram Kumar Yadav',
    this.providerImage = AppImages.serviceProvider,
    this.rating = '4.7',
    this.reviewCount = '128',
  });

  Widget _bookingDetailRow(String key, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppDimensions.padding6h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            key,
            style: customTextStyle(12, AppColors.black, FontWeight.w500),
          ),
          SizedBox(width: AppDimensions.padding10w),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: customTextStyle(14, AppColors.black, FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.padding20w,
              ),
              child: CommonAppBar(title: 'Live Tracking', showMoreIcon: true),
            ),
            SizedBox(height: AppDimensions.padding15h),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Live Tracking Map Image (full width)
                    Image.asset(
                      AppImages.liveTracking,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(height: AppDimensions.padding20h),

                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.padding20w,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Delivery / Professional Card
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radius8r,
                                ),
                                child: Image.asset(
                                  providerImage,
                                  width: AppDimensions.containerWidth60w,
                                  height: AppDimensions.containerHeight60h,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              SizedBox(width: AppDimensions.padding12w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      providerName,
                                      style: customTextStyle(
                                        15,
                                        AppColors.text,
                                        FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(
                                      height: AppDimensions.padding4h,
                                    ),
                                    Row(
                                      children: [
                                        Image.asset(
                                          AppImages.ratingStar,
                                          width:
                                              AppDimensions.containerWidth14w,
                                          height: AppDimensions
                                              .containerHeight14h,
                                        ),
                                        Image.asset(
                                          AppImages.ratingStar,
                                          width:
                                              AppDimensions.containerWidth14w,
                                          height: AppDimensions
                                              .containerHeight14h,
                                        ),
                                        SizedBox(
                                          width: AppDimensions.padding4w,
                                        ),
                                        Text(
                                          '$rating ($reviewCount)',
                                          style: customTextStyle(
                                            12,
                                            AppColors.darkGrey,
                                            FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: AppDimensions.padding4h,
                                    ),
                                    Text(
                                      serviceName,
                                      style: customTextStyle(
                                        14,
                                        AppColors.text,
                                        FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: AppDimensions.padding8w),
                              Image.asset(
                                AppImages.ringerVolume,
                                width: AppDimensions.containerWidth24w,
                                height: AppDimensions.containerHeight24h,
                              ),
                              SizedBox(width: AppDimensions.padding12w),
                              Image.asset(
                                AppImages.chatBubble,
                                width: AppDimensions.containerWidth24w,
                                height: AppDimensions.containerHeight24h,
                              ),
                            ],
                          ),
                          SizedBox(height: AppDimensions.padding20h),

                          // Booking Details Card
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(
                              AppDimensions.padding15w,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radius15r,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(
                                    alpha: 0.15,
                                  ),
                                  offset: const Offset(0, 1),
                                  blurRadius: 2,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                _bookingDetailRow('Booking ID', bookingId),
                                _bookingDetailRow('Service', serviceName),
                                _bookingDetailRow(
                                  'Date & Time',
                                  dateTime,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: AppDimensions.padding20h),

                          // Cancel Booking Button
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              width: double.infinity,
                              height: AppDimensions.containerHeight50h,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                border: Border.all(
                                  color: AppColors.primaryDark,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radius10r,
                                ),
                              ),
                              child: Text(
                                'Cancel Booking',
                                style: customTextStyle(
                                  16,
                                  AppColors.primaryDark,
                                  FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: AppDimensions.padding20h),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
