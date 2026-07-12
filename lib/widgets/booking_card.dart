// File: lib/widgets/booking_card.dart
// Purpose: A reusable card for displaying a single booking item on the My Bookings screen.

import 'package:flutter/material.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/widgets/custom_text_style.dart';

enum BookingStatus { confirmed, completed, cancelled }

class BookingCard extends StatelessWidget {
  /// Path of the booking/service image asset
  final String imagePath;

  /// Name of the booked service
  final String serviceName;

  /// Current status of the booking
  final BookingStatus status;

  /// Formatted date & time string, e.g. "20 May 2024, 11:00 AM"
  final String dateTime;

  /// Unique booking identifier
  final String bookingId;

  /// Label for the action button (Track / Rebook / Book again)
  final String buttonText;

  /// Callback for the action button tap
  final VoidCallback? onButtonTap;

  const BookingCard({
    super.key,
    required this.imagePath,
    required this.serviceName,
    required this.status,
    required this.dateTime,
    required this.bookingId,
    required this.buttonText,
    this.onButtonTap,
  });

  String get _statusLabel {
    switch (status) {
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get _statusBgColor {
    switch (status) {
      case BookingStatus.confirmed:
        return const Color.fromRGBO(231, 255, 216, 1);
      case BookingStatus.cancelled:
        return const Color.fromRGBO(255, 216, 216, 1);
      case BookingStatus.completed:
        return const Color.fromRGBO(216, 236, 255, 1);
    }
  }

  Color get _statusTextColor {
    switch (status) {
      case BookingStatus.confirmed:
        return const Color.fromRGBO(10, 128, 28, 1);
      case BookingStatus.cancelled:
        return const Color.fromRGBO(126, 10, 10, 1);
      case BookingStatus.completed:
        return const Color.fromRGBO(10, 61, 128, 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppDimensions.padding10w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radius10r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Booking Image
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radius8r),
            child: Image.asset(
              imagePath,
              width: AppDimensions.containerWidth60w,
              height: AppDimensions.containerHeight78h,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: AppDimensions.padding12w),

          // Details Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row 1: Service Name + Status Label
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        serviceName,
                        style: customTextStyle(
                          12,
                          AppColors.black,
                          FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(width: AppDimensions.padding6w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.padding8w,
                        vertical: AppDimensions.padding2h,
                      ),
                      decoration: BoxDecoration(
                        color: _statusBgColor,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radius4r,
                        ),
                      ),
                      child: Text(
                        _statusLabel,
                        style: customTextStyle(
                          10,
                          _statusTextColor,
                          FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppDimensions.padding8h),

                // Row 2: DateTime
                Text(
                  dateTime,
                  style: customTextStyle(10, AppColors.darkGrey, FontWeight.w400),
                ),
                SizedBox(height: AppDimensions.padding12h),

                // Row 3: Booking ID + Action Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        bookingId,
                        style: customTextStyle(
                          10,
                          AppColors.black,
                          FontWeight.w400,
                        ),
                      ),
                    ),
                    SizedBox(width: AppDimensions.padding6w),
                    GestureDetector(
                      onTap: onButtonTap,
                      child: Container(
                        padding: const EdgeInsets.all(1.2),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primaryDark, AppColors.primary],
                          ),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radius20r,
                          ),
                        ),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppDimensions.padding15w,
                            vertical: AppDimensions.padding5h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radius20r,
                            ),
                          ),
                          child: Text(
                            buttonText,
                            style: customTextStyle(
                              10,
                              AppColors.primaryDark,
                              FontWeight.w500,
                            ),
                          ),
                        ),
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
