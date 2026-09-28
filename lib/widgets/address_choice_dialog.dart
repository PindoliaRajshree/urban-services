// File: lib/widgets/address_choice_dialog.dart
// Purpose: Prompts the user to choose how to set their service address —
// enter it manually or use their current location. Shown when they try to
// continue without a saved address, and offered again whenever they go to
// add/change their address (even if one was already saved manually), so
// both paths always stay available.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_images.dart';
import 'package:urban_services/core/constants/app_text_sizes.dart';
import 'package:urban_services/features/address/address_provider.dart';
import 'package:urban_services/features/address/models/service_address_response.dart';
import 'package:urban_services/routes/route_names.dart';
import 'package:urban_services/widgets/custom_text_style.dart';
import 'package:urban_services/widgets/primary_button.dart';
import 'package:urban_services/widgets/secondary_button.dart';

class AddressChoiceDialog extends ConsumerWidget {
  const AddressChoiceDialog({super.key, required this.onUseCurrentLocation});

  /// Runs the address screen's "Use my Current Location" handling (which
  /// may open the Location Accuracy dialog) after this dialog closes.
  final VoidCallback onUseCurrentLocation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(addressProvider);

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
              state.hasCardAddress
                  ? 'How would you like to change your service address?'
                  : 'We need a service address to continue. How would you like to set it?',
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
            SecondaryButton(
              text: 'Use My Current Location',
              iconPath: AppImages.placeMarker,
              isLoading: state.isFetchingLocation,
              onPressed: () {
                Navigator.of(context).pop(); // Close this dialog first.
                onUseCurrentLocation();
              },
            ),
            SizedBox(height: AppDimensions.padding15h),

            // Option 2: Enter address manually. Prefills Add Address with
            // the unsaved manual entry if there is one (it's what the card
            // shows), otherwise with the saved address.
            PrimaryButton(
              text: 'Enter Address Manually',
              onPressed: () {
                final router = GoRouter.of(context);
                final pending = state.pendingManualAddress;
                Navigator.of(context).pop(); // Close this dialog first.
                router.push(
                  RouteNames.addAddressScreen,
                  extra: pending != null
                      ? ServiceAddressResponse.fromRequest(pending)
                      : state.address,
                );
              },
            ),
            SizedBox(height: AppDimensions.padding10h),

            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: customTextStyle(
                  AppTextSizes.largeTextSize,
                  AppColors.darkGrey,
                  FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
