// File: lib/features/home/complete_profile/user_complete_profile_screen.dart
// Purpose: Single-section form for a regular user to complete their basic
// profile details (photo, name, mobile, email, gender, DOB).

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_images.dart';
import 'package:urban_services/core/constants/app_text_sizes.dart';
import 'package:urban_services/features/home/complete_profile/user_complete_profile_controller.dart';
import 'package:urban_services/widgets/address_form_field.dart';
import 'package:urban_services/widgets/common_app_bar.dart';
import 'package:urban_services/widgets/custom_dropdown.dart';
import 'package:urban_services/widgets/custom_text_style.dart';
import 'package:urban_services/widgets/dashed_border_painter.dart';
import 'package:urban_services/widgets/icon_header.dart';
import 'package:urban_services/widgets/primary_button.dart';

class UserCompleteProfileScreen extends StatefulWidget {
  const UserCompleteProfileScreen({super.key});

  @override
  State<UserCompleteProfileScreen> createState() =>
      _UserCompleteProfileScreenState();
}

class _UserCompleteProfileScreenState
    extends State<UserCompleteProfileScreen> {
  final controller = Get.put(UserCompleteProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: SafeArea(
        child: Form(
          key: controller.formKey,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.padding20w,
                ),
                child: const CommonAppBar(
                  title: 'Complete Your Profile',
                  showMoreIcon: false,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.padding20w,
                  ),
                  child: Column(
                    children: [
                      const IconHeader(
                        icon: AppImages.person,
                        title: 'Basic Information',
                      ),
                      _buildBasicInfoSection(),
                      SizedBox(height: AppDimensions.padding40h),
                      PrimaryButton(
                        text: "Submit Profile",
                        onPressed: controller.submitProfile,
                      ),
                      SizedBox(height: AppDimensions.padding40h),
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

  Widget _buildBasicInfoSection() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Photo Column
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profile Photo',
                  style: customTextStyle(
                    AppTextSizes.smallTextSize,
                    AppColors.black,
                    FontWeight.w400,
                  ),
                ),
                SizedBox(height: AppDimensions.padding5h),
                Obx(
                  () => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => controller.pickImage(ImageSource.gallery),
                        child: CustomPaint(
                          painter: DashedBorderPainter(
                            color: controller.profileImageError.value != null
                                ? AppColors.danger
                                : AppColors.primaryDark,
                            borderRadius: AppDimensions.radius4r,
                            dashWidth: 5.0,
                            dashSpace: 3.0,
                          ),
                          child: Container(
                            width: AppDimensions.containerWidth80w,
                            height: AppDimensions.containerHeight145h,
                            decoration: BoxDecoration(
                              color: AppColors.uploadBg,
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radius4r,
                              ),
                            ),
                            child: controller.profileImage.value == null
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.camera_alt,
                                        color: AppColors.primaryDark,
                                      ),
                                      Text(
                                        "Upload",
                                        style: customTextStyle(
                                          AppTextSizes.stableTextSize,
                                          AppColors.primaryDark,
                                          FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  )
                                : Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          AppDimensions.radius4r,
                                        ),
                                        child: Image.file(
                                          controller.profileImage.value!,
                                          fit: BoxFit.cover,
                                          width:
                                              AppDimensions.containerWidth80w,
                                          height:
                                              AppDimensions.containerHeight145h,
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: GestureDetector(
                                          onTap: controller.removeProfileImage,
                                          child: Container(
                                            padding: EdgeInsets.all(
                                              AppDimensions.padding4w,
                                            ),
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.close,
                                              size: AppDimensions.padding12w,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                      if (controller.profileImageError.value != null)
                        _buildInlineError(controller.profileImageError.value!),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(width: AppDimensions.padding20w),
            // Name and Mobile Column
            Expanded(
              child: Column(
                children: [
                  AddressFormField(
                    label: "Full Name",
                    hintText: "Enter your full name",
                    controller: controller.fullNameController,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? "Required" : null,
                  ),
                  SizedBox(height: AppDimensions.padding15h),
                  Obx(
                    () => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AddressFormField(
                          label: "Mobile Number",
                          hintText: "Enter your Number",
                          controller: controller.mobileController,
                          keyboardType: TextInputType.phone,
                          errorText: controller.mobileError.value,
                          validator: (v) => (v == null || v.length != 10)
                              ? "Enter 10 digits"
                              : null,
                          prefix: Container(
                            padding: EdgeInsets.all(AppDimensions.padding4w),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radius3r,
                              ),
                            ),
                            child: Text(
                              "+91",
                              style: customTextStyle(
                                AppTextSizes.stableTextSize,
                                AppColors.black,
                                FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: controller.sendOtp,
                            child: Container(
                              margin: EdgeInsets.only(
                                top: AppDimensions.padding5h,
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: AppDimensions.padding12w,
                                vertical: AppDimensions.padding5h,
                              ),
                              decoration: BoxDecoration(
                                gradient: AppColors.gradient,
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radius10r,
                                ),
                              ),
                              child: Text(
                                "Send OTP",
                                style: customTextStyle(
                                  AppTextSizes.stableTextSize,
                                  AppColors.white,
                                  FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: AppDimensions.padding15h),
        AddressFormField(
          label: "Email (Optional)",
          hintText: "Enter your Email (Optional)",
          controller: controller.emailController,
          validator: controller.validateEmail,
        ),
        SizedBox(height: AppDimensions.padding15h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Obx(
                () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomDropdown<String>(
                      label: "Gender",
                      hint: "Select Gender",
                      value: controller.gender.value,
                      items: ["Male", "Female", "Other"]
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: (val) => controller.gender.value = val,
                    ),
                    if (controller.genderError.value != null)
                      _buildInlineError(controller.genderError.value!),
                  ],
                ),
              ),
            ),
            SizedBox(width: AppDimensions.padding15w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Date of Birth",
                    style: customTextStyle(
                      AppTextSizes.smallTextSize,
                      AppColors.black,
                      FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: AppDimensions.padding5h),
                  Obx(
                    () => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => controller.selectDate(context),
                          child: Container(
                            height: AppDimensions.containerHeight48h,
                            padding: EdgeInsets.symmetric(
                              horizontal: AppDimensions.padding12w,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radius10r,
                              ),
                              border: Border.all(
                                color: controller.dobError.value != null
                                    ? AppColors.danger
                                    : AppColors.grey,
                              ),
                            ),
                            child: Row(
                              children: [
                                Image.asset(
                                  AppImages.calendar,
                                  height: AppDimensions.containerHeight16h,
                                  width: AppDimensions.containerWidth16w,
                                ),
                                SizedBox(width: AppDimensions.padding8w),
                                Text(
                                  controller.dob.value ?? "DD/MM/YYYY",
                                  style: customTextStyle(
                                    AppTextSizes.smallTextSize,
                                    controller.dob.value == null
                                        ? AppColors.grey
                                        : AppColors.black,
                                    FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (controller.dobError.value != null)
                          _buildInlineError(controller.dobError.value!),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInlineError(String error) {
    return Padding(
      padding: EdgeInsets.only(
        top: AppDimensions.padding4h,
        left: AppDimensions.padding4w,
      ),
      child: Text(
        error,
        style: customTextStyle(
          AppTextSizes.stableTextSize,
          AppColors.danger,
          FontWeight.w400,
        ),
      ),
    );
  }
}
