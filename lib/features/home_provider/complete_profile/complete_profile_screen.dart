// File: lib/features/home_provider/complete_profile/complete_profile_screen.dart
// Purpose: 3-step wizard (Basic Information -> Service Details -> Bank Details)
// for providers to complete their professional profile. Each step lives on
// its own page, navigated with Previous/Next/Submit buttons.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_images.dart';
import 'package:urban_services/core/constants/app_text_sizes.dart';
import 'package:urban_services/features/home_provider/complete_profile/complete_profile_provider.dart';
import 'package:urban_services/features/home/complete_profile/user_complete_profile_provider.dart';
import 'package:urban_services/features/home_provider/complete_profile/models/service_type.dart';
import 'package:urban_services/features/home_provider/complete_profile/models/sub_service_type.dart';
import 'package:urban_services/features/home_provider/complete_profile/service_type_provider.dart';
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
import 'package:urban_services/widgets/verify_number_dialog.dart';

class CompleteProfileScreen extends ConsumerStatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  ConsumerState<CompleteProfileScreen> createState() =>
      _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends ConsumerState<CompleteProfileScreen> {
  final _pageController = PageController();

  // --- Per-step form keys (each page validates only its own fields) ---
  final _basicInfoFormKey = GlobalKey<FormState>();
  final _serviceDetailsFormKey = GlobalKey<FormState>();
  final _bankDetailsFormKey = GlobalKey<FormState>();

  // --- Basic Information (Step 0) ---
  final _fullNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();

  // --- Service Details (Step 1) ---
  final _descriptionController = TextEditingController();
  final _startingPriceController = TextEditingController();
  final _perHourRateController = TextEditingController();
  final _perVisitRateController = TextEditingController();
  final _customPricingController = TextEditingController();
  final _cityController = TextEditingController();
  final _areaController = TextEditingController();

  // --- Bank Details (Step 2) ---
  final _accountHolderController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _ifscController = TextEditingController();
  final _upiIdController = TextEditingController();

  /// Watched from build and the _build* helpers (all run during build).
  ProviderProfileState get _state => ref.watch(providerProfileProvider);

  ProviderProfileNotifier get _notifier =>
      ref.read(providerProfileProvider.notifier);

  /// Preloaded on ProviderHomeScreen; fetched here if not loaded yet.
  AsyncValue<List<ServiceType>> get _serviceTypes =>
      ref.watch(serviceTypesProvider);

  AsyncValue<List<SubServiceType>> get _subServiceTypes {
    final categoryId = _state.serviceCategory;
    if (categoryId == null) return const AsyncData([]);
    return ref.watch(subServiceTypesProvider(categoryId));
  }

  @override
  void initState() {
    super.initState();
    // Clear mobile / IFSC errors when typing
    _mobileController.addListener(() {
      if (_mobileController.text.isNotEmpty) _notifier.clearMobileError();
    });
    _ifscController.addListener(() {
      if (_ifscController.text.isNotEmpty) _notifier.clearIfscError();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final c in [
      _fullNameController,
      _mobileController,
      _emailController,
      _descriptionController,
      _startingPriceController,
      _perHourRateController,
      _perVisitRateController,
      _customPricingController,
      _cityController,
      _areaController,
      _accountHolderController,
      _accountNumberController,
      _ifscController,
      _upiIdController,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // --- Step Navigation ---

  void _animateToStep(int step) {
    _notifier.goToStep(step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  /// Validates the current step and, if valid, advances to the next page.
  void _nextStep() {
    final step = ref.read(providerProfileProvider).currentStep;
    if (!_validateStep(step)) return;
    if (step < ProviderProfileNotifier.totalSteps - 1) _animateToStep(step + 1);
  }

  /// Goes back to the previous page, or leaves the screen if already on step 0.
  void _previousStep() {
    final step = ref.read(providerProfileProvider).currentStep;
    if (step > 0) {
      _animateToStep(step - 1);
    } else {
      context.pop();
    }
  }

  bool _validateStep(int step) {
    switch (step) {
      case 0:
        final formValid = _basicInfoFormKey.currentState?.validate() ?? false;
        final customValid = _notifier.validateBasicInfoFields();
        return formValid && customValid;
      case 1:
        final formValid =
            _serviceDetailsFormKey.currentState?.validate() ?? false;
        final customValid = _notifier.validateServiceDetailsFields();
        return formValid && customValid;
      default:
        return true;
    }
  }

  /// Validates the final (Bank Details) step and submits the whole profile.
  Future<void> _submitProfile() async {
    final isFormValid = _bankDetailsFormKey.currentState?.validate() ?? false;
    if (!isFormValid) return;

    final jumpTo = await _notifier.submitProfile(
      ProviderProfileTextValues(
        fullName: _fullNameController.text,
        mobile: _mobileController.text,
        email: _emailController.text,
        description: _descriptionController.text,
        startingPrice: _startingPriceController.text,
        perHourRate: _perHourRateController.text,
        perVisitRate: _perVisitRateController.text,
        customPricing: _customPricingController.text,
        city: _cityController.text,
        area: _areaController.text,
        accountHolder: _accountHolderController.text,
        accountNumber: _accountNumberController.text,
        ifsc: _ifscController.text,
        upiId: _upiIdController.text,
      ),
    );
    if (jumpTo != null && mounted) _pageController.jumpToPage(jumpTo);
  }

  /// Handles OTP verification dialog logic
  void _sendOtp() {
    if (!_notifier.sendOtp(_mobileController.text)) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => VerifyNumberDialog(phoneNumber: _mobileController.text),
    );
  }

  Future<void> _selectDate() async {
    final picked = await pickDateOfBirth(context);
    if (picked != null) _notifier.setDob(picked);
  }

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
                onBackPress: _previousStep,
              ),
            ),

            // Step Indicator (3 steps)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.padding20w,
              ),
              child: StepIndicator(
                currentStep: _state.currentStep,
                stepLabels: _stepLabels,
              ),
            ),

            // Each step is a separate, independently scrollable page.
            Expanded(
              child: PageView(
                controller: _pageController,
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
              child: _buildFooterButtons(),
            ),
          ],
        ),
      ),
    );
  }

  /// Shows a "Take Photo" / "Choose from Gallery" bottom sheet and, if the
  /// user picks one, forwards the picked image to [field] on the notifier
  /// (profile photo, Aadhaar front/back, or PAN — see
  /// `ProviderProfileNotifier.pickPhotoFor`).
  Future<void> _pickPhoto(String field) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
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
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
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
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;
    await _notifier.pickPhotoFor(field, source);
  }

  Widget _buildFooterButtons() {
    if (_state.isFirstStep) {
      return PrimaryButton(text: "Next", onPressed: _nextStep);
    }

    return Row(
      children: [
        Expanded(
          child: SecondaryButton(text: "Previous", onPressed: _previousStep),
        ),
        SizedBox(width: AppDimensions.padding15w),
        Expanded(
          child: PrimaryButton(
            text: _state.isLastStep ? "Submit Profile" : "Next",
            isLoading: _state.isLastStep && _state.isSubmitting,
            onPressed: _state.isLastStep ? _submitProfile : _nextStep,
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
        key: _basicInfoFormKey,
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => _pickPhoto('profile'),
                      child: CustomPaint(
                        painter: DashedBorderPainter(
                          color: _state.profileImageError != null
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
                          child: _state.profileImage == null
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
                                        _state.profileImage!,
                                        fit: BoxFit.cover,
                                        width: AppDimensions.containerWidth80w,
                                        height:
                                            AppDimensions.containerHeight145h,
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: GestureDetector(
                                        onTap: _notifier.removeProfileImage,
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
                    if (_state.profileImageError != null)
                      _buildInlineError(_state.profileImageError!),
                  ],
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
                    controller: _fullNameController,
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
                        controller: _mobileController,
                        keyboardType: TextInputType.phone,
                        errorText: _state.mobileError,
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
                          onTap: _sendOtp,
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
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: AppDimensions.padding15h),
        AddressFormField(
          label: "Email (Optional)",
          hintText: "Enter your Email (Optional)",
          controller: _emailController,
          validator: _notifier.validateEmail,
        ),
        SizedBox(height: AppDimensions.padding15h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomDropdown<String>(
                    label: "Gender",
                    hint: "Select Gender",
                    value: _state.gender,
                    items: ["Male", "Female", "Other"]
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: _notifier.setGender,
                  ),
                  if (_state.genderError != null)
                    _buildInlineError(_state.genderError!),
                ],
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: _selectDate,
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
                              color: _state.dobError != null
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
                                _state.dob ?? "DD/MM/YYYY",
                                style: customTextStyle(
                                  AppTextSizes.smallTextSize,
                                  _state.dob == null
                                      ? AppColors.grey
                                      : AppColors.black,
                                  FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_state.dobError != null)
                        _buildInlineError(_state.dobError!),
                    ],
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DocumentUploadCard(
              title: "Aadhaar",
              subTitle: "Upload Front",
              selectedFile: _state.adhaarFront,
              onUpload: () => _pickPhoto('aadhaarFront'),
              onRemove: () => _notifier.removeDocument('aadhaarFront'),
            ),
            if (_state.adhaarFrontError != null)
              _buildInlineError(_state.adhaarFrontError!),
            SizedBox(height: AppDimensions.padding20h),
            DocumentUploadCard(
              title: "Aadhaar",
              subTitle: "Upload Back",
              selectedFile: _state.adhaarBack,
              onUpload: () => _pickPhoto('aadhaarBack'),
              onRemove: () => _notifier.removeDocument('aadhaarBack'),
            ),
            if (_state.adhaarBackError != null)
              _buildInlineError(_state.adhaarBackError!),
          ],
        ),
        SizedBox(height: AppDimensions.padding20h),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DocumentUploadCard(
              title: "PAN Card (Optional)",
              subTitle: "Upload Card",
              selectedFile: _state.panCard,
              onUpload: () => _pickPhoto('pan'),
              onRemove: () => _notifier.removeDocument('pan'),
            ),
            if (_state.panCardError != null)
              _buildInlineError(_state.panCardError!),
          ],
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
        key: _serviceDetailsFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const IconHeader(icon: AppImages.service, title: 'Service Details'),
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomDropdown<int>(
              label: "Service Category",
              hint: _serviceTypes.isLoading ? "Loading..." : "Service Category",
              value: _state.serviceCategory,
              items: (_serviceTypes.value ?? const <ServiceType>[])
                  .map(
                    (s) => DropdownMenuItem(value: s.id, child: Text(s.name)),
                  )
                  .toList(),
              onChanged: _notifier.setServiceCategory,
            ),
            if (_state.categoryError != null)
              _buildInlineError(_state.categoryError!),
          ],
        ),
        SizedBox(height: AppDimensions.padding15h),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomDropdown<int>(
              label: "Sub Services",
              hint: _state.serviceCategory == null
                  ? "Select a service first"
                  : _subServiceTypes.isLoading
                  ? "Loading..."
                  : "Sub Services",
              value: _state.subServices,
              items: (_subServiceTypes.value ?? const <SubServiceType>[])
                  .map(
                    (s) => DropdownMenuItem(value: s.id, child: Text(s.name)),
                  )
                  .toList(),
              onChanged: _notifier.setSubService,
            ),
            if (_state.subServiceError != null)
              _buildInlineError(_state.subServiceError!),
          ],
        ),
        SizedBox(height: AppDimensions.padding15h),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomDropdown<String>(
              label: "Experience (Years)",
              hint: "Service Experience (Years)",
              value: _state.experience,
              items: [
                "1",
                "2",
                "3",
                "4",
                "5+",
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: _notifier.setExperience,
            ),
            if (_state.experienceError != null)
              _buildInlineError(_state.experienceError!),
          ],
        ),
        SizedBox(height: AppDimensions.padding15h),
        AddressFormField(
          label: "Description/About Service",
          hintText: "Write about your service...",
          controller: _descriptionController,
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
                controller: _startingPriceController,
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
              ),
            ),
            SizedBox(width: AppDimensions.padding15w),
            Expanded(
              child: AddressFormField(
                label: "Per Hour Rate (₹)",
                hintText: "Enter amount",
                controller: _perHourRateController,
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
                controller: _perVisitRateController,
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(width: AppDimensions.padding15w),
            Expanded(
              child: AddressFormField(
                label: "Custom Pricing (₹)",
                hintText: "Enter amount",
                controller: _customPricingController,
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
                controller: _cityController,
                validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
              ),
            ),
            SizedBox(width: AppDimensions.padding15w),
            Expanded(
              child: AddressFormField(
                label: "Area/Locality",
                hintText: "Enter area",
                controller: _areaController,
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
              .map(
                (r) => _buildSelectionChip(
                  r,
                  _state.selectedRadius,
                  _notifier.setRadius,
                ),
              )
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
                  child: _buildSelectionChip(
                    t,
                    _state.workType,
                    _notifier.setWorkType,
                  ),
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
        key: _bankDetailsFormKey,
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
                controller: _accountHolderController,
                validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
              ),
            ),
            SizedBox(width: AppDimensions.padding15w),
            Expanded(
              child: AddressFormField(
                label: "Account number",
                hintText: "Enter number",
                controller: _accountNumberController,
                keyboardType: TextInputType.number,
                validator: _notifier.validateAccountNumber,
              ),
            ),
          ],
        ),
        SizedBox(height: AppDimensions.padding15h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AddressFormField(
                label: "IFSC Code",
                hintText: "Enter IFSC Code",
                controller: _ifscController,
                errorText: _state.ifscError,
                validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
                labelTrailing: GestureDetector(
                  onTap: () => _notifier.verifyIfsc(_ifscController.text),
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
            SizedBox(width: AppDimensions.padding15w),
            Expanded(
              child: AddressFormField(
                label: "UPI ID (Optional)",
                hintText: "name@upi",
                controller: _upiIdController,
                validator: _notifier.validateUpi,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ---------------- Shared helpers ----------------

  Widget _buildSelectionChip(
    String label,
    String groupValue,
    ValueChanged<String> onSelect,
  ) {
    return Builder(
      builder: (context) {
        final isSelected = groupValue == label;
        return GestureDetector(
          onTap: () => onSelect(label),
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
      },
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
