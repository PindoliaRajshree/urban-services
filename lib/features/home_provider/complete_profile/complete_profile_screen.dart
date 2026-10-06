// File: lib/features/home_provider/complete_profile/complete_profile_screen.dart
// Purpose: 3-step wizard (Basic Information -> Service Details -> Bank Details)
// for providers to complete their professional profile. Each step lives on
// its own page, navigated with Previous/Next/Submit buttons.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:urban_services/core/utils/input_formatters.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_images.dart';
import 'package:urban_services/core/constants/app_text_sizes.dart';
import 'package:urban_services/features/home_provider/complete_profile/complete_profile_provider.dart';
import 'package:urban_services/features/profile_common/basic_info.dart';
import 'package:urban_services/features/home_provider/complete_profile/models/service_type.dart';
import 'package:urban_services/features/home_provider/complete_profile/models/sub_service_type.dart';
import 'package:urban_services/features/home_provider/complete_profile/service_type_provider.dart';
import 'package:urban_services/widgets/address_form_field.dart';
import 'package:urban_services/widgets/common_app_bar.dart';
import 'package:urban_services/widgets/confirm_dialog.dart';
import 'package:urban_services/widgets/custom_dropdown.dart';
import 'package:urban_services/widgets/custom_snackbar.dart';
import 'package:urban_services/widgets/custom_text_style.dart';
import 'package:urban_services/widgets/dashed_border_painter.dart';
import 'package:urban_services/widgets/document_upload_card.dart';
import 'package:urban_services/widgets/icon_header.dart';
import 'package:urban_services/widgets/primary_button.dart';
import 'package:urban_services/widgets/secondary_button.dart';
import 'package:urban_services/widgets/step_indicator.dart';
import 'package:urban_services/widgets/add_mobile_number_dialog.dart';
import 'package:urban_services/widgets/verify_number_dialog.dart';

class CompleteProfileScreen extends ConsumerStatefulWidget {
  const CompleteProfileScreen({super.key, this.initialStep = 0});

  /// The page to open on — set when editing one section from the profile
  /// view. Back from this page leaves the screen.
  final int initialStep;

  @override
  ConsumerState<CompleteProfileScreen> createState() =>
      _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends ConsumerState<CompleteProfileScreen> {
  late final _pageController = PageController(initialPage: widget.initialStep);

  /// What was loaded, to tell whether an edit changed anything.
  ProviderProfileTextValues? _loadedValues;
  ProviderProfileState? _loadedState;

  // --- Per-step form keys (each page validates only its own fields) ---
  final _basicInfoFormKey = GlobalKey<FormState>();
  final _serviceDetailsFormKey = GlobalKey<FormState>();
  final _bankDetailsFormKey = GlobalKey<FormState>();

  // --- Basic Information (Step 0) ---
  final _fullNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _aadhaarNumberController = TextEditingController();
  final _panNumberController = TextEditingController();

  // --- Service Details (Step 1) ---
  final _bioController = TextEditingController();
  final _startingPriceController = TextEditingController();
  final _teamSizeController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();

  // --- Bank Details (Step 2) ---
  final _accountHolderController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _confirmAccountNumberController = TextEditingController();

  static final List<TextInputFormatter> _accountNumberFormatters = [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(18),
  ];
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
    // Fetch the saved profile (or registration details) to prefill.
    Future.microtask(_loadProfile);
  }

  /// Loads the saved profile and writes its text values into the fields.
  Future<void> _loadProfile() async {
    final values = await _notifier.loadInitial();
    if (values == null || !mounted) return;
    _fullNameController.text = values.fullName;
    _mobileController.text = values.mobile;
    _emailController.text = values.email;
    _bioController.text = values.bio;
    _startingPriceController.text = values.startingPrice;
    _teamSizeController.text = values.teamSize;
    _addressController.text = values.address;
    _cityController.text = values.city;
    _stateController.text = values.state;
    _pincodeController.text = values.pincode;
    _accountHolderController.text = values.accountHolder;
    _bankNameController.text = values.bankName;
    _accountNumberController.text = values.accountNumber;
    _confirmAccountNumberController.text = values.accountNumber;
    _ifscController.text = values.ifsc;
    _upiIdController.text = values.upiId;
    if (widget.initialStep > 0) _notifier.goToStep(widget.initialStep);
    _loadedValues = values;
    _loadedState = ref.read(providerProfileProvider);
  }

