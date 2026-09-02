// File: lib/features/address/add_address_screen.dart
// Purpose: Form screen for users to input and save a new service address.

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_text_sizes.dart';
import 'package:urban_services/features/address/add_address_controller.dart';
import 'package:urban_services/features/address/full_screen_map_picker.dart';
import 'package:urban_services/widgets/address_form_field.dart';
import 'package:urban_services/widgets/common_app_bar.dart';
import 'package:urban_services/widgets/custom_text_style.dart';
import 'package:urban_services/widgets/primary_button.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  // Initialize AddAddressController for form state and validation
  final controller = Get.put(AddAddressController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppDimensions.padding20w),
          child: Column(
            children: [
              // Standard AppBar with "Add New Address" title
              const CommonAppBar(title: 'Add New Address', showMoreIcon: false),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Quick Action: Use Current Location — reverse
                      // geocodes the device's position onto the map and
                      // prefills Full Address / City / State / Pincode.
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDimensions.padding12w,
                        ),
                        child: Obx(
                          () => GestureDetector(
                            onTap: controller.isLocatingOnMap.value
                                ? null
                                : controller.useCurrentLocationOnMap,
                            child: Row(
                              children: [
                                controller.isLocatingOnMap.value
                                    ? SizedBox(
                                        height:
                                            AppDimensions.containerHeight15h,
                                        width: AppDimensions.containerWidth15w,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Icon(
                                        Icons.my_location,
                                        color: AppColors.primary,
                                        size: AppDimensions.containerHeight15h,
                                      ),
                                SizedBox(width: AppDimensions.padding8w),
                                Text(
                                  'Use Current Location',
                                  style: customTextStyle(
                                    AppTextSizes.stableTextSize,
                                    AppColors.black,
                                    FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: AppDimensions.padding15h),

                      // Live Google Map — tap anywhere to drop the pin
                      // there, or use "Use Current Location" above/on the
                      // map, or tap the expand icon for a full-screen,
                      // easier-to-use picker. All three reverse-geocode
                      // the picked point into the fields below.
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDimensions.padding12w,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radius18r,
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            height: AppDimensions.containerHeight280h,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Obx(
                                  () => GoogleMap(
                                    initialCameraPosition: CameraPosition(
                                      target: controller.initialMapPosition,
                                      zoom:
                                          controller.selectedPosition.value ==
                                              null
                                          ? 4
                                          : 16,
                                    ),
                                    onMapCreated: controller.onMapCreated,
                                    onTap: controller.onMapTapped,
                                    markers:
                                        controller.selectedPosition.value ==
                                            null
                                        ? const {}
                                        : {
                                            Marker(
                                              markerId: const MarkerId(
                                                'selected-address',
                                              ),
                                              position: controller
                                                  .selectedPosition
                                                  .value!,
                                            ),
                                          },
                                    myLocationButtonEnabled: false,
                                    zoomControlsEnabled: false,
                                    gestureRecognizers: {
                                      Factory<EagerGestureRecognizer>(
                                        () => EagerGestureRecognizer(),
                                      ),
                                    },
                                  ),
                                ),

                                // Expand / fullscreen button.
                                Positioned(
                                  top: AppDimensions.padding10h,
                                  right: AppDimensions.padding10w,
                                  child: _MapIconButton(
                                    icon: Icons.open_in_full,
                                    onTap: () async {
                                      final result = await Get.to<LatLng>(
                                        () => FullScreenMapPicker(
                                          initialPosition:
                                              controller.selectedPosition.value,
                                        ),
                                      );
                                      if (result != null) {
                                        await controller.applyPickedLocation(
                                          result,
                                        );
                                      }
                                    },
                                  ),
                                ),

                                // On-map "get current location" button.
                                Positioned(
                                  bottom: AppDimensions.padding10h,
                                  right: AppDimensions.padding10w,
                                  child: Obx(
                                    () => _MapIconButton(
                                      icon: Icons.my_location,
                                      isLoading:
                                          controller.isLocatingOnMap.value,
                                      onTap: controller.isLocatingOnMap.value
                                          ? null
                                          : controller.useCurrentLocationOnMap,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: AppDimensions.padding20h),

                      // --- ADDRESS FORM SECTION ---

                      // Flat / Apartment Input
                      Obx(
                        () => AddressFormField(
                          label: 'Flat/Apartment/Suite',
                          hintText: 'eg 101, A Wing Green Readency',
                          controller: controller.flatController,
                          focusNode: controller.flatFocus,
                          textInputAction: TextInputAction.next,
                          errorText: controller.flatError.value,
                        ),
                      ),
                      SizedBox(height: AppDimensions.padding15h),

                      // Floor / Building Input
                      Obx(
                        () => AddressFormField(
                          label: 'Floor/Building',
                          hintText: 'eg. 2nd Floor',
                          controller: controller.floorController,
                          focusNode: controller.floorFocus,
                          textInputAction: TextInputAction.next,
                          errorText: controller.floorError.value,
                        ),
                      ),
                      SizedBox(height: AppDimensions.padding15h),

                      // Building / Society / Landmark Input
                      Obx(
                        () => AddressFormField(
                          label: 'Building/Society/Landmark',
                          hintText: 'eg. Indus Business School',
                          controller: controller.buildingController,
                          focusNode: controller.buildingFocus,
                          textInputAction: TextInputAction.next,
                          errorText: controller.buildingError.value,
                        ),
                      ),
                      SizedBox(height: AppDimensions.padding15h),

                      // Full Address Input (Multi-line)
                      Obx(
                        () => AddressFormField(
                          label: 'Full Address',
                          hintText:
                              'REBM, Indus Business School, Tonk Phatak Jaipur, Rajasthan-302015',
                          controller: controller.fullAddressController,
                          focusNode: controller.fullAddressFocus,
                          maxLines: 3,
                          textInputAction: TextInputAction.next,
                          errorText: controller.fullAddressError.value,
                        ),
                      ),
                      SizedBox(height: AppDimensions.padding15h),

                      // Optional Landmark Input
                      AddressFormField(
                        label: 'Landmark (Optional)',
                        hintText: 'eg. Near Tonk Phatak',
                        controller: controller.landmarkController,
                        focusNode: controller.landmarkFocus,
                        textInputAction: TextInputAction.next,
                      ),
                      SizedBox(height: AppDimensions.padding15h),

                      // City Input
                      Obx(
                        () => AddressFormField(
                          label: 'City',
                          hintText: 'eg. Jaipur',
                          controller: controller.cityController,
                          focusNode: controller.cityFocus,
                          textInputAction: TextInputAction.next,
                          errorText: controller.cityError.value,
                        ),
                      ),
                      SizedBox(height: AppDimensions.padding15h),

                      // State Input
                      Obx(
                        () => AddressFormField(
                          label: 'State',
                          hintText: 'eg. Rajasthan',
                          controller: controller.stateController,
                          focusNode: controller.stateFocus,
                          textInputAction: TextInputAction.next,
                          errorText: controller.stateError.value,
                        ),
                      ),
                      SizedBox(height: AppDimensions.padding15h),

                      // Pincode Input
                      Obx(
                        () => AddressFormField(
                          label: 'Pincode',
                          hintText: 'eg. 302015',
                          controller: controller.pincodeController,
                          focusNode: controller.pincodeFocus,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          errorText: controller.pincodeError.value,
                        ),
                      ),

                      SizedBox(height: AppDimensions.padding15h),

                      // Settings: Save as Default Address
                      Obx(
                        () => Row(
                          children: [
                            Checkbox(
                              value: controller.isDefault.value,
                              onChanged: (val) =>
                                  controller.isDefault.value = val ?? false,
                              activeColor: AppColors.primary,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: const VisualDensity(
                                horizontal: -4,
                                vertical: -4,
                              ),
                            ),
                            SizedBox(width: AppDimensions.padding8w),
                            Text(
                              'Save as default address',
                              style: customTextStyle(
                                AppTextSizes.smallTextSize,
                                AppColors.text,
                                FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: AppDimensions.padding30h),

                      // Primary Action: Save address and navigate
                      Obx(
                        () => PrimaryButton(
                          text: 'Save',
                          isLoading: controller.isLoading,
                          onPressed: controller.saveAddress,
                        ),
                      ),

                      SizedBox(height: AppDimensions.padding30h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


/// Small round icon button used for the overlay controls on top of the
/// map (expand / current-location) — kept local to this screen since it
/// isn't reused elsewhere.
class _MapIconButton extends StatelessWidget {
  const _MapIconButton({
    required this.icon,
    required this.onTap,
    this.isLoading = false,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      shape: const CircleBorder(),
      elevation: 3,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.padding8w),
          child: isLoading
              ? SizedBox(
                  height: AppDimensions.containerHeight18h,
                  width: AppDimensions.containerWidth18w,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  icon,
                  color: AppColors.primary,
                  size: AppDimensions.containerHeight20h,
                ),
        ),
      ),
    );
  }
}

