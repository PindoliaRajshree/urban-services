// File: lib/features/home/home_screen.dart
// Purpose: The primary dashboard for users to explore services, categories, and top-rated providers.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:urban_services/widgets/home_header.dart';
import 'package:urban_services/routes/route_args.dart';
import 'package:urban_services/routes/route_names.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_images.dart';
import 'package:urban_services/core/session/session_provider.dart';
import 'package:urban_services/features/address/address_provider.dart';
import 'package:urban_services/widgets/category_item.dart';
import 'package:urban_services/widgets/custom_search_bar.dart';
import 'package:urban_services/widgets/section_heading.dart';
import 'package:urban_services/widgets/top_rated_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // Current index for the promotional slider
  int _currentSliderIndex = 0;

  /// Opens the address screen to change the saved address; it pops back
  /// here after saving.
  void _openAddress() => context.push(
    RouteNames.addressScreen,
    extra: const AddressArgs(manage: true),
  );

  @override
  Widget build(BuildContext context) {
    final firstName = ref.watch(sessionProvider.select((s) => s.firstName));
    final address = ref.watch(addressProvider.select((s) => s.address));
    final location = [
      address?.city,
      address?.state,
    ].where((part) => part != null && part.trim().isNotEmpty).join(', ');

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
                  HomeHeader(
                    firstName: firstName,
                    showcaseDescription:
                        'Tap your photo to complete your basic profile details.',
                    // The basic profile-completion screen (name, photo,
                    // mobile, email, gender, DOB), not the provider wizard.
                    onAvatarTap: () => context.push(RouteNames.completeProfile),
                    location: location.isNotEmpty
                        ? location
                        : 'Add your address',
                    onLocationTap: _openAddress,
                    actions: [
                      GestureDetector(
                        onTap: _openAddress,
                        child: Image.asset(
                          AppImages.homeLocation,
                          height: AppDimensions.containerHeight50h,
                          width: AppDimensions.containerWidth50w,
                        ),
                      ),
                      GestureDetector(
                        onTap: () =>
                            context.push(RouteNames.notificationScreen),
                        child: Image.asset(
                          AppImages.notification,
                          height: AppDimensions.containerHeight50h,
                          width: AppDimensions.containerWidth50w,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: AppDimensions.padding8h),

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
                      },
                    ),
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
                          onTap: () => context.push(
                            RouteNames.serviceCategoryScreen,
                            extra: ServiceCategoryArgs(
                              categoryTitle: 'Cleaning Service',
                              serviceCount: '30+ Services',
                            ),
                          ),
                        ),
                        SizedBox(width: AppDimensions.padding15w),
                        CategoryItem(
                          icon: AppImages.electrician,
                          title: 'Electrician',
                          onTap: () => context.push(
                            RouteNames.serviceCategoryScreen,
                            extra: ServiceCategoryArgs(
                              categoryTitle: 'Electrician Service',
                              serviceCount: '30+ Services',
                            ),
                          ),
                        ),
                        SizedBox(width: AppDimensions.padding15w),
                        CategoryItem(
                          icon: AppImages.plumber,
                          title: 'Plumber',
                          onTap: () => context.push(
                            RouteNames.serviceCategoryScreen,
                            extra: ServiceCategoryArgs(
                              categoryTitle: 'Plumber Service',
                              serviceCount: '30+ Services',
                            ),
                          ),
                        ),
                        SizedBox(width: AppDimensions.padding15w),
                        CategoryItem(
                          icon: AppImages.laundry,
                          title: 'Laundry',
                          onTap: () => context.push(
                            RouteNames.serviceCategoryScreen,
                            extra: ServiceCategoryArgs(
                              categoryTitle: 'Laundry Service',
                              serviceCount: '30+ Services',
                            ),
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
