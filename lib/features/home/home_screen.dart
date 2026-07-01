// File: lib/features/home/home_screen.dart
// Purpose: The primary dashboard for users to explore services, categories, and top-rated providers.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urban_services/routes/route_names.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_images.dart';
import 'package:urban_services/core/constants/app_text_sizes.dart';
import 'package:urban_services/widgets/category_item.dart';
import 'package:urban_services/widgets/complete_profile_card.dart';
import 'package:urban_services/widgets/custom_text_style.dart';
import 'package:urban_services/widgets/section_heading.dart';
import 'package:urban_services/widgets/top_rated_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Current index for the promotional slider
  int _currentSliderIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: Stack(
        children: [
          // 1. Vector Background Image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(AppImages.vector, fit: BoxFit.fitWidth),
          ),

          // Main Scrollable Content
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.padding20w,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: AppDimensions.padding15h),

                  // 3. User Profile and Location Header
                  Row(
                    children: [
                      // User Avatar with Shadow
                      Container(
                        width: AppDimensions.containerWidth45w,
                        height: AppDimensions.containerHeight45h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primaryDark,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              offset: const Offset(0, 1),
                              blurRadius: 2.9,
                              spreadRadius: 0,
                            ),
                          ],
                          image: const DecorationImage(
                            image: AssetImage(AppImages.image),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(width: AppDimensions.padding10w),
                      // Greeting and Location
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hi, Anamika',
                            style: customTextStyle(
                              AppTextSizes.smallTextSize, // 10
                              AppColors.text,
                              FontWeight.w600,
                            ),
                          ),
                          Row(
                            children: [
                              Image.asset(
                                AppImages.placeMarker,
                                height: AppDimensions.containerHeight15h,
                                width: AppDimensions.containerWidth15w,
                              ),
                              SizedBox(width: AppDimensions.padding4w),
                              Text(
                                'Indore, MP',
                                style: customTextStyle(
                                  AppTextSizes.smallTextSize, // 10
                                  AppColors.text,
                                  FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Action Icons
                      Image.asset(
                        AppImages.homeLocation,
                        height: AppDimensions.containerHeight50h,
                        width: AppDimensions.containerWidth50w,
                      ),
                      SizedBox(width: AppDimensions.padding15w),
                      Image.asset(
                        AppImages.addToCart,
                        height: AppDimensions.containerHeight50h,
                        width: AppDimensions.containerWidth50w,
                      ),
                      SizedBox(width: AppDimensions.padding15w),
                      GestureDetector(
                        onTap: () => Get.toNamed(RouteNames.notificationScreen),
                        child: Icon(Icons.notifications_on_outlined,color: AppColors.primaryDark,size: AppDimensions.radius30r,),
                      ),
                    ],
                  ),

                  // Complete Your Profile Section with Animation
                  CompleteProfileCard(
                    onFinish: () {
                      // Navigate to profile completion or settings
                    },
                  ),

                  // 4. Search Bar
                  Container(
                    height: AppDimensions.containerHeight45h,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radius30r,
                      ),
                      border: Border.all(color: AppColors.white, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          offset: const Offset(0, 1),
                          blurRadius: 4,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.padding15w,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: AppColors.grey),
                        SizedBox(width: AppDimensions.padding10w),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search',
                              hintStyle: customTextStyle(
                                AppTextSizes.smallTextSize, // 12
                                AppColors.darkGrey,
                                FontWeight.w400,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            style: customTextStyle(
                              AppTextSizes.smallTextSize, // 12
                              AppColors.black,
                              FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: AppDimensions.padding20h),

                  // 5. Promotional Slider
                  SizedBox(
                    height: AppDimensions.containerHeight200h,
                    child: PageView.builder(
                      itemCount: 5,
                      onPageChanged: (index) {
                        setState(() {
                          _currentSliderIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: AppDimensions.padding4w,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radius12r,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                offset: const Offset(0, 4),
                                blurRadius: 4,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radius12r,
                            ),
                            child: Image.asset(
                              AppImages.ads,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: AppDimensions.padding10h),
                  // Dots Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final isSelected = _currentSliderIndex == index;
                      return Container(
                        width: AppDimensions.containerWidth7w,
                        height: AppDimensions.containerHeight7h,
                        margin: EdgeInsets.symmetric(
                          horizontal: AppDimensions.padding4w,
                        ),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: !isSelected ? AppColors.lightGrey2 : null,
                          gradient: isSelected ? AppColors.gradient : null,
                        ),
                      );
                    }),
                  ),

                  SizedBox(height: AppDimensions.padding10h),

                  // 6. Categories Section
                  const SectionHeading(title: 'Categories'),
                  SizedBox(height: AppDimensions.padding15h),
                  // Horizontal Categories List
                  SizedBox(
                    height: AppDimensions.containerHeight110h,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        const CategoryItem(
                          icon: AppImages.cleaningService,
                          title: 'Cleaning',
                        ),
                        SizedBox(width: AppDimensions.padding15w),
                        const CategoryItem(
                          icon: AppImages.electrician,
                          title: 'Electrician',
                        ),
                        SizedBox(width: AppDimensions.padding15w),
                        const CategoryItem(
                          icon: AppImages.plumber,
                          title: 'Plumber',
                        ),
                        SizedBox(width: AppDimensions.padding15w),
                        const CategoryItem(
                          icon: AppImages.laundry,
                          title: 'Laundry',
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: AppDimensions.padding10h),

                  // 8. Top Rated Section
                  const SectionHeading(title: 'Top Rated'),
                  SizedBox(height: AppDimensions.padding15h),
                  // Vertical Top Rated List
                  const TopRatedCard(
                    name: 'Devon Lane',
                    category: 'Plumber',
                    price: '\$20/Hour',
                    rating: '4.2',
                    image: AppImages.serviceProvider,
                  ),
                  const TopRatedCard(
                    name: 'Devon Lane',
                    category: 'Plumber',
                    price: '\$20/Hour',
                    rating: '4.2',
                    image: AppImages.serviceProvider,
                  ),

                  SizedBox(height: AppDimensions.padding70h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
