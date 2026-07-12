// File: lib/features/service_category/service_category_screen.dart
// Purpose: Lists all services under a category (opened from a category card on the Home screen).

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_images.dart';
import 'package:urban_services/routes/route_names.dart';
import 'package:urban_services/widgets/common_app_bar.dart';
import 'package:urban_services/widgets/custom_search_bar.dart';
import 'package:urban_services/widgets/custom_text_style.dart';
import 'package:urban_services/widgets/service_category_card.dart';

class _CategoryService {
  final String title;
  final String subtitle;
  final String rating;
  final String reviewCount;
  final String price;
  final String imagePath;

  const _CategoryService({
    required this.title,
    required this.subtitle,
    required this.rating,
    required this.reviewCount,
    required this.price,
    required this.imagePath,
  });
}

class ServiceCategoryScreen extends StatelessWidget {
  /// Title shown in the header, e.g. "Cleaning Service"
  final String categoryTitle;

  /// Subtitle shown under the header, e.g. "30+ Services"
  final String serviceCount;

  const ServiceCategoryScreen({
    super.key,
    this.categoryTitle = 'Cleaning Service',
    this.serviceCount = '30+ Services',
  });

  // Dummy service data
  static const List<_CategoryService> _services = [
    _CategoryService(
      title: 'Deep Cleaning',
      subtitle: 'Full home deep cleaning',
      rating: '4.6',
      reviewCount: '256',
      price: '699',
      imagePath: AppImages.serviceDeep,
    ),
    _CategoryService(
      title: 'Bathroom Cleaning',
      subtitle: 'Full home deep cleaning',
      rating: '4.6',
      reviewCount: '256',
      price: '599',
      imagePath: AppImages.serviceBathroom,
    ),
    _CategoryService(
      title: 'Sofa & Carpet Cleaning',
      subtitle: 'Full home deep cleaning',
      rating: '4.6',
      reviewCount: '256',
      price: '499',
      imagePath: AppImages.serviceSofa,
    ),
    _CategoryService(
      title: 'Kitchen Cleaning',
      subtitle: 'Full home deep cleaning',
      rating: '4.6',
      reviewCount: '256',
      price: '399',
      imagePath: AppImages.serviceKitchen,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(244, 249, 253, 1),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppDimensions.padding20w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AppDimensions.padding15h),
              CommonAppBar(title: categoryTitle, showMoreIcon: true),
              // SizedBox(height: AppDimensions.padding10h),

              // Subtitle: e.g. "30+ Services"
              Center(
                child: Text(
                  serviceCount,
                  style: customTextStyle(
                    14,
                    const Color.fromRGBO(109, 109, 109, 1),
                    FontWeight.w400,
                  ),
                ),
              ),
              SizedBox(height: AppDimensions.padding20h),

              // Search Bar
              const CustomSearchBar(hintText: 'Search for Services'),
              SizedBox(height: AppDimensions.padding15h),

              // Filter / Sort Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: Row(
                      children: [
                        Image.asset(
                          AppImages.filterPipe,
                          width: AppDimensions.containerWidth18w,
                          height: AppDimensions.containerHeight18h,
                        ),
                        SizedBox(width: AppDimensions.padding6w),
                        Text(
                          'Filter',
                          style: customTextStyle(
                            12,
                            const Color.fromRGBO(64, 64, 64, 1),
                            FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Row(
                      children: [
                        Image.asset(
                          AppImages.filterPipe,
                          width: AppDimensions.containerWidth18w,
                          height: AppDimensions.containerHeight18h,
                        ),
                        SizedBox(width: AppDimensions.padding6w),
                        Text(
                          'Sort',
                          style: customTextStyle(
                            12,
                            const Color.fromRGBO(64, 64, 64, 1),
                            FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppDimensions.padding20h),

              // Service Cards List
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.only(bottom: AppDimensions.padding20h),
                  itemCount: _services.length,
                  separatorBuilder: (_, _) =>
                      SizedBox(height: AppDimensions.padding15h),
                  itemBuilder: (context, index) {
                    final service = _services[index];
                    return ServiceCategoryCard(
                      title: service.title,
                      subtitle: service.subtitle,
                      rating: service.rating,
                      reviewCount: service.reviewCount,
                      price: service.price,
                      imagePath: service.imagePath,
                      onTap: () => Get.toNamed(
                        RouteNames.serviceDetailsScreen,
                        arguments: {
                          'imagePath': service.imagePath,
                          'reviewCount': service.reviewCount,
                          'price': service.price,
                        },
                      ),
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
