// File: lib/features/home/home_screen.dart
// Purpose: The primary dashboard for users to explore services, categories, and top-rated providers.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:urban_services/routes/route_names.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_images.dart';
import 'package:urban_services/core/constants/app_text_sizes.dart';
import 'package:urban_services/widgets/category_item.dart';
import 'package:urban_services/widgets/custom_search_bar.dart';
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

  // Spotlights the profile avatar with a "complete your profile" callout.
  final GlobalKey _profileShowcaseKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Runs every time this screen is built — there's no "seen it already"
    // flag yet, so the callout shows on every visit to Home for now.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ShowCaseWidget.of(context).startShowCase([_profileShowcaseKey]);
    });
  }

  /// Sends the user to the provider onboarding form — this is the
  /// "become a provider" entry point, not a generic user-profile edit
  /// screen. `disableDefaultTargetGestures: true` below means the
  /// package's own tap handling (and its `disposeOnTap` logic) never
  /// runs, so the showcase is dismissed explicitly here before navigating.
  void _onProfileShowcaseTap() {
    ShowCaseWidget.of(context).dismiss();
    Get.toNamed(RouteNames.completeProviderProfile);
  }

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
                      // User Avatar with Shadow — showcased with a
                      // "complete your profile" spotlight + arrow, and now
                      // actually tappable (it wasn't before).
                      Showcase(
                        key: _profileShowcaseKey,
                        title: 'Complete Your Profile',
                        description:
                            'Tap your photo to finish setting up your provider details and start offering services.',
                        targetShapeBorder: const CircleBorder(),
                        tooltipBackgroundColor: AppColors.primaryDark,
                        textColor: AppColors.white,
                        titleTextStyle: customTextStyle(
                          AppTextSizes.largeTextSize,
                          AppColors.white,
                          FontWeight.w700,
                        ),
                        descTextStyle: customTextStyle(
                          AppTextSizes.smallTextSize,
                          AppColors.white,
                          FontWeight.w400,
                        ),
                        disableDefaultTargetGestures: true,
                        onTargetClick: _onProfileShowcaseTap,
                        disposeOnTap: true,
                        child: GestureDetector(
                          onTap: _onProfileShowcaseTap,
                          child: Container(
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
                      // SizedBox(width: AppDimensions.padding8w),
                      // Image.asset(
                      //   AppImages.addToCart,
                      //   height: AppDimensions.containerHeight50h,
                      //   width: AppDimensions.containerWidth50w,
                      // ),
                      // SizedBox(width: AppDimensions.padding15w),
                      GestureDetector(
                        onTap: () => Get.toNamed(RouteNames.notificationScreen),
                        child: Image.asset(
                          AppImages.notification,
                          height: AppDimensions.containerHeight50h,
                          width: AppDimensions.containerWidth50w,
                        ),
                      ),
                    ],
                  ),

                  // Complete Your Profile Section with Animation
                  // CompleteProfileCard(
                  //   onFinish: () {
                  //     Get.toNamed(RouteNames.completeProviderProfile);
                  //   },
                  // ),

                  SizedBox(height: AppDimensions.padding8h,),

                  // 4. Search Bar
                  const CustomSearchBar(hintText: 'Search'),

                  SizedBox(height: AppDimensions.padding20h),

                  // 5. Promotional Slider
                  SizedBox(
                    height: AppDimensions.containerHeight200h,
                    child: PageView.builder(
                      itemCount: AppImages.promotionalBanners.length,
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
                              AppImages.promotionalBanners[index],
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
                    children: List.generate(
                      AppImages.promotionalBanners.length,
                      (index) {
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
                        CategoryItem(
                          icon: AppImages.cleaningService,
                          title: 'Cleaning',
                          onTap: () => Get.toNamed(
                            RouteNames.serviceCategoryScreen,
                            arguments: {
                              'categoryTitle': 'Cleaning Service',
                              'serviceCount': '30+ Services',
                            },
                          ),
                        ),
                        SizedBox(width: AppDimensions.padding15w),
                        CategoryItem(
                          icon: AppImages.electrician,
                          title: 'Electrician',
                          onTap: () => Get.toNamed(
                            RouteNames.serviceCategoryScreen,
                            arguments: {
                              'categoryTitle': 'Electrician Service',
                              'serviceCount': '30+ Services',
                            },
                          ),
                        ),
                        SizedBox(width: AppDimensions.padding15w),
                        CategoryItem(
                          icon: AppImages.plumber,
                          title: 'Plumber',
                          onTap: () => Get.toNamed(
                            RouteNames.serviceCategoryScreen,
                            arguments: {
                              'categoryTitle': 'Plumber Service',
                              'serviceCount': '30+ Services',
                            },
                          ),
                        ),
                        SizedBox(width: AppDimensions.padding15w),
                        CategoryItem(
                          icon: AppImages.laundry,
                          title: 'Laundry',
                          onTap: () => Get.toNamed(
                            RouteNames.serviceCategoryScreen,
                            arguments: {
                              'categoryTitle': 'Laundry Service',
                              'serviceCount': '30+ Services',
                            },
                          ),
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
