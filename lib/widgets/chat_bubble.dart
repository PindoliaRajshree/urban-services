// File: lib/widgets/chat_bubble.dart
// Purpose: Message bubble used inside the chat conversation screen.
// Handles both the receiver layout (left, avatar + blue bubble) and the
// sender layout (right, white bubble) for a single chat message.

import 'package:flutter/material.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_text_sizes.dart';
import 'package:urban_services/widgets/custom_text_style.dart';

class ChatMessageBubble extends StatelessWidget {
  /// True when the message was sent by the current user (right side, white).
  /// False when it was received from the other participant (left side, blue,
  /// shown with their avatar).
  final bool isSender;
  final String message;
  final String time;
  final String? avatar;

  const ChatMessageBubble({
    super.key,
    required this.isSender,
    required this.message,
    required this.time,
    this.avatar,
  });

  @override
  Widget build(BuildContext context) {
    final maxBubbleWidth = MediaQuery.of(context).size.width * 0.65;

    if (isSender) {
      return Padding(
        padding: EdgeInsets.only(bottom: AppDimensions.padding12h),
        child: Align(
          alignment: Alignment.centerRight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                constraints: BoxConstraints(maxWidth: maxBubbleWidth),
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.padding12w,
                  vertical: AppDimensions.padding10h,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppDimensions.radius6r),
                    bottomLeft: Radius.circular(AppDimensions.radius6r),
                    bottomRight: Radius.circular(AppDimensions.radius6r),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      offset: const Offset(0, 1),
                      blurRadius: 3,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Text(
                  message,
                  style: customTextStyle(
                    AppTextSizes.smallTextSize, // 12
                    AppColors.text,
                    FontWeight.w400,
                  ),
                ),
              ),
              SizedBox(height: AppDimensions.padding4h),
              Text(
                time,
                style: customTextStyle(
                  AppTextSizes.stableTextSize, // 10
                  AppColors.chatSubText,
                  FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Receiver layout
    return Padding(
      padding: EdgeInsets.only(bottom: AppDimensions.padding12h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: AppDimensions.containerWidth40w,
            height: AppDimensions.containerHeight40h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.chatAvatarBg,
              image: avatar != null
                  ? DecorationImage(
                      image: AssetImage(avatar!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
          ),
          SizedBox(width: AppDimensions.padding8w),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(maxWidth: maxBubbleWidth),
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.padding12w,
                    vertical: AppDimensions.padding10h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.receiverBubble,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(AppDimensions.radius6r),
                      bottomRight: Radius.circular(AppDimensions.radius6r),
                      bottomLeft: Radius.circular(AppDimensions.radius6r),
                    ),
                  ),
                  child: Text(
                    message,
                    style: customTextStyle(
                      AppTextSizes.stableTextSize, // 10
                      AppColors.white,
                      FontWeight.w400,
                    ),
                  ),
                ),
                SizedBox(height: AppDimensions.padding4h),
                Text(
                  time,
                  style: customTextStyle(
                    AppTextSizes.stableTextSize, // 10
                    AppColors.chatSubText,
                    FontWeight.w400,
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
