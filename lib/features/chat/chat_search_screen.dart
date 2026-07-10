// File: lib/features/chat/chat_search_screen.dart
// Purpose: Dedicated search screen for finding a user/conversation from the
// Chat tab. Reuses the same CustomSearchBar as the Home screen.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_images.dart';
import 'package:urban_services/core/constants/app_text_sizes.dart';
import 'package:urban_services/routes/route_names.dart';
import 'package:urban_services/widgets/chat_search_user_card.dart';
import 'package:urban_services/widgets/custom_search_bar.dart';
import 'package:urban_services/widgets/custom_text_style.dart';

class ChatSearchScreen extends StatefulWidget {
  const ChatSearchScreen({super.key});

  @override
  State<ChatSearchScreen> createState() => _ChatSearchScreenState();
}

class _ChatSearchScreenState extends State<ChatSearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Mock user directory to search against.
  final List<Map<String, String>> _allUsers = const [
    {
      'name': 'Devon Lane',
      'avatar': AppImages.serviceProvider,
      'status': 'Online',
    },
    {
      'name': 'Anamika Sharma',
      'avatar': AppImages.image,
      'status': 'Online',
    },
    {
      'name': 'Rahul Verma',
      'avatar': AppImages.person,
      'status': 'Last seen 1 hour ago',
    },
    {
      'name': 'Priya Singh',
      'avatar': AppImages.serviceProvider,
      'status': 'Last seen 3 hours ago',
    },
    {
      'name': 'Karan Mehta',
      'avatar': AppImages.person,
      'status': 'Last seen 2 days ago',
    },
  ];

  List<Map<String, String>> _results = const [];

  @override
  void initState() {
    super.initState();
    _results = _allUsers;
    _searchController.addListener(_onQueryChanged);
  }

  void _onQueryChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _results = query.isEmpty
          ? _allUsers
          : _allUsers
                .where((user) => user['name']!.toLowerCase().contains(query))
                .toList();
    });
  }

  void _openChat(Map<String, String> user) {
    // Dismiss the keyboard before navigating away.
    FocusManager.instance.primaryFocus?.unfocus();
    Get.toNamed(
      RouteNames.chatScreen,
      arguments: {
        'name': user['name'],
        'avatar': user['avatar'],
        'status': user['status'],
      },
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(_onQueryChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Tap anywhere outside the search field to close the keyboard.
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: AppColors.background,
        // Let the sheet resize above the keyboard instead of overflowing.
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(height: AppDimensions.padding15h),

              // Header: Back button + Search Bar (same as Home screen)
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.padding20w,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Image.asset(
                        AppImages.back,
                        width: AppDimensions.containerWidth20w,
                        height: AppDimensions.containerHeight20h,
                        color: AppColors.text,
                      ),
                    ),
                    SizedBox(width: AppDimensions.padding12w),
                    Expanded(
                      child: CustomSearchBar(
                        hintText: 'Search for Services...',
                        controller: _searchController,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppDimensions.padding20h),

              // Results List (scrolls independently so the keyboard never
              // overlaps the input, and shrinks gracefully when it opens).
              Expanded(
                child: _results.isEmpty
                    ? Center(
                        child: Text(
                          'No results found',
                          style: customTextStyle(
                            AppTextSizes.largeTextSize,
                            AppColors.chatSubText,
                            FontWeight.w400,
                          ),
                        ),
                      )
                    : ListView.builder(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDimensions.padding20w,
                        ),
                        itemCount: _results.length,
                        itemBuilder: (context, index) {
                          final user = _results[index];
                          return ChatSearchUserCard(
                            avatar: user['avatar']!,
                            name: user['name']!,
                            status: user['status']!,
                            onTap: () => _openChat(user),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
