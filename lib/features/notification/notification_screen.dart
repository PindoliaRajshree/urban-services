// File: lib/features/notification/notification_screen.dart
// Purpose: Screen for displaying all user/provider notifications.

import 'package:flutter/material.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_images.dart';
import 'package:urban_services/widgets/custom_text_style.dart';
import 'package:urban_services/widgets/notification_card.dart';
import 'package:urban_services/widgets/section_heading.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color darkBlue = const Color.fromRGBO(40, 42, 55, 1);

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppDimensions.padding20w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AppDimensions.padding20h),
              // 1. Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notifications',
                        style: customTextStyle(
                          24,
                          darkBlue,
                          FontWeight.w600,
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          style: customTextStyle(
                            14,
                            AppColors.grey,
                            FontWeight.w400,
                          ),
                          children: [
                            const TextSpan(text: 'You have '),
                            TextSpan(
                              text: '3 Notifications',
                              style: customTextStyle(
                                14,
                                darkBlue,
                                FontWeight.w600,
                              ),
                            ),
                            const TextSpan(text: ' today'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Filter Icon
                  Image.asset(
                    AppImages.filter,
                    width: AppDimensions.containerWidth40w,
                    height: AppDimensions.containerHeight40h,
                  ),
                ],
              ),
              SizedBox(height: AppDimensions.padding30h),

              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 2. Today Section
                      const SectionHeading(
                        title: 'Today',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                      SizedBox(height: AppDimensions.padding10h),
                      const NotificationCard(
                        type: NotificationType.booking,
                        heading: 'New Booking Request',
                        description: 'You have a new booking request for Home Cleaning',
                        timeAgo: 'Just Now',
                      ),
                      const NotificationCard(
                        type: NotificationType.confirmed,
                        heading: 'Booking Confirmed',
                        description: 'Rahul Sharma has confirmed the booking',
                        timeAgo: '10 min ago',
                      ),
                      const NotificationCard(
                        type: NotificationType.payment,
                        heading: 'Payment Received',
                        description: 'You received a payment of 2699',
                        timeAgo: '30 min ago',
                      ),

                      SizedBox(height: AppDimensions.padding20h),

                      // 4. This Week Section
                      const SectionHeading(
                        title: 'This Week',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                      SizedBox(height: AppDimensions.padding10h),
                      const NotificationCard(
                        type: NotificationType.cancelled,
                        heading: 'Booking Cancelled',
                        description: 'A booking for 25 Apr has been cancelled.',
                        timeAgo: '2 hours ago',
                        isRead: true,
                      ),
                      const NotificationCard(
                        type: NotificationType.update,
                        heading: 'Service Update',
                        description: 'new service category added.',
                        timeAgo: '2 hours ago',
                        isRead: true,
                      ),
                      const NotificationCard(
                        type: NotificationType.payment,
                        heading: 'Payment Received',
                        description: 'You received a payment of 3999',
                        timeAgo: '2 hours ago',
                        isRead: true,
                      ),
                      const NotificationCard(
                        type: NotificationType.cancelled,
                        heading: 'Booking Cancelled',
                        description: 'A booking for 25 Apr has been cancelled.',
                        timeAgo: '1 week ago',
                        isRead: true,
                      ),
                      SizedBox(height: AppDimensions.padding20h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
