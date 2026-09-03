// File: lib/widgets/address_choice_dialog.dart
// Purpose: Prompts the user to choose how to set their service address —
// enter it manually or use their current location. Shown when they try to
// continue without a saved address, and offered again whenever they go to
// add/change their address (even if one was already saved manually), so
// both paths always stay available.

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
import 'package:urban_services/widgets/secondary_button.dart';

class AddressChoiceDialog extends StatelessWidget {
  const AddressChoiceDialog({super.key});

  @override
  Widget build(BuildContext context) {
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
        padding: EdgeInsets.all(AppDimensions.padding20h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              'Set Your Address',
              style: customTextStyle(
                AppTextSizes.extraLargeTextSize, // 20
                AppColors.darkBlack,
                FontWeight.w600,
              ),
            ),
            SizedBox(height: AppDimensions.padding15h),

            // Message
            Text(
              'We need a service address to continue. How would you like to set it?',
              textAlign: TextAlign.center,
              style: customTextStyle(
                AppTextSizes.largeMediumTextSize, // 14
                AppColors.text,
                FontWeight.w500,
              ),
            ),
            SizedBox(height: AppDimensions.padding30h),

            // Option 1: Use current location (mirrors the loading state of
            // the "Use my Current Location" row on the address screen so
            // there's no dead tap while a fetch is already in flight).
            Obx(
              () => SecondaryButton(
                text: 'Use My Current Location',
                iconPath: AppImages.placeMarker,
                isLoading: controller.isFetchingLocation.value,
                onPressed: () {
                  Get.back(); // Close this dialog first.
                  controller.onCurrentLocationTap();
                },
              ),
            ),
            SizedBox(height: AppDimensions.padding15h),

            // Option 2: Enter address manually. Passes the saved address
            // (if any) so Add Address can prefill its fields when the user
            // is just switching a previously-set manual address.
            PrimaryButton(
              text: 'Enter Address Manually',
              onPressed: () {
                Get.back(); // Close this dialog first.
                Get.toNamed(
                  RouteNames.addAddressScreen,
                  arguments: controller.address.value,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
