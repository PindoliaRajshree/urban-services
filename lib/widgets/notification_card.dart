// File: lib/widgets/notification_card.dart
// Purpose: A reusable card for displaying notification items.

import 'package:flutter/material.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_images.dart';
import 'package:urban_services/widgets/custom_text_style.dart';

enum NotificationType { booking, confirmed, payment, update, cancelled }

class NotificationCard extends StatelessWidget {
  final NotificationType type;
  final String heading;
  final String description;
  final String timeAgo;
  final bool isRead;

  const NotificationCard({
    super.key,
    required this.type,
    required this.heading,
    required this.description,
    required this.timeAgo,
    this.isRead = false,
  });

  String _getIconPath() {
    switch (type) {
      case NotificationType.booking:
        return AppImages.bookingNotify;
      case NotificationType.confirmed:
        return AppImages.bookingConfirmed;
      case NotificationType.payment:
        return AppImages.paymentReceived;
      case NotificationType.update:
        return AppImages.serviceUpdate;
      case NotificationType.cancelled:
        return AppImages.bookingNotify; // Using bookingNotify for cancelled as well or check if there's a better one
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppDimensions.padding10h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Column 1: Blue Circle
          Padding(
            padding: .symmetric(vertical: AppDimensions.padding20h),
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isRead ? Colors.transparent : AppColors.primaryDark,
                shape: BoxShape.circle,
              ),
            ),
          ),
          SizedBox(width: AppDimensions.padding10w),

          // Column 2: Icon from Assets
          Image.asset(
            _getIconPath(),
            width: AppDimensions.containerWidth50w,
            height: AppDimensions.containerHeight50h,
          ),
          SizedBox(width: AppDimensions.padding12w),

          // Column 3: Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: AppDimensions.padding5h,),
                // Row 1: Heading and Time Ago
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      heading,
                      style: customTextStyle(
                        12,
                        AppColors.text,
                        FontWeight.w600,
                      ),
                    ),
                    Text(
                      timeAgo,
                      style: customTextStyle(
                        10,
                        AppColors.primaryDark,
                        FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppDimensions.padding4h),
                // Row 2: Description
                Text(
                  description,
                  style: customTextStyle(
                    10,
                    AppColors.primaryDark,
                    FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
