// File: lib/widgets/chat_card.dart
// Purpose: A single row in the Chat List screen — avatar with online status,
// contact name, last message preview, time-ago label, and unread count badge.

import 'package:flutter/material.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_text_sizes.dart';
import 'package:urban_services/widgets/custom_text_style.dart';

class ChatCard extends StatelessWidget {
  final String avatar;
  final String name;
  final String lastMessage;
  final String timeAgo;
  final int unreadCount;
  final bool isOnline;
  final VoidCallback? onTap;

  const ChatCard({
    super.key,
    required this.avatar,
    required this.name,
    required this.lastMessage,
    required this.timeAgo,
    this.unreadCount = 0,
    this.isOnline = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radius12r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppDimensions.padding10h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Avatar with online status indicator
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: AppDimensions.containerWidth40w,
                  height: AppDimensions.containerHeight40h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.chatAvatarBg,
                    image: DecorationImage(
                      image: AssetImage(avatar),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                if (isOnline)
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: Container(
                      width: AppDimensions.containerWidth12w,
                      height: AppDimensions.containerHeight12h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.onlineStatus,
                        border: Border.all(color: AppColors.white, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: AppDimensions.padding12w),

            // Name + Last Message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: customTextStyle(
                      AppTextSizes.largeTextSize, // 20
                      AppColors.chatNameText,
                      FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: AppDimensions.padding2h),
                  Text(
                    lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: customTextStyle(
                      AppTextSizes.smallTextSize, // 12
                      AppColors.chatSubText,
                      FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: AppDimensions.padding8w),

            // Time Ago + Unread Count
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  timeAgo,
                  style: customTextStyle(
                    AppTextSizes.smallTextSize, // 12
                    AppColors.chatSubText,
                    FontWeight.w400,
                  ),
                ),
                SizedBox(height: AppDimensions.padding4h),
                if (unreadCount > 0)
                  Container(
                    width: AppDimensions.containerWidth21_81w,
                    height: AppDimensions.containerHeight21_81h,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.unreadBadge,
                    ),
                    child: Text(
                      unreadCount > 99 ? '99+' : '$unreadCount',
                      style: customTextStyle(
                        AppTextSizes.smallTextSize, // 12
                        AppColors.white,
                        FontWeight.w400,
                      ),
                    ),
                  )
                else
                  SizedBox(height: AppDimensions.containerHeight21_81h),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
