// File: lib/features/home_provider/complete_profile/complete_profile_screen.dart
// Purpose: Multi-step form for providers to complete their detailed professional profile.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_images.dart';
import 'package:urban_services/core/constants/app_text_sizes.dart';
import 'package:urban_services/features/home_provider/complete_profile/complete_profile_controller.dart';
import 'package:urban_services/widgets/address_form_field.dart';
import 'package:urban_services/widgets/common_app_bar.dart';
import 'package:urban_services/widgets/custom_dropdown.dart';
import 'package:urban_services/widgets/custom_text_style.dart';
import 'package:urban_services/widgets/dashed_border_painter.dart';
import 'package:urban_services/widgets/document_upload_card.dart';
import 'package:urban_services/widgets/icon_header.dart';
import 'package:urban_services/widgets/primary_button.dart';
import 'package:urban_services/widgets/step_indicator.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final controller = Get.put(CompleteProfileController());

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
                  showMoreIcon: true,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.padding20w,
                  ),
                  child: Column(
                    children: [
                      // 2. Step Indicator
                      Obx(
                        () => StepIndicator(
                          currentStep: controller.currentStep.value,
                          stepLabels: const [
                            "Basic Info",
                            "Service",
                            "Pricing",
                            "Area",
                            "Availability",
                            "Documents",
                            "Bank Details",
                          ],
                        ),
                      ),

                      // 3. Basic Information Section
                      const IconHeader(
                        icon: AppImages.person,
                        title: 'Basic Information',
                      ),
                      _buildBasicInfoSection(),

                      // 5. Service Details Section
                      const IconHeader(
                        icon: AppImages.service,
                        title: 'Service Details',
                      ),
                      _buildServiceDetailsSection(),

                      // 6. Pricing Section
                      const IconHeader(
                        icon: AppImages.pricing,
                        title: 'Pricing',
                      ),
                      _buildPricingSection(),

                      // 8. Service Area Section
                      const IconHeader(
                        icon: AppImages.locationOutlined,
                        title: 'Service Area',
                      ),
                      _buildServiceAreaSection(),

                      // 10. Availability Section
                      const IconHeader(
                        icon: AppImages.clockOutlined,
                        title: 'Availability',
                      ),
                      _buildAvailabilitySection(),

                      // 13. Documents Verification Section
                      const IconHeader(
                        icon: AppImages.clockOutlined,
                        title: 'Documents Verification',
                      ),
                      _buildDocumentsSection(),

                      // 16. Bank Details Section
                      const IconHeader(
                        icon: AppImages.clockOutlined,
                        title: 'Bank Details',
                      ),
                      _buildBankSection(),

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
                            borderRadius: 4.0,
                            dashWidth: 5.0,
                            dashSpace: 3.0,
                          ),
                          child: Container(
                            width: 80,
                            height:
                                145, // Adjusted to match right column height
                            decoration: BoxDecoration(
                              color: AppColors.uploadBg,
                              borderRadius: BorderRadius.circular(4),
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
                                          10,
                                          AppColors.primaryDark,
                                          FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  )
                                : Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: Image.file(
                                          controller.profileImage.value!,
                                          fit: BoxFit.cover,
                                          width: 80,
                                          height: 145,
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: GestureDetector(
                                          onTap: controller.removeProfileImage,
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              size: 12,
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AddressFormField(
                        label: "Mobile Number",
                        hintText: "Enter your Number",
                        controller: controller.mobileController,
                        keyboardType: TextInputType.phone,
                        validator: (v) => (v == null || v.length != 10)
                            ? "Enter 10 digits"
                            : null,
                        prefix: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            "+91",
                            style: customTextStyle(
                              10,
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
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              "Send OTP",
                              style: customTextStyle(
                                10,
                                AppColors.white,
                                FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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
                            height: 48,
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
                                  height: 16,
                                  width: 16,
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

  Widget _buildServiceDetailsSection() {
    return Column(
      children: [
        Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomDropdown<String>(
                label: "Service Category",
                hint: "Service Category",
                value: controller.serviceCategory.value,
                items: ["Cleaning", "Electrician", "Plumber", "Laundry"]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => controller.serviceCategory.value = v,
              ),
              if (controller.categoryError.value != null)
                _buildInlineError(controller.categoryError.value!),
            ],
          ),
        ),
        SizedBox(height: AppDimensions.padding15h),
        Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomDropdown<String>(
                label: "Sub Services",
                hint: "Sub Services",
                value: controller.subServices.value,
                items: ["Full Home", "Kitchen", "Bathroom"]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => controller.subServices.value = v,
              ),
              if (controller.subServiceError.value != null)
                _buildInlineError(controller.subServiceError.value!),
            ],
          ),
        ),
        SizedBox(height: AppDimensions.padding15h),
        Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomDropdown<String>(
                label: "Experience (Years)",
                hint: "Service Experience (Years)",
                value: controller.experience.value,
                items: ["1", "2", "3", "4", "5+"]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => controller.experience.value = v,
              ),
              if (controller.experienceError.value != null)
                _buildInlineError(controller.experienceError.value!),
            ],
          ),
        ),
        SizedBox(height: AppDimensions.padding15h),
        AddressFormField(
          label: "Description/About Service",
          hintText: "Write about your service...",
          controller: controller.descriptionController,
          maxLines: 3,
          validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
        ),
      ],
    );
  }

  Widget _buildPricingSection() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AddressFormField(
                label: "Starting Price (₹)",
                hintText: "Enter amount",
                controller: controller.startingPriceController,
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
              ),
            ),
            SizedBox(width: 15),
            Expanded(
              child: AddressFormField(
                label: "Per Hour Rate (₹)",
                hintText: "Enter amount",
                controller: controller.perHourRateController,
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
              ),
            ),
          ],
        ),
        SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: AddressFormField(
                label: "Per Visit Rate (₹)",
                hintText: "Enter amount",
                controller: controller.perVisitRateController,
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(width: 15),
            Expanded(
              child: AddressFormField(
                label: "Custom Pricing (₹)",
                hintText: "Enter amount",
                controller: controller.customPricingController,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildServiceAreaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AddressFormField(
                label: "City",
                hintText: "Enter city",
                controller: controller.cityController,
                validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
              ),
            ),
            SizedBox(width: 15),
            Expanded(
              child: AddressFormField(
                label: "Area/Locality",
                hintText: "Enter area",
                controller: controller.areaController,
                validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
              ),
            ),
          ],
        ),
        SizedBox(height: 15),
        Text(
          "Service Radius",
          style: customTextStyle(12, AppColors.black, FontWeight.w400),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: ['5km', '10km', '15km', '20km']
              .map((r) => _buildSelectionChip(r, controller.selectedRadius))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildAvailabilitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Work type",
          style: customTextStyle(12, AppColors.black, FontWeight.w400),
        ),
        SizedBox(height: 10),
        Row(
          children: ['Full Time', 'Part Time']
              .map(
                (t) => Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: _buildSelectionChip(t, controller.workType),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildDocumentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Upload clear images of your documents",
          style: customTextStyle(12, AppColors.darkGrey, FontWeight.w400),
        ),
        SizedBox(height: 15),
        Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DocumentUploadCard(
                title: "Aadhaar",
                subTitle: "Upload Front/Back",
                selectedFile: controller.adhaarFront.value,
                onUpload: () => controller.pickDocument('aadhaarFront'),
                onRemove: () => controller.removeDocument('aadhaarFront'),
              ),
              if (controller.adhaarFrontError.value != null)
                _buildInlineError(controller.adhaarFrontError.value!),
            ],
          ),
        ),
        SizedBox(height: 20),
        Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DocumentUploadCard(
                title: "Aadhaar Back",
                subTitle: "Upload Card",
                selectedFile: controller.adhaarBack.value,
                onUpload: () => controller.pickDocument('aadhaarBack'),
                onRemove: () => controller.removeDocument('aadhaarBack'),
              ),
              if (controller.adhaarBackError.value != null)
                _buildInlineError(controller.adhaarBackError.value!),
            ],
          ),
        ),
        SizedBox(height: 20),
        Obx(
          () => DocumentUploadCard(
            title: "PAN Card (Optional)",
            subTitle: "Upload Card",
            selectedFile: controller.panCard.value,
            onUpload: () => controller.pickDocument('pan'),
            onRemove: () => controller.removeDocument('pan'),
          ),
        ),
      ],
    );
  }

  Widget _buildBankSection() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AddressFormField(
                label: "Account holder name",
                hintText: "Enter name",
                controller: controller.accountHolderController,
                validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
              ),
            ),
            SizedBox(width: 15),
            Expanded(
              child: AddressFormField(
                label: "Account number",
                hintText: "Enter number",
                controller: controller.accountNumberController,
                keyboardType: TextInputType.number,
                validator: controller.validateAccountNumber,
              ),
            ),
          ],
        ),
        SizedBox(height: 15),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Obx(
                () => AddressFormField(
                  label: "IFSC Code",
                  hintText: "Enter IFSC Code",
                  controller: controller.ifscController,
                  errorText: controller.ifscError.value,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? "Required" : null,
                  labelTrailing: GestureDetector(
                    onTap: controller.verifyIfsc,
                    child: Text(
                      "Verify",
                      style: customTextStyle(
                        12,
                        AppColors.primaryDark,
                        FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 15),
            Expanded(
              child: AddressFormField(
                label: "UPI ID (Optional)",
                hintText: "name@upi",
                controller: controller.upiIdController,
                validator: controller.validateUpi,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSelectionChip(String label, RxString groupValue) {
    return Obx(() {
      final isSelected = groupValue.value == label;
      return GestureDetector(
        onTap: () => groupValue.value = label,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color: isSelected ? AppColors.primaryDark : AppColors.grey,
            ),
          ),
          child: Text(
            label,
            style: customTextStyle(
              12,
              isSelected ? AppColors.primaryDark : AppColors.grey,
              FontWeight.w400,
            ),
          ),
        ),
      );
    });
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
