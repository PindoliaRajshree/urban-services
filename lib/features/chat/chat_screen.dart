// File: lib/features/chat/chat_screen.dart
// Purpose: One-to-one chat conversation screen between the user and a service provider.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_images.dart';
import 'package:urban_services/core/constants/app_text_sizes.dart';
import 'package:urban_services/widgets/chat_bubble.dart';
import 'package:urban_services/widgets/custom_text_style.dart';

class ChatScreen extends StatefulWidget {
  final String name;
  final String avatar;
  final String status;

  const ChatScreen({
    super.key,
    this.name = 'Devon Lane',
    this.avatar = AppImages.serviceProvider,
    this.status = 'Online',
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  // Dummy conversation data
  final List<Map<String, dynamic>> _messages = const [
    {
      'isSender': false,
      'message': 'Hi! I would like to book a cleaning service for tomorrow.',
      'time': '10:02 AM',
    },
    {
      'isSender': true,
      'message': 'Sure, what time works best for you?',
      'time': '10:04 AM',
    },
    {
      'isSender': false,
      'message': 'Around 11 AM would be great.',
      'time': '10:05 AM',
    },
    {
      'isSender': true,
      'message': 'Sure, I will be there by 5 PM.',
      'time': '10:06 AM',
    },
    {
      'isSender': false,
      'message': 'Thank you! See you then.',
      'time': '10:07 AM',
    },
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true, // keep input bar above the keyboard
      body: SafeArea(
        child: Column(
          children: [
            // 3. Header Row
            Padding(
              padding: EdgeInsets.all(AppDimensions.padding15w),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Image.asset(
                      AppImages.back,
                      width: AppDimensions.containerWidth20w,
                      height: AppDimensions.containerHeight20h,
                    ),
                  ),
                  SizedBox(width: AppDimensions.padding12w),

                  // Avatar with status dot
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: AppDimensions.containerWidth45w,
                        height: AppDimensions.containerHeight45h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.chatAvatarBg,
                          image: DecorationImage(
                            image: AssetImage(widget.avatar),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 2,
                        bottom: 2,
                        child: Container(
                          width: AppDimensions.containerWidth12w,
                          height: AppDimensions.containerHeight12h,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.onlineStatus,
                            border: Border.all(
                              color: AppColors.white,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: AppDimensions.padding10w),

                  // Name + Status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: customTextStyle(
                            AppTextSizes.largeTextSize, // 16
                            AppColors.chatNameText,
                            FontWeight.w500,
                          ),
                        ),
                        Text(
                          widget.status,
                          style: customTextStyle(
                            AppTextSizes.smallTextSize, // 12
                            AppColors.chatSubText,
                            FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Call & Video Icons
                  GestureDetector(
                    onTap: () {},
                    child: Image.asset(
                      AppImages.chatPhone,
                      width: AppDimensions.containerWidth18w,
                      height: AppDimensions.containerHeight18h,
                    ),
                  ),
                  SizedBox(width: AppDimensions.padding15w),
                  GestureDetector(
                    onTap: () {},
                    child: Image.asset(
                      AppImages.video,
                      width: AppDimensions.containerWidth24w,
                      height: AppDimensions.containerHeight24h,
                    ),
                  ),
                ],
              ),
            ),

            // 4. DateTime Label (centered)
            Center(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.padding12w,
                  vertical: AppDimensions.padding6h,
                ),
                decoration: BoxDecoration(
                  color: AppColors.dateChipBg,
                  borderRadius: BorderRadius.circular(AppDimensions.radius6r),
                ),
                child: Text(
                  'Today, 10 July',
                  style: customTextStyle(
                    AppTextSizes.smallTextSize, // 12
                    AppColors.chatNameText,
                    FontWeight.w400,
                  ),
                ),
              ),
            ),
            SizedBox(height: AppDimensions.padding15h),

            // 5 & 6. Messages List
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.padding15w,
                ),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isSender = msg['isSender'] as bool;
                  return ChatMessageBubble(
                    isSender: isSender,
                    message: msg['message'] as String,
                    time: msg['time'] as String,
                    avatar: isSender ? null : widget.avatar,
                  );
                },
              ),
            ),

            // 7. Bottom Input Container
            SafeArea(
              top: false,
              child: Container(
                height: AppDimensions.containerHeight70h,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  border: Border(
                    top: BorderSide(
                      color: AppColors.chatInputBorder,
                      width: 1,
                    ),
                  ),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.padding15w,
                ),
                child: Row(
                  children: [
                    // Pin / Attachment Icon
                    GestureDetector(
                      onTap: () {},
                      child: Image.asset(
                        AppImages.pin,
                        width: AppDimensions.containerWidth20w,
                        height: AppDimensions.containerHeight20h,
                      ),
                    ),
                    SizedBox(width: AppDimensions.padding10w),

                    // Chat Input Box
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDimensions.padding12w,
                          vertical: AppDimensions.padding6h
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.chatInputBg,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radius12r,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _messageController,
                                decoration: InputDecoration(
                                  hintText: 'Write your message',
                                  hintStyle: customTextStyle(
                                    AppTextSizes.smallTextSize, // 12
                                    AppColors.chatSubText,
                                    FontWeight.w400,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                                style: customTextStyle(
                                  AppTextSizes.smallTextSize, // 12
                                  AppColors.text,
                                  FontWeight.w400,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {},
                              child: Image.asset(
                                AppImages.chatFile,
                                width: AppDimensions.containerWidth18w,
                                height: AppDimensions.containerHeight18h,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: AppDimensions.padding10w),

                    // Camera Icon
                    GestureDetector(
                      onTap: () {},
                      child: Image.asset(
                        AppImages.camera,
                        width: AppDimensions.containerWidth20w,
                        height: AppDimensions.containerHeight20h,
                      ),
                    ),
                    SizedBox(width: AppDimensions.padding10w),

                    // Microphone Icon
                    GestureDetector(
                      onTap: () {},
                      child: Image.asset(
                        AppImages.chatMic,
                        width: AppDimensions.containerWidth20w,
                        height: AppDimensions.containerHeight20h,
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