  /// Fills the address fields from the device location (empty results
  /// leave the field as it is).
  Future<void> _useCurrentLocation() async {
    final fill = await _notifier.useCurrentLocation();
    if (fill == null || !mounted) return;
    void set(TextEditingController c, String? v) {
      if (v != null) c.text = v;
    }

    set(_addressController, fill.address);
    set(_cityController, fill.city);
    set(_stateController, fill.state);
    set(_pincodeController, fill.pincode);
  }

  List<TextEditingController> get _textControllers => [
    _fullNameController,
    _mobileController,
    _emailController,
    _aadhaarNumberController,
    _panNumberController,
    _bioController,
    _startingPriceController,
    _teamSizeController,
    _addressController,
    _cityController,
    _stateController,
    _pincodeController,
    _accountHolderController,
    _bankNameController,
    _accountNumberController,
    _confirmAccountNumberController,
    _ifscController,
    _upiIdController,
  ];

  @override
  void dispose() {
    _pageController.dispose();
    for (final c in _textControllers) {
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

  /// The "Previous" button: goes back one page.
  void _previousStep() {
    final profile = ref.read(providerProfileProvider);
    if (profile.isSubmitting || profile.currentStep == 0) return;
    _animateToStep(profile.currentStep - 1);
  }

  /// App-bar back and Android back (see PopScope): goes back one page, but
  /// on the page the screen opened on it leaves, after confirming if
  /// anything has been entered or changed.
  Future<void> _onBack() async {
    final profile = ref.read(providerProfileProvider);
    if (profile.isSubmitting) return;
    if (profile.currentStep > widget.initialStep) {
      _animateToStep(profile.currentStep - 1);
      return;
    }

    if (_hasChanges) {
      final discard = await ConfirmDialog.show(
        context,
        title: profile.isEditing
            ? 'Discard changes?'
            : 'Discard profile details?',
        message: profile.isEditing
            ? "Unsaved changes will be lost."
            : "What you've entered will be lost.",
        confirmLabel: 'Discard',
        isDestructive: true,
      );
      if (!discard || !mounted) return;
    }
    context.pop();
  }

  /// Whether leaving now might lose anything the user entered. Fields
  /// prefilled from registration (name/email/mobile) alone don't count;
  /// when editing, only differences from the saved profile do.
  bool get _hasChanges {
    final profile = ref.read(providerProfileProvider);
    if (profile.isLoading || profile.loadError != null) return false;
    if (profile.isEditing) return _hasEdits(profile);
    return profile.profileImage != null ||
        profile.adhaarFront != null ||
        profile.adhaarBack != null ||
        profile.panCard != null ||
        profile.gender != null ||
        profile.dob != null ||
        profile.serviceCategory != null ||
        _textControllers
            .skip(3) // name, mobile, email
            .any((c) => c.text.trim().isNotEmpty);
  }

  /// Whether [now] differs from the saved profile loaded into the form.
  bool _hasEdits(ProviderProfileState now) {
    final values = _loadedValues;
    final saved = _loadedState;
    if (values == null || saved == null) return true;

    final textChanged = {
      _mobileController: values.mobile,
      _emailController: values.email,
      _bioController: values.bio,
      _startingPriceController: values.startingPrice,
      _teamSizeController: values.teamSize,
      _addressController: values.address,
      _cityController: values.city,
      _stateController: values.state,
      _pincodeController: values.pincode,
      _accountHolderController: values.accountHolder,
      _bankNameController: values.bankName,
      _accountNumberController: values.accountNumber,
      _ifscController: values.ifsc,
      _upiIdController: values.upiId,
    }.entries.any((e) => e.key.text.trim() != e.value.trim());

    return textChanged ||
        // A newly picked image, or a saved one removed.
        now.profileImage != null ||
        now.adhaarFront != null ||
        now.adhaarBack != null ||
        now.panCard != null ||
        now.profileImageUrl != saved.profileImageUrl ||
        now.adhaarFrontUrl != saved.adhaarFrontUrl ||
        now.adhaarBackUrl != saved.adhaarBackUrl ||
        now.panCardUrl != saved.panCardUrl ||
        now.gender != saved.gender ||
        now.dob != saved.dob ||
        now.serviceCategory != saved.serviceCategory ||
        now.subServices != saved.subServices ||
        now.experience != saved.experience ||
        now.pricingType != saved.pricingType ||
        now.selectedRadius != saved.selectedRadius ||
        now.workType != saved.workType ||
        now.latitude != saved.latitude ||
        now.longitude != saved.longitude;
  }

  bool _validateStep(int step) {
    switch (step) {
      case 0:
        final formValid = _basicInfoFormKey.currentState?.validate() ?? false;
        final customValid = _notifier.validateBasicInfoFields(
          _mobileController.text,
        );
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
        bio: _bioController.text,
        startingPrice: _startingPriceController.text,
        teamSize: _teamSizeController.text,
        address: _addressController.text,
        city: _cityController.text,
        state: _stateController.text,
        pincode: _pincodeController.text,
        accountHolder: _accountHolderController.text,
        bankName: _bankNameController.text,
        accountNumber: _accountNumberController.text,
        ifsc: _ifscController.text,
        upiId: _upiIdController.text,
      ),
    );
    if (jumpTo != null && mounted) _pageController.jumpToPage(jumpTo);
  }

  /// Sends an OTP to the entered number and opens the verification dialog.
  /// The number only counts as verified once the dialog's code matches.
  Future<void> _sendOtp() async {
    FocusScope.of(context).unfocus();
    final mobile = _mobileController.text.trim();
    if (!await _notifier.sendOtp(mobile) || !mounted) return;
    final verified = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => VerifyNumberDialog(
        phoneNumber: mobile,
        onVerify: (code) => _notifier.verifyOtp(mobile, code),
        onResend: () => _notifier.sendOtp(mobile),
      ),
    );
    if (verified == true) {
      CustomSnackBar.showSuccess(message: "Mobile number verified");
    }
  }

