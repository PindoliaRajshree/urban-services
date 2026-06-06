import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_images.dart';
import 'package:urban_services/core/constants/app_text_sizes.dart';
import 'package:urban_services/features/address/address_controller.dart';
import 'package:urban_services/routes/route_names.dart';
import 'package:urban_services/widgets/custom_text_style.dart';
import 'package:urban_services/widgets/location_accuracy_dialog.dart';
import 'package:urban_services/widgets/primary_button.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final controller = Get.put(AddressController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    // Bottom layer: vector image
                    Image.asset(
                      AppImages.vector,
                      width: double.infinity,
                      fit: BoxFit.fitWidth,
                    ),

                    // Top layer: address image with 70 top padding
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
                padding: EdgeInsets.symmetric(horizontal: AppDimensions.padding20w),
                child: Column(
                  children: [
                    SizedBox(height: AppDimensions.padding20h),
                    
                    // 1. Select Your Service Address Text
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
                    
                    // 2. Horizontal divider with gradient
                    Container(
                      width: AppDimensions.containerWidth75w,
                      height: AppDimensions.containerHeight5h,
                      decoration: BoxDecoration(
                        gradient: AppColors.gradient,
                        borderRadius: BorderRadius.circular(AppDimensions.radius10r),
                      ),
                    ),
                    
                    SizedBox(height: AppDimensions.padding15h),
                    
                    // 3. Choose the address description Text
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
                    
                    // 4. Current Location Container
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(AppDimensions.radius5r),
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
                          
                          // Enable Gradient Button
                          GestureDetector(
                            onTap: () {
                              Get.dialog(
                                const LocationAccuracyDialog(),
                                barrierDismissible: false,
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppDimensions.padding12w,
                                vertical: AppDimensions.padding4h,
                              ),
                              decoration: BoxDecoration(
                                gradient: AppColors.gradient,
                                borderRadius: BorderRadius.circular(AppDimensions.radius3r),
                              ),
                              child: Text(
                                'Enable',
                                style: customTextStyle(
                                  AppTextSizes.smallTextSize,
                                  AppColors.white,
                                  FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: AppDimensions.padding20h),

                    // 5. Address Detail Card
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(AppDimensions.radius12r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withValues(alpha: 0.25),
                            blurRadius: 9.66,
                            spreadRadius: 0,
                            offset: Offset(0, AppDimensions.containerHeight9_66h),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Container
                          Container(
                            padding: EdgeInsets.all(AppDimensions.padding15h),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(AppDimensions.radius12r),
                                topRight: Radius.circular(AppDimensions.radius12r),
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

                          // Content Area
                          Padding(
                            padding: EdgeInsets.all(AppDimensions.padding15h),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 1st Row: City
                                Text(
                                  'Indore MP',
                                  style: customTextStyle(
                                    AppTextSizes.smallTextSize,
                                    AppColors.primary,
                                    FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: AppDimensions.padding8h),
                                
                                // 2nd Row: Detailed Address
                                Text(
                                  '1016, opposite Shalimar township, Sector B, Slice 5. Aranya Nagar, Scheme 78, Vijay Nagar.',
                                  style: customTextStyle(
                                    AppTextSizes.stableTextSize,
                                    AppColors.darkGrey2,
                                    FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // 3rd Row: Change Address Button (Sticking to edge)
                          Align(
                            alignment: Alignment.bottomRight,
                            child: GestureDetector(
                              onTap: () => Get.toNamed(RouteNames.addAddressScreen),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppDimensions.padding15w,
                                  vertical: AppDimensions.padding8h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(AppDimensions.radius12r),
                                    bottomRight: Radius.circular(AppDimensions.radius12r),
                                  ),
                                ),
                                child: Text(
                                  'Change Address',
                                  style: customTextStyle(
                                    AppTextSizes.stableTextSize,
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
                    SizedBox(height: AppDimensions.padding30h),

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
