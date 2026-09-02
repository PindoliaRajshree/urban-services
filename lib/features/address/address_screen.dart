// File: lib/features/address/address_screen.dart
// Purpose: Screen for displaying the user's selected address and providing options to change it or use current location.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_images.dart';
import 'package:urban_services/core/constants/app_text_sizes.dart';
import 'package:urban_services/features/address/address_controller.dart';
import 'package:urban_services/routes/route_names.dart';
import 'package:urban_services/widgets/custom_text_style.dart';
import 'package:urban_services/widgets/primary_button.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  // Initialize AddressController for logic management
  final controller = Get.put(AddressController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Top Image Section: Vector background with Address Image overlay
              SizedBox(
                width: double.infinity,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    // Base vector image
                    Image.asset(
                      AppImages.vector,
                      width: double.infinity,
                      fit: BoxFit.fitWidth,
                    ),

                    // Overlaid address image with specific top padding
                    Padding(
                      padding: EdgeInsets.only(top: AppDimensions.padding70h),
                      child: Image.asset(
                        AppImages.addressImage,
                        height: AppDimensions.containerHeight200h,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.padding20w,
                ),
                child: Column(
                  children: [
                    SizedBox(height: AppDimensions.padding20h),

                    // 1. Title Section
                    Text(
                      'Select Your Service Address',
                      textAlign: TextAlign.center,
                      style: customTextStyle(
                        AppTextSizes.headingTextSize,
                        AppColors.black,
                        FontWeight.w600,
                      ),
                    ),

                    SizedBox(height: AppDimensions.padding10h),

                    // 2. Gradient Divider
                    Container(
                      width: AppDimensions.containerWidth75w,
                      height: AppDimensions.containerHeight5h,
                      decoration: BoxDecoration(
                        gradient: AppColors.gradient,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radius10r,
                        ),
                      ),
                    ),

                    SizedBox(height: AppDimensions.padding15h),

                    // 3. Description Section
                    Text(
                      'Choose the address where you want the service to be provided.',
                      textAlign: TextAlign.center,
                      style: customTextStyle(
                        AppTextSizes.largeTextSize,
                        AppColors.black,
                        FontWeight.w400,
                      ),
                    ),

                    SizedBox(height: AppDimensions.padding20h),

                    // 4. Current Location Action Container
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radius5r,
                        ),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.padding15w,
                        vertical: AppDimensions.padding10h,
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            AppImages.placeMarker,
                            height: AppDimensions.containerHeight18h,
                            width: AppDimensions.containerWidth18w,
                          ),
                          SizedBox(width: AppDimensions.padding10w),
                          Text(
                            'Use my Current Location',
                            style: customTextStyle(
                              AppTextSizes.smallTextSize,
                              AppColors.black,
                              FontWeight.w400,
                            ),
                          ),
                          const Spacer(),

                          // Enable Button: skips the dialog when permission is
                          // already granted (goes straight to fetch + save);
                          // shows the Location Accuracy dialog otherwise.
                          Obx(
                            () => GestureDetector(
                              onTap: controller.isFetchingLocation.value
                                  ? null
                                  : controller.onUseCurrentLocationTap,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppDimensions.padding12w,
                                  vertical: AppDimensions.padding4h,
                                ),
                                decoration: BoxDecoration(
                                  gradient: AppColors.gradient,
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.radius3r,
                                  ),
                                ),
                                child: controller.isFetchingLocation.value
                                    ? SizedBox(
                                        height: AppDimensions.containerHeight15h,
                                        width: AppDimensions.containerWidth15w,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                AppColors.white,
                                              ),
                                        ),
                                      )
                                    : Text(
                                        'Enable',
                                        style: customTextStyle(
                                          AppTextSizes.smallTextSize,
                                          AppColors.white,
                                          FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: AppDimensions.padding20h),

                    // 5. Selected Address Detail Card
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radius12r,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withValues(alpha: 0.25),
                            blurRadius: 9.66,
                            spreadRadius: 0,
                            offset: Offset(
                              0,
                              AppDimensions.containerHeight9_66h,
                            ),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header: Card label and radio-style indicator
                          Container(
                            padding: EdgeInsets.all(AppDimensions.padding15h),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(
                                  AppDimensions.radius12r,
                                ),
                                topRight: Radius.circular(
                                  AppDimensions.radius12r,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'CHOOSE YOUR ADDRESS',
                                  style: customTextStyle(
                                    AppTextSizes.smallTextSize,
                                    AppColors.text,
                                    FontWeight.w500,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  height: AppDimensions.containerHeight15h,
                                  width: AppDimensions.containerWidth15w,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.text,
                                      width: 1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Content: City and Detailed Address text
                          Padding(
                            padding: EdgeInsets.all(AppDimensions.padding15h),
                            child: Obx(() {
                              if (controller.isLoadingAddress) {
                                return SizedBox(
                                  height: AppDimensions.containerHeight18h,
                                  width: AppDimensions.containerWidth18w,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                );
                              }

                              final address = controller.address.value;
                              if (address == null) {
                                return Text(
                                  'No address saved yet. Add one below.',
                                  style: customTextStyle(
                                    AppTextSizes.stableTextSize,
                                    AppColors.darkGrey2,
                                    FontWeight.w400,
                                  ),
                                );
                              }

                              final cityLine = [address.city, address.state]
                                  .where(
                                    (part) =>
                                        part != null && part.trim().isNotEmpty,
                                  )
                                  .join(', ');

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // City/Area Row
                                  if (cityLine.isNotEmpty) ...[
                                    Text(
                                      cityLine,
                                      style: customTextStyle(
                                        AppTextSizes.smallTextSize,
                                        AppColors.primary,
                                        FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: AppDimensions.padding8h),
                                  ],

                                  // Full Address String
                                  Text(
                                    address.fullAddress ?? '',
                                    style: customTextStyle(
                                      AppTextSizes.stableTextSize,
                                      AppColors.darkGrey2,
                                      FontWeight.w400,
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ),

                          // Action: Change/Add Address Button (Flush to
                          // bottom-right edge). Passes the saved address (if
                          // any) so Add Address can prefill its fields.
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Obx(
                              () => GestureDetector(
                                onTap: () => Get.toNamed(
                                  RouteNames.addAddressScreen,
                                  arguments: controller.address.value,
                                ),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: AppDimensions.padding15w,
                                    vertical: AppDimensions.padding8h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(
                                        AppDimensions.radius12r,
                                      ),
                                      bottomRight: Radius.circular(
                                        AppDimensions.radius12r,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    controller.hasAddress
                                        ? 'Change Address'
                                        : 'Add Address',
                                    style: customTextStyle(
                                      AppTextSizes.stableTextSize,
                                      AppColors.white,
                                      FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppDimensions.padding30h),

                    // Primary Action: Navigate to Home
                    PrimaryButton(
                      text: 'Next',
                      onPressed: () => Get.offAllNamed(RouteNames.homeMain),
                    ),

                    SizedBox(height: AppDimensions.padding30h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