  /// For an account with no mobile number: asks for one and adds it
  /// (add-mobile-number, which also sends it an OTP). It's filled in here
  /// and offers "Verify" (see [_verifyAddedMobile]).
  Future<void> _addMobile() async {
    FocusScope.of(context).unfocus();
    final mobile = await showDialog<String>(
      context: context,
      builder: (_) =>
          AddMobileNumberDialog(onSubmit: _notifier.requestAddMobileOtp),
    );
    if (mobile == null || !mounted) return;
    _mobileController.text = mobile;
    CustomSnackBar.showSuccess(
      message: "Mobile number added. Tap Verify to confirm it.",
    );
  }

  /// Verifies the number added by [_addMobile] with the OTP it was sent.
  Future<void> _verifyAddedMobile() async {
    final mobile = _state.pendingMobile;
    if (mobile == null) return;
    FocusScope.of(context).unfocus();
    final verified = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => VerifyNumberDialog(
        phoneNumber: mobile,
        onVerify: (code) => _notifier.confirmAddMobile(mobile, code),
        onResend: () async {
          final sent = await _notifier.requestAddMobileOtp(mobile);
          if (sent) CustomSnackBar.showSuccess(message: "OTP sent to $mobile");
          return sent;
        },
      ),
    );
    if (verified == true && mounted) {
      CustomSnackBar.showSuccess(message: "Mobile number verified");
    }
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
    // The Aadhaar/PAN fields are read-only mirrors of the numbers read from
    // the card images (or loaded with the saved profile).
    ref.listen(providerProfileProvider.select((s) => s.aadhaarNumber), (
      _,
      number,
    ) {
      _aadhaarNumberController.text = number ?? '';
    });
    ref.listen(providerProfileProvider.select((s) => s.panNumber), (_, number) {
      _panNumberController.text = number ?? '';
    });

