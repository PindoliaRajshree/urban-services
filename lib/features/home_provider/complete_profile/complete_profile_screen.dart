// File: lib/features/home_provider/complete_profile/complete_profile_screen.dart
// Purpose: 3-step wizard (Basic Information -> Service Details -> Bank Details)
// for providers to complete their professional profile. Each step lives on
// its own page, navigated with Previous/Next/Submit buttons.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_images.dart';
import 'package:urban_services/core/constants/api_status.dart';
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
import 'package:urban_services/widgets/secondary_button.dart';
import 'package:urban_services/widgets/step_indicator.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final controller = Get.put(CompleteProfileController());

  static const List<String> _stepLabels = [
    "Basic Info",
    "Service Details",
    "Bank Details",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.padding20w,
              ),
              child: CommonAppBar(
                title: 'Complete Your Profile',
                showMoreIcon: false,
                // Step 0 leaves the screen; later steps go back one page.
                onBackPress: controller.previousStep,
              ),
            ),

            // Step Indicator (3 steps)
            Obx(
              () => Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.padding20w,
                ),
                child: StepIndicator(
                  currentStep: controller.currentStep.value,
                  stepLabels: _stepLabels,
                ),
              ),
            ),

            // Each step is a separate, independently scrollable page.
            Expanded(
              child: PageView(
                controller: controller.pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildBasicInfoPage(),
                  _buildServiceDetailsPage(),
                  _buildBankDetailsPage(),
                ],
              ),
            ),

            // Footer navigation: Next only on step 1, Previous/Next in the
            // middle, Previous/Submit on the last step.
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppDimensions.padding20w,
                AppDimensions.padding15h,
                AppDimensions.padding20w,
                AppDimensions.padding15h,
              ),
              child: Obx(() => _buildFooterButtons()),
            ),
          ],
        ),
      ),
    );
  }

  /// Shows a "Take Photo" / "Choose from Gallery" bottom sheet and, if the
  /// user picks one, forwards the picked image to [field] on the controller
  /// (profile photo, Aadhaar front/back, or PAN — see
  /// `CompleteProfileController.pickPhotoFor`).
  Future<void> _pickPhoto(String field) async {
    final source = await Get.bottomSheet<ImageSource>(
      Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.padding20w,
          vertical: AppDimensions.padding20h,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.radius16r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Upload Photo",
              style: customTextStyle(
                AppTextSizes.largeTextSize,
                AppColors.darkBlueText,
                FontWeight.w700,
              ),
            ),
            SizedBox(height: AppDimensions.padding15h),
            ListTile(
              leading: Icon(Icons.camera_alt, color: AppColors.primaryDark),
              title: Text(
                "Take Photo",
                style: customTextStyle(
                  AppTextSizes.smallTextSize,
                  AppColors.black,
                  FontWeight.w400,
                ),
              ),
              onTap: () => Get.back(result: ImageSource.camera),
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: AppColors.primaryDark),
              title: Text(
                "Choose from Gallery",
                style: customTextStyle(
                  AppTextSizes.smallTextSize,
                  AppColors.black,
                  FontWeight.w400,
                ),
              ),
              onTap: () => Get.back(result: ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;
    await controller.pickPhotoFor(field, source);
  }

  Widget _buildFooterButtons() {
    if (controller.isFirstStep) {
      return PrimaryButton(text: "Next", onPressed: controller.nextStep);
    }

    return Row(
      children: [
        Expanded(
          child: SecondaryButton(
            text: "Previous",
            onPressed: controller.previousStep,
          ),
        ),
        SizedBox(width: AppDimensions.padding15w),
        Expanded(
          child: PrimaryButton(
            text: controller.isLastStep ? "Submit Profile" : "Next",
            isLoading: controller.isLastStep && controller.isSubmitting.value,
            onPressed: controller.isLastStep
                ? controller.submitProfile
                : controller.nextStep,
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // Step 0: Basic Information (photo, name, mobile, email, gender, dob,
  // documents verification)
  // ==========================================================================

  Widget _buildBasicInfoPage() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: AppDimensions.padding20w),
      child: Form(
        key: controller.basicInfoFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const IconHeader(
              icon: AppImages.person,
              title: 'Basic Information',
            ),
            _buildBasicInfoSection(),
            const IconHeader(
              icon: AppImages.file,
              title: 'Documents Verification',
            ),
            _buildDocumentsSection(),
            SizedBox(height: AppDimensions.padding20h),
          ],
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
                        onTap: () => _pickPhoto('profile'),
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
                            height: AppDimensions
                                .containerHeight145h, // Adjusted to match right column height
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

  Widget _buildDocumentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Upload clear images of your documents",
          style: customTextStyle(
            AppTextSizes.smallTextSize,
            AppColors.darkGrey,
            FontWeight.w400,
          ),
        ),
        SizedBox(height: AppDimensions.padding15h),
        Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DocumentUploadCard(
                title: "Aadhaar",
                subTitle: "Upload Front",
                selectedFile: controller.adhaarFront.value,
                onUpload: () => _pickPhoto('aadhaarFront'),
                onRemove: () => controller.removeDocument('aadhaarFront'),
              ),
              if (controller.adhaarFrontError.value != null)
                _buildInlineError(controller.adhaarFrontError.value!),
              SizedBox(height: AppDimensions.padding20h),
              DocumentUploadCard(
                title: "Aadhaar",
                subTitle: "Upload Back",
                selectedFile: controller.adhaarBack.value,
                onUpload: () => _pickPhoto('aadhaarBack'),
                onRemove: () => controller.removeDocument('aadhaarBack'),
              ),
              if (controller.adhaarBackError.value != null)
                _buildInlineError(controller.adhaarBackError.value!),
            ],
          ),
        ),
        SizedBox(height: AppDimensions.padding20h),
        Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DocumentUploadCard(
                title: "PAN Card (Optional)",
                subTitle: "Upload Card",
                selectedFile: controller.panCard.value,
                onUpload: () => _pickPhoto('pan'),
                onRemove: () => controller.removeDocument('pan'),
              ),
              if (controller.panCardError.value != null)
                _buildInlineError(controller.panCardError.value!),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // Step 1: Service Details (category, sub services, experience, description,
  // pricing, service area, availability)
  // ==========================================================================

  Widget _buildServiceDetailsPage() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: AppDimensions.padding20w),
      child: Form(
        key: controller.serviceDetailsFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const IconHeader(
              icon: AppImages.service,
              title: 'Service Details',
            ),
            _buildServiceDetailsSection(),
            const IconHeader(icon: AppImages.pricing, title: 'Pricing'),
            _buildPricingSection(),
            const IconHeader(
              icon: AppImages.locationOutlined,
              title: 'Service Area',
            ),
            _buildServiceAreaSection(),
            const IconHeader(
              icon: AppImages.clockOutlined,
              title: 'Availability',
            ),
            _buildAvailabilitySection(),
            SizedBox(height: AppDimensions.padding20h),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceDetailsSection() {
    return Column(
      children: [
        Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomDropdown<int>(
                label: "Service Category",
                hint:
                    controller.serviceTypeController.serviceTypesStatus.value ==
                        ApiStatus.loading
                    ? "Loading..."
                    : "Service Category",
                value: controller.serviceCategory.value,
                items: controller.serviceTypeController.serviceTypes
                    .map(
                      (s) => DropdownMenuItem(value: s.id, child: Text(s.name)),
                    )
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
              CustomDropdown<int>(
                label: "Sub Services",
                hint: controller.serviceCategory.value == null
                    ? "Select a service first"
                    : controller.serviceTypeController.subServiceTypesStatus
                              .value ==
                          ApiStatus.loading
                    ? "Loading..."
                    : "Sub Services",
                value: controller.subServices.value,
                items: controller.serviceTypeController.subServiceTypes
                    .map(
                      (s) => DropdownMenuItem(value: s.id, child: Text(s.name)),
                    )
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
            SizedBox(width: AppDimensions.padding15w),
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
        SizedBox(height: AppDimensions.padding15h),
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
            SizedBox(width: AppDimensions.padding15w),
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
            SizedBox(width: AppDimensions.padding15w),
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
        SizedBox(height: AppDimensions.padding15h),
        Text(
          "Service Radius",
          style: customTextStyle(
            AppTextSizes.smallTextSize,
            AppColors.black,
            FontWeight.w400,
          ),
        ),
        SizedBox(height: AppDimensions.padding10h),
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
          style: customTextStyle(
            AppTextSizes.smallTextSize,
            AppColors.black,
            FontWeight.w400,
          ),
        ),
        SizedBox(height: AppDimensions.padding10h),
        Row(
          children: ['Full Time', 'Part Time']
              .map(
                (t) => Padding(
                  padding: EdgeInsets.only(right: AppDimensions.padding15w),
                  child: _buildSelectionChip(t, controller.workType),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  // ==========================================================================
  // Step 2: Bank Details (account holder name, A/C no, IFSC code, UPI ID)
  // ==========================================================================

  Widget _buildBankDetailsPage() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: AppDimensions.padding20w),
      child: Form(
        key: controller.bankDetailsFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const IconHeader(
              icon: AppImages.creditDebitCard,
              title: 'Bank Details',
            ),
            _buildBankSection(),
            SizedBox(height: AppDimensions.padding20h),
          ],
        ),
      ),
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
            SizedBox(width: AppDimensions.padding15w),
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
        SizedBox(height: AppDimensions.padding15h),
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
                        AppTextSizes.smallTextSize,
                        AppColors.primaryDark,
                        FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: AppDimensions.padding15w),
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

  // ---------------- Shared helpers ----------------

  Widget _buildSelectionChip(String label, RxString groupValue) {
    return Obx(() {
      final isSelected = groupValue.value == label;
      return GestureDetector(
        onTap: () => groupValue.value = label,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.padding16w,
            vertical: AppDimensions.padding8h,
          ),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppDimensions.radius3r),
            border: Border.all(
              color: isSelected ? AppColors.primaryDark : AppColors.grey,
            ),
          ),
          child: Text(
            label,
            style: customTextStyle(
              AppTextSizes.smallTextSize,
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
