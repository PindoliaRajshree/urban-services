// File: lib/widgets/location_accuracy_dialog.dart
// Purpose: A custom system-style dialog to request Location Accuracy from the user.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_images.dart';
import 'package:urban_services/core/constants/app_text_sizes.dart';
import 'package:urban_services/features/address/address_controller.dart';
import 'package:urban_services/widgets/custom_text_style.dart';

class LocationAccuracyDialog extends StatelessWidget {
  const LocationAccuracyDialog({super.key});

  @override
  Widget build(BuildContext context) {
    // Access AddressController to handle button actions
    final controller = Get.find<AddressController>();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: AppDimensions.padding20w),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radius20r),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.17),
              blurRadius: 4,
              spreadRadius: 1,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: AppDimensions.padding20h),

            // 1. Heading: Benefit explanation
            Padding(
              padding: EdgeInsets.only(
                left: AppDimensions.padding40w,
                right: AppDimensions.padding20w,
              ),
              child: Text(
                'For a better experience, your device will need to use Location Accuracy',
                style: customTextStyle(15, AppColors.text, FontWeight.w600),
              ),
            ),

            SizedBox(height: AppDimensions.padding15h),

            // 2. Subheading: Required settings
            Padding(
              padding: EdgeInsets.only(
                left: AppDimensions.padding40w,
                right: AppDimensions.padding20w,
              ),
              child: Text(
                'The following settings should be on:',
                style: customTextStyle(
                  14,
                  AppColors.primaryDark,
                  FontWeight.w500,
                ),
              ),
            ),

            SizedBox(height: AppDimensions.padding20h),

            // 3. Info Item: Device Location
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.padding16w,
              ),
              child: Row(
                children: [
                  Image.asset(
                    AppImages.placeMarker,
                    height: AppDimensions.containerHeight20h,
                    width: AppDimensions.containerWidth20w,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Device location',
                    style: customTextStyle(15, AppColors.text, FontWeight.w600),
                  ),
                ],
              ),
            ),

            SizedBox(height: AppDimensions.padding15h),

            // 4. Detailed explanation with Clock icon
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.padding16w,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    AppImages.clock,
                    height: AppDimensions.containerHeight20h,
                    width: AppDimensions.containerWidth20w,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      'Location Accuracy, which provides more accurate location for apps and services. To do this, Google periodically processes information about device sensors and wireless signals from your device to crowdsource wireless signal locations. These are used without identifying you to improve location accuracy and location-based services and to improve, provide and maintain Google\'s services based on Google\'s and third parties legitimate interests to serve users\' needs.',
                      style: customTextStyle(
                        AppTextSizes.smallTextSize,
                        AppColors.text,
                        FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: AppDimensions.padding20h),

            // 5. Footer: Settings manage info and RichText link
            Padding(
              padding: EdgeInsets.only(
                left: AppDimensions.padding40w,
                right: AppDimensions.padding20w,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'You can change this at any time in location settings.',
                    style: customTextStyle(
                      AppTextSizes.smallTextSize,
                      AppColors.text,
                      FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      text: 'Manage settings or\nlearn more',
                      style: customTextStyle(
                        15,
                        AppColors.primaryDark,
                        FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: AppDimensions.padding30h),

            // 6. Action Buttons: Dismiss vs. Enable
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.padding40w,
              ),
              child: Row(
                children: [
                  // Negative Action: Close Dialog
                  Expanded(
                    child: TextButton(
                      onPressed: controller.closeDialog,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: AppDimensions.padding12h,
                        ),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      child: Text(
                        'No, thanks',
                        style: customTextStyle(
                          AppTextSizes.largeTextSize,
                          AppColors.darkGrey,
                          FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Positive Action: Trigger Permission Request
                  Expanded(
                    child: ElevatedButton(
                      onPressed: controller.requestLocationPermission,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: EdgeInsets.symmetric(
                          vertical: AppDimensions.padding12h,
                        ),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Turn on',
                        style: customTextStyle(
                          AppTextSizes.largeTextSize,
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
          ],
        ),
      ),
    );
  }
}
