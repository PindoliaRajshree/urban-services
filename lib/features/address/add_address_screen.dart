import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_images.dart';
import 'package:urban_services/core/constants/app_text_sizes.dart';
import 'package:urban_services/features/address/add_address_controller.dart';
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
              const CommonAppBar(title: 'Add New Address', showMoreIcon: true),
              
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Use Current Location Row
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: AppDimensions.padding12w),
                        child: Row(
                          children: [
                            Image.asset(
                              AppImages.placeMarker,
                              height: AppDimensions.containerHeight15h,
                              width: AppDimensions.containerWidth15w,
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
                      
                      SizedBox(height: AppDimensions.padding15h),
                      
                      // Location Image
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: AppDimensions.padding12w),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppDimensions.radius18r),
                          child: Image.asset(
                            AppImages.locationImage,
                            width: double.infinity,
                            height: AppDimensions.containerHeight150h,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      
                      SizedBox(height: AppDimensions.padding20h),
                      
                      // Form Fields
                      Obx(() => AddressFormField(
                        label: 'Flat/Apartment/Suite',
                        hintText: 'eg 101, A Wing Green Readency',
                        controller: controller.flatController,
                        focusNode: controller.flatFocus,
                        textInputAction: TextInputAction.next,
                        errorText: controller.flatError.value,
                      )),
                      SizedBox(height: AppDimensions.padding15h),
                      
                      Obx(() => AddressFormField(
                        label: 'Floor/Building',
                        hintText: 'eg. 2nd Floor',
                        controller: controller.floorController,
                        focusNode: controller.floorFocus,
                        textInputAction: TextInputAction.next,
                        errorText: controller.floorError.value,
                      )),
                      SizedBox(height: AppDimensions.padding15h),
                      
                      Obx(() => AddressFormField(
                        label: 'Building/Society/Landmark',
                        hintText: 'eg. Indus Business School',
                        controller: controller.buildingController,
                        focusNode: controller.buildingFocus,
                        textInputAction: TextInputAction.next,
                        errorText: controller.buildingError.value,
                      )),
                      SizedBox(height: AppDimensions.padding15h),
                      
                      Obx(() => AddressFormField(
                        label: 'Full Address',
                        hintText: 'REBM, Indus Business School, Tonk Phatak Jaipur, Rajasthan-302015',
                        controller: controller.fullAddressController,
                        focusNode: controller.fullAddressFocus,
                        maxLines: 3,
                        textInputAction: TextInputAction.next,
                        errorText: controller.fullAddressError.value,
                      )),
                      SizedBox(height: AppDimensions.padding15h),
                      
                      AddressFormField(
                        label: 'Landmark (Optional)',
                        hintText: 'eg. Near Tonk Phatak',
                        controller: controller.landmarkController,
                        focusNode: controller.landmarkFocus,
                        textInputAction: TextInputAction.done,
                      ),
                      
                      SizedBox(height: AppDimensions.padding15h),
                      
                      // Checkbox
                      Obx(() => Row(
                        children: [
                          Checkbox(
                            value: controller.isDefault.value,
                            onChanged: (val) => controller.isDefault.value = val ?? false,
                            activeColor: AppColors.primary,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
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
                      )),
                      
                      SizedBox(height: AppDimensions.padding30h),
                      
                      // Save Button
                      PrimaryButton(
                        text: 'Save',
                        onPressed: controller.saveAddress,
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
