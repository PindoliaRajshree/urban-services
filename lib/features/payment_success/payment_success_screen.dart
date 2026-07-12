// File: lib/features/payment_success/payment_success_screen.dart
// Purpose: Confirms a successful booking payment (opened from the "Pay"
// button on the Payment screen).

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_images.dart';
import 'package:urban_services/routes/route_names.dart';
import 'package:urban_services/widgets/common_app_bar.dart';
import 'package:urban_services/widgets/custom_text_style.dart';
import 'package:urban_services/widgets/primary_button.dart';
import 'package:urban_services/widgets/secondary_button.dart';

class PaymentSuccessScreen extends StatelessWidget {
  /// Unique booking identifier
  final String bookingId;

  /// Name of the booked service
  final String serviceName;

  /// Booking date & time text
  final String dateTime;

  /// Booking address text
  final String address;

  const PaymentSuccessScreen({
    super.key,
    this.bookingId = 'US123456789',
    this.serviceName = 'Deep Cleaning',
    this.dateTime = '20 May 2024, 11:00 AM',
    this.address = '123, Green Park, Main Road, New Delhi-110016',
  });

  Widget _infoRow(String iconPath, String label, String value) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            iconPath,
            width: AppDimensions.containerWidth24w,
            height: AppDimensions.containerHeight24h,
          ),
          SizedBox(width: AppDimensions.padding8w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: customTextStyle(15, AppColors.text, FontWeight.w600),
                ),
                SizedBox(height: AppDimensions.padding2h),
                Text(
                  value,
                  style: customTextStyle(15, AppColors.text, FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color infoBg = Color.fromRGBO(199, 231, 255, 1);

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
              child: CommonAppBar(
                title: 'Booking Success',
                showMoreIcon: true,
              ),
            ),
            SizedBox(height: AppDimensions.padding10h),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.padding20w,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: AppDimensions.padding10h),
                    Image.asset(
                      AppImages.paymentSuccess,
                      width: AppDimensions.containerWidth150w,
                      height: AppDimensions.containerHeight150h,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: AppDimensions.padding15h),
                    Text(
                      'Booking Confirmed!',
                      textAlign: TextAlign.center,
                      style: customTextStyle(
                        16,
                        AppColors.black,
                        FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: AppDimensions.padding8h),
                    Text(
                      'Your service has been booked successfully.',
                      textAlign: TextAlign.center,
                      style: customTextStyle(
                        14,
                        AppColors.darkGrey,
                        FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: AppDimensions.padding20h),

                    // Booking ID
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.padding15w,
                        vertical: AppDimensions.padding15h,
                      ),
                      decoration: BoxDecoration(
                        color: infoBg,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radius10r,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Text(
                            'Booking ID',
                            style: customTextStyle(
                              18,
                              AppColors.darkGrey,
                              FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: AppDimensions.padding4h),
                          Text(
                            bookingId,
                            style: customTextStyle(
                              17,
                              AppColors.black,
                              FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppDimensions.padding20h),

                    // Service + Date & Time
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _infoRow(AppImages.personPro, 'Service', serviceName),
                        SizedBox(width: AppDimensions.padding12w),
                        _infoRow(AppImages.clock, 'Date & Time', dateTime),
                      ],
                    ),
                    SizedBox(height: AppDimensions.padding20h),

                    // Address
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _infoRow(AppImages.homePage, 'Address', address),
                      ],
                    ),
                    SizedBox(height: AppDimensions.padding20h),

                    // Info Note
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.padding15w,
                        vertical: AppDimensions.padding15h,
                      ),
                      decoration: BoxDecoration(
                        color: infoBg,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radius10r,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'We will assign a professional and update you soon.',
                        textAlign: TextAlign.center,
                        style: customTextStyle(
                          17,
                          AppColors.black,
                          FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: AppDimensions.padding20h),
                  ],
                ),
              ),
            ),

            // Buttons
            Padding(
              padding: EdgeInsets.all(AppDimensions.padding20w),
              child: Column(
                children: [
                  PrimaryButton(
                    text: 'Track Booking',
                    onPressed: () =>
                        Get.toNamed(RouteNames.myBookingsScreen),
                  ),
                  SizedBox(height: AppDimensions.padding12h),
                  SecondaryButton(
                    text: 'Go to Home',
                    onPressed: () =>
                        Get.offAllNamed(RouteNames.homeMain),
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
