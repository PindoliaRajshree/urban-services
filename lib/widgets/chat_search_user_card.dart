// File: lib/widgets/chat_search_user_card.dart
// Purpose: A single search result row on the Chat Search screen — circular
// avatar, user name, and status (e.g. Online / Last seen).

import 'package:flutter/material.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_text_sizes.dart';
import 'package:urban_services/widgets/custom_text_style.dart';

class ChatSearchUserCard extends StatelessWidget {
  final String avatar;
  final String name;
  final String status;
  final VoidCallback? onTap;

  const ChatSearchUserCard({
    super.key,
    required this.avatar,
    required this.name,
    required this.status,
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
            // 1. User Profile Avatar (51 x 51, circular)
            Container(
              width: AppDimensions.containerWidth51w,
              height: AppDimensions.containerHeight51h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.chatAvatarBg,
                image: DecorationImage(
                  image: AssetImage(avatar),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: AppDimensions.padding12w),

            // 2. Name + Status Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: customTextStyle(
                      AppTextSizes.doubleLargeTextSize, // 18
                      AppColors.chatNameText, // (0, 14, 8, 1)
                      FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: AppDimensions.padding4h),
                  Text(
                    status,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: customTextStyle(
                      AppTextSizes.smallTextSize, // 12
                      AppColors.chatSubText, // (121, 124, 123, 1)
                      FontWeight.w400,
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
