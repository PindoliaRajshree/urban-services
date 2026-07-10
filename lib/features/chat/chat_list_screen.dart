// File: lib/features/chat/chat_list_screen.dart
// Purpose: Displays the list of ongoing chats between the user and service providers.

import 'package:flutter/material.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_images.dart';
import 'package:urban_services/widgets/chat_card.dart';
import 'package:urban_services/widgets/custom_search_bar.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: AppDimensions.padding15h),

            // 1. Search Bar
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.padding20w,
              ),
              child: const CustomSearchBar(
                hintText: 'Search for Services...',
              ),
            ),

            SizedBox(height: AppDimensions.padding20h),

            // 2. White rounded container holding the chat list
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppDimensions.radius40r),
                    topRight: Radius.circular(AppDimensions.radius40r),
                  ),
                ),
                child: Column(
                  children: [
                    // Handler (drag-handle style indicator)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: AppDimensions.padding12h,
                      ),
                      child: Container(
                        width: AppDimensions.containerWidth30w,
                        height: AppDimensions.containerHeight3h,
                        decoration: BoxDecoration(
                          color: AppColors.darkGrey,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radius100r,
                          ),
                        ),
                      ),
                    ),

                    // Chat List
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDimensions.padding20w,
                        ),
                        children: const [
                          ChatCard(
                            avatar: AppImages.serviceProvider,
                            name: 'Devon Lane',
                            lastMessage: 'Sure, I will be there by 5 PM.',
                            timeAgo: '2 min ago',
                            unreadCount: 3,
                            isOnline: true,
                          ),
                          ChatCard(
                            avatar: AppImages.image,
                            name: 'Anamika Sharma',
                            lastMessage: 'Thank you for the quick service!',
                            timeAgo: '10 min ago',
                            unreadCount: 0,
                            isOnline: true,
                          ),
                          ChatCard(
                            avatar: AppImages.person,
                            name: 'Rahul Verma',
                            lastMessage: 'Can you share the invoice?',
                            timeAgo: '1 hour ago',
                            unreadCount: 1,
                          ),
                          ChatCard(
                            avatar: AppImages.serviceProvider,
                            name: 'Priya Singh',
                            lastMessage: 'Booking confirmed for tomorrow.',
                            timeAgo: '3 hours ago',
                            unreadCount: 0,
                          ),
                          ChatCard(
                            avatar: AppImages.image,
                            name: 'Devon Lane',
                            lastMessage: 'Typing...',
                            timeAgo: '1 day ago',
                            unreadCount: 12,
                            isOnline: true,
                          ),
                          ChatCard(
                            avatar: AppImages.person,
                            name: 'Karan Mehta',
                            lastMessage: 'See you at the scheduled time.',
                            timeAgo: '2 days ago',
                            unreadCount: 0,
                          ),
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