    // Android back behaves like the app-bar back: one step at a time, with
    // a discard confirmation when leaving from the opening page.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onBack();
      },
      child: Scaffold(
        backgroundColor: AppColors.screenBackground,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.padding20w,
                ),
                child: CommonAppBar(
                  title: _state.isEditing
                      ? 'Edit Profile'
                      : 'Complete Your Profile',
                  showMoreIcon: false,
                  // The opening page leaves the screen; later steps go
                  // back one page.
                  onBackPress: _onBack,
                ),
              ),

              if (_state.isLoading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_state.loadError != null)
                Expanded(child: _buildLoadFailed(_state.loadError!))
              else ...[
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
            ],
          ),
        ),
      ),
    );
  }

  /// Shown instead of the form when the saved profile couldn't be fetched
  /// — an empty form here could overwrite the provider's saved details.
  Widget _buildLoadFailed(String message) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppDimensions.padding20w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Couldn't load your profile",
            textAlign: TextAlign.center,
            style: customTextStyle(
              AppTextSizes.largeTextSize,
              AppColors.darkBlueText,
              FontWeight.w700,
            ),
          ),
          SizedBox(height: AppDimensions.padding10h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: customTextStyle(
              AppTextSizes.smallTextSize,
              AppColors.darkGrey,
              FontWeight.w400,
            ),
          ),
          SizedBox(height: AppDimensions.padding20h),
          PrimaryButton(text: "Retry", onPressed: _loadProfile),
        ],
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
      useSafeArea: true,
      builder: (sheetContext) => Container(
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
        // The white sheet runs to the screen edge, but its options stay
        // above the system navigation / gesture bar.
        child: SafeArea(
          top: false,
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
                onTap: () => Navigator.of(sheetContext).pop(ImageSource.camera),
              ),
              ListTile(
                leading: Icon(
                  Icons.photo_library,
                  color: AppColors.primaryDark,
                ),
                title: Text(
                  "Choose from Gallery",
                  style: customTextStyle(
                    AppTextSizes.smallTextSize,
                    AppColors.black,
                    FontWeight.w400,
                  ),
                ),
                onTap: () =>
                    Navigator.of(sheetContext).pop(ImageSource.gallery),
              ),
            ],
          ),
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
                          child:
                              _state.profileImage == null &&
                                  _state.profileImageUrl == null
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
                                      child: _state.profileImage != null
                                          ? Image.file(
                                              _state.profileImage!,
                                              fit: BoxFit.cover,
                                              width: AppDimensions
                                                  .containerWidth80w,
                                              height: AppDimensions
                                                  .containerHeight145h,
                                            )
                                          : Image.network(
                                              _state.profileImageUrl!,
                                              fit: BoxFit.cover,
                                              width: AppDimensions
                                                  .containerWidth80w,
                                              height: AppDimensions
                                                  .containerHeight145h,
                                              errorBuilder: (_, _, _) =>
                                                  const Center(
                                                    child: Icon(
                                                      Icons.person,
                                                      color:
                                                          AppColors.primaryDark,
                                                    ),
                                                  ),
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
                  // The update API has no name field — it's the name
                  // given at registration.
                  AddressFormField(
                    label: "Full Name",
                    hintText: "Enter your full name",
                    controller: _fullNameController,
                    readOnly: true,
                  ),
                  SizedBox(height: AppDimensions.padding15h),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AddressFormField(
                        label: "Mobile Number",
                        hintText: _state.canAddMobile
                            ? "Add your mobile number"
                            : "Enter your Number",
                        controller: _mobileController,
                        // No number on the account yet: it's added through
                        // the "Add Mobile Number" dialog, not typed here,
                        // and stays fixed until verified.
                        readOnly:
                            _state.canAddMobile || _state.pendingMobile != null,
                        keyboardType: TextInputType.phone,
                        inputFormatters: mobileNumberFormatters,
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
                      // "Verified" while the field matches the verified
                      // number; editing it brings "Send OTP" back.
                      Align(
                        alignment: Alignment.centerRight,
                        child: ValueListenableBuilder<TextEditingValue>(
                          valueListenable: _mobileController,
                          builder: (_, value, _) => _state.canAddMobile
                              ? _buildAddMobileButton()
                              : _state.pendingMobile != null
                              ? _buildMobileActionButton(
                                  "Verify",
                                  _verifyAddedMobile,
                                )
                              : _state.isMobileVerified(value.text)
                              ? _buildVerifiedBadge()
                              : _buildSendOtpButton(),
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
          label: "Email",
          hintText: "Enter your Email",
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
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
                    items: ProviderProfileNotifier.genderOptions.keys
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

  Widget _buildSendOtpButton() => _buildMobileActionButton(
    _state.isSendingOtp ? "Sending..." : "Send OTP",
    _sendOtp,
  );

  Widget _buildAddMobileButton() =>
      _buildMobileActionButton("Add Mobile Number", _addMobile);

  Widget _buildMobileActionButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: _state.isSendingOtp ? null : onTap,
      child: Container(
        margin: EdgeInsets.only(top: AppDimensions.padding5h),
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.padding12w,
          vertical: AppDimensions.padding5h,
        ),
        decoration: BoxDecoration(
          gradient: AppColors.gradient,
          borderRadius: BorderRadius.circular(AppDimensions.radius10r),
        ),
        child: Text(
          label,
          style: customTextStyle(
            AppTextSizes.stableTextSize,
            AppColors.white,
            FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildVerifiedBadge() {
    return Padding(
      padding: EdgeInsets.only(top: AppDimensions.padding5h),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified,
            color: AppColors.success,
            size: AppDimensions.containerHeight16h,
          ),
          SizedBox(width: AppDimensions.padding4w),
          Text(
            "Verified",
            style: customTextStyle(
              AppTextSizes.stableTextSize,
              AppColors.success,
              FontWeight.w500,
            ),
          ),
        ],
      ),
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
              existingUrl: _state.adhaarFrontUrl,
              isProcessing: _state.isReadingAadhaar,
              onUpload: () => _pickPhoto('aadhaarFront'),
              onRemove: () => _notifier.removeDocument('aadhaarFront'),
            ),
            if (_state.adhaarFrontError != null)
              _buildInlineError(_state.adhaarFrontError!),
            SizedBox(height: AppDimensions.padding15h),
            // Read from the front image — never typed.
            AddressFormField(
              label: "Aadhaar Number",
              hintText: "Read from the uploaded front",
              controller: _aadhaarNumberController,
              readOnly: true,
            ),
            SizedBox(height: AppDimensions.padding20h),
            DocumentUploadCard(
              title: "Aadhaar",
              subTitle: "Upload Back",
              selectedFile: _state.adhaarBack,
              existingUrl: _state.adhaarBackUrl,
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
              existingUrl: _state.panCardUrl,
              isProcessing: _state.isReadingPan,
              onUpload: () => _pickPhoto('pan'),
              onRemove: () => _notifier.removeDocument('pan'),
            ),
            if (_state.panCardError != null)
              _buildInlineError(_state.panCardError!),
            SizedBox(height: AppDimensions.padding15h),
            // Read from the card image — never typed.
            AddressFormField(
              label: "PAN Number",
              hintText: "Read from the uploaded PAN card",
              controller: _panNumberController,
              readOnly: true,
            ),
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
            if (_serviceTypes.hasError && !_serviceTypes.isLoading)
              _buildLoadError(
                "Couldn't load service categories.",
                () => ref.invalidate(serviceTypesProvider),
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
            if (_subServiceTypes.hasError && !_subServiceTypes.isLoading)
              _buildLoadError(
                "Couldn't load sub services.",
                () => ref.invalidate(
                  subServiceTypesProvider(_state.serviceCategory!),
                ),
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
              items: ProviderProfileNotifier.experienceOptions
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
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
          controller: _bioController,
          maxLines: 3,
          validator: _notifier.validateRequired,
        ),
      ],
    );
  }

  Widget _buildPricingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Pricing type",
          style: customTextStyle(
            AppTextSizes.smallTextSize,
            AppColors.black,
            FontWeight.w400,
          ),
        ),
        SizedBox(height: AppDimensions.padding10h),
        Wrap(
          spacing: AppDimensions.padding10w,
          runSpacing: AppDimensions.padding8h,
          children: ProviderProfileNotifier.pricingOptions.keys
              .map(
                (t) => _buildSelectionChip(
                  t,
                  _state.pricingType,
                  _notifier.setPricingType,
                ),
              )
              .toList(),
        ),
        SizedBox(height: AppDimensions.padding15h),
        AddressFormField(
          label: "Starting Price (₹ ${_state.pricingType.toLowerCase()})",
          hintText: "Enter amount",
          controller: _startingPriceController,
          keyboardType: TextInputType.number,
          inputFormatters: amountFormatters,
          validator: (v) => _notifier.validatePrice(v, required: true),
        ),
      ],
    );
  }

  Widget _buildServiceAreaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Latitude/longitude come from the device, not typed in. Also
        // fills the address fields when Google can resolve them.
        Row(
          children: [
            Expanded(
              child: Text(
                _state.hasLocation
                    ? "Location captured "
                          "(${_state.latitude!.toStringAsFixed(4)}, "
                          "${_state.longitude!.toStringAsFixed(4)})"
                    : "Set the location you serve from",
                style: customTextStyle(
                  AppTextSizes.smallTextSize,
                  _state.hasLocation ? AppColors.success : AppColors.darkGrey,
                  FontWeight.w400,
                ),
              ),
            ),
            GestureDetector(
              onTap: _state.isLocating ? null : _useCurrentLocation,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_state.isLocating)
                    SizedBox(
                      height: AppDimensions.containerHeight16h,
                      width: AppDimensions.containerWidth16w,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    Icon(
                      Icons.my_location,
                      color: AppColors.primaryDark,
                      size: AppDimensions.containerHeight16h,
                    ),
                  SizedBox(width: AppDimensions.padding4w),
                  Text(
                    _state.hasLocation ? "Update" : "Use current location",
                    style: customTextStyle(
                      AppTextSizes.smallTextSize,
                      AppColors.primaryDark,
                      FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (_state.locationError != null)
          _buildInlineError(_state.locationError!),
        SizedBox(height: AppDimensions.padding15h),
        AddressFormField(
          label: "Address",
          hintText: "House no., street, area",
          controller: _addressController,
          maxLines: 2,
          validator: _notifier.validateRequired,
        ),
        SizedBox(height: AppDimensions.padding15h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AddressFormField(
                label: "City",
                hintText: "Enter city",
                controller: _cityController,
                validator: _notifier.validateRequired,
              ),
            ),
            SizedBox(width: AppDimensions.padding15w),
            Expanded(
              child: AddressFormField(
                label: "State",
                hintText: "Enter state",
                controller: _stateController,
                validator: _notifier.validateRequired,
              ),
            ),
          ],
        ),
        SizedBox(height: AppDimensions.padding15h),
        AddressFormField(
          label: "Pincode",
          hintText: "6-digit pincode",
          controller: _pincodeController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
          validator: _notifier.validatePincode,
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
        // Wraps onto a second line instead of overflowing with large fonts.
        Wrap(
          spacing: AppDimensions.padding10w,
          runSpacing: AppDimensions.padding8h,
          children: ProviderProfileNotifier.radiusOptions.keys
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
          children: ProviderProfileNotifier.workTypeOptions.keys
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
        SizedBox(height: AppDimensions.padding15h),
        AddressFormField(
          label: "Team Size",
          hintText: "Number of people incl. you",
          controller: _teamSizeController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(4),
          ],
          validator: _notifier.validateTeamSize,
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
                validator: _notifier.validateRequired,
              ),
            ),
            SizedBox(width: AppDimensions.padding15w),
            Expanded(
              child: AddressFormField(
                label: "Bank name",
                hintText: "e.g. SBI",
                controller: _bankNameController,
                validator: _notifier.validateRequired,
              ),
            ),
          ],
        ),
        SizedBox(height: AppDimensions.padding15h),
        AddressFormField(
          label: "Account number",
          hintText: "Enter number",
          controller: _accountNumberController,
          keyboardType: TextInputType.number,
          inputFormatters: _accountNumberFormatters,
          validator: _notifier.validateAccountNumber,
        ),
        SizedBox(height: AppDimensions.padding15h),
        // Typed twice so a typo can't send payouts to the wrong account.
        AddressFormField(
          label: "Confirm account number",
          hintText: "Re-enter account number",
          controller: _confirmAccountNumberController,
          keyboardType: TextInputType.number,
          inputFormatters: _accountNumberFormatters,
          validator: (v) => _notifier.validateAccountNumberConfirmation(
            v,
            _accountNumberController.text,
          ),
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
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                  const UpperCaseTextFormatter(),
                  LengthLimitingTextInputFormatter(11),
                ],
                validator: _notifier.validateIfsc,
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
                label: "UPI ID",
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

  /// Shown under a dropdown whose options failed to load.
  Widget _buildLoadError(String message, VoidCallback onRetry) {
    return Padding(
      padding: EdgeInsets.only(
        top: AppDimensions.padding4h,
        left: AppDimensions.padding4w,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: customTextStyle(
                AppTextSizes.stableTextSize,
                AppColors.danger,
                FontWeight.w400,
              ),
            ),
          ),
          GestureDetector(
            onTap: onRetry,
            child: Text(
              "Retry",
              style: customTextStyle(
                AppTextSizes.stableTextSize,
                AppColors.primaryDark,
                FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
