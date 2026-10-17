// File: lib/features/home/complete_profile/user_complete_profile_screen.dart
// Purpose: Single-section form for a regular user to complete or edit their
// basic profile details (photo, name, mobile, email, gender, DOB) and
// address. Prefilled from the saved profile (user/get-user-profile).

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
import 'package:urban_services/features/home/complete_profile/user_complete_profile_provider.dart';
import 'package:urban_services/features/profile_common/basic_info.dart';
import 'package:urban_services/widgets/add_mobile_number_dialog.dart';
import 'package:urban_services/widgets/address_form_field.dart';
import 'package:urban_services/widgets/common_app_bar.dart';
import 'package:urban_services/widgets/confirm_dialog.dart';
import 'package:urban_services/widgets/custom_dropdown.dart';
import 'package:urban_services/widgets/custom_snackbar.dart';
import 'package:urban_services/widgets/custom_text_style.dart';
import 'package:urban_services/widgets/dashed_border_painter.dart';
import 'package:urban_services/widgets/icon_header.dart';
import 'package:urban_services/widgets/primary_button.dart';
import 'package:urban_services/widgets/searchable_picker_field.dart';
import 'package:urban_services/widgets/verify_number_dialog.dart';

class UserCompleteProfileScreen extends ConsumerStatefulWidget {
  const UserCompleteProfileScreen({super.key});

  @override
  ConsumerState<UserCompleteProfileScreen> createState() =>
      _UserCompleteProfileScreenState();
}

class _UserCompleteProfileScreenState
    extends ConsumerState<UserCompleteProfileScreen> {
  final _fullNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _fullAddressController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  /// What was loaded, to tell whether anything changed.
  UserProfileTextValues? _loadedValues;
  UserCompleteProfileState? _loadedState;

  UserCompleteProfileNotifier get _notifier =>
      ref.read(userCompleteProfileProvider.notifier);

  @override
  void initState() {
    super.initState();
    // Clear mobile error when typing
    _mobileController.addListener(() {
      if (_mobileController.text.isNotEmpty) _notifier.clearMobileError();
    });
    // Fetch the saved profile to prefill.
    Future.microtask(_loadProfile);
  }

  /// Loads the saved profile and writes its text values into the fields.
  Future<void> _loadProfile() async {
    final values = await _notifier.loadInitial();
    if (values == null || !mounted) return;
    _fullNameController.text = values.fullName;
    _mobileController.text = values.mobile;
    _emailController.text = values.email;
    _pincodeController.text = values.pincode;
    _fullAddressController.text = values.fullAddress;
    _loadedValues = values;
    _loadedState = ref.read(userCompleteProfileProvider);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _pincodeController.dispose();
    _fullAddressController.dispose();
    super.dispose();
  }

  UserProfileTextValues get _textValues => UserProfileTextValues(
    fullName: _fullNameController.text,
    mobile: _mobileController.text,
    email: _emailController.text,
    pincode: _pincodeController.text,
    fullAddress: _fullAddressController.text,
  );

  /// App-bar back and Android back (see PopScope): leaves, after confirming
  /// if anything differs from what was loaded.
  Future<void> _onBack() async {
    final profile = ref.read(userCompleteProfileProvider);
    if (profile.isSubmitting) return;
    if (_hasChanges(profile)) {
      final discard = await ConfirmDialog.show(
        context,
        title: 'Discard changes?',
        message: "Unsaved changes will be lost.",
        confirmLabel: 'Discard',
        isDestructive: true,
      );
      if (!discard || !mounted) return;
    }
    context.pop();
  }

  /// Whether [now] differs from the saved profile loaded into the form.
  bool _hasChanges(UserCompleteProfileState now) {
    if (now.isLoading || now.loadError != null) return false;
    final values = _loadedValues;
    final saved = _loadedState;
    if (values == null || saved == null) return false;

    final current = _textValues;
    final textChanged =
        current.fullName.trim() != values.fullName.trim() ||
        current.mobile.trim() != values.mobile.trim() ||
        current.email.trim() != values.email.trim() ||
        current.pincode.trim() != values.pincode.trim() ||
        current.fullAddress.trim() != values.fullAddress.trim();

    return textChanged ||
        // A newly picked photo, or the saved one removed.
        now.profileImage != null ||
        now.profileImageUrl != saved.profileImageUrl ||
        now.gender != saved.gender ||
        now.dob != saved.dob ||
        now.selectedCountry?.isoCode != saved.selectedCountry?.isoCode ||
        now.selectedState?.isoCode != saved.selectedState?.isoCode ||
        now.selectedCity != saved.selectedCity;
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    _notifier.submitProfile(
      _textValues,
      isFormValid: _formKey.currentState?.validate() ?? false,
    );
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
    final mobile = ref.read(userCompleteProfileProvider).pendingMobile;
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
    final picked = await pickDateOfBirth(
      context,
      current: ref.read(userCompleteProfileProvider).dob,
    );
    if (picked != null) _notifier.setDob(picked);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userCompleteProfileProvider);

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
                  title: state.isEditing
                      ? 'Edit Profile'
                      : 'Complete Your Profile',
                  showMoreIcon: false,
                  onBackPress: _onBack,
                ),
              ),
              if (state.isLoading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (state.loadError != null)
                Expanded(child: _buildLoadFailed(state.loadError!))
              else
                Expanded(
                  child: Form(
                    key: _formKey,
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
                          _buildBasicInfoSection(state),
                          const IconHeader(
                            icon: AppImages.location,
                            title: 'Address Information',
                          ),
                          _buildAddressSection(state),
                          SizedBox(height: AppDimensions.padding40h),
                          PrimaryButton(
                            text: state.isEditing
                                ? "Save Changes"
                                : "Submit Profile",
                            isLoading: state.isSubmitting,
                            onPressed: _submit,
                          ),
                          SizedBox(height: AppDimensions.padding40h),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Shown instead of the form when the saved profile couldn't be fetched
  /// — an empty form here could overwrite the user's saved details.
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

  Widget _buildBasicInfoSection(UserCompleteProfileState state) {
    final hasPhoto =
        state.profileImage != null || state.profileImageUrl != null;
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
                      onTap: () => _notifier.pickImage(ImageSource.gallery),
                      child: CustomPaint(
                        painter: DashedBorderPainter(
                          color: state.profileImageError != null
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
                          child: !hasPhoto
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
                                      child: state.profileImage != null
                                          ? Image.file(
                                              state.profileImage!,
                                              fit: BoxFit.cover,
                                              width: AppDimensions
                                                  .containerWidth80w,
                                              height: AppDimensions
                                                  .containerHeight145h,
                                            )
                                          : Image.network(
                                              state.profileImageUrl!,
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
                    if (state.profileImageError != null)
                      _buildInlineError(state.profileImageError!),
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
                    validator: _notifier.validateRequired,
                  ),
                  SizedBox(height: AppDimensions.padding15h),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AddressFormField(
                        label: "Mobile Number",
                        hintText: state.canAddMobile
                            ? "Add your mobile number"
                            : "Enter your Number",
                        controller: _mobileController,
                        // No number on the account yet: it's added through
                        // the "Add Mobile Number" dialog, not typed here,
                        // and stays fixed until verified.
                        readOnly:
                            state.canAddMobile || state.pendingMobile != null,
                        keyboardType: TextInputType.phone,
                        inputFormatters: mobileNumberFormatters,
                        errorText: state.mobileError,
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
                          builder: (_, value, _) => state.canAddMobile
                              ? _buildMobileActionButton(
                                  state,
                                  "Add Mobile Number",
                                  _addMobile,
                                )
                              : state.pendingMobile != null
                              ? _buildMobileActionButton(
                                  state,
                                  "Verify",
                                  _verifyAddedMobile,
                                )
                              : state.isMobileVerified(value.text)
                              ? _buildVerifiedBadge()
                              : _buildMobileActionButton(
                                  state,
                                  state.isSendingOtp
                                      ? "Sending..."
                                      : "Send OTP",
                                  _sendOtp,
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
                    value: state.gender,
                    items: UserCompleteProfileNotifier.genderOptions.keys
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: _notifier.setGender,
                  ),
                  if (state.genderError != null)
                    _buildInlineError(state.genderError!),
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
                              color: state.dobError != null
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
                                state.dob ?? "DD/MM/YYYY",
                                style: customTextStyle(
                                  AppTextSizes.smallTextSize,
                                  state.dob == null
                                      ? AppColors.grey
                                      : AppColors.black,
                                  FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (state.dobError != null)
                        _buildInlineError(state.dobError!),
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

  Widget _buildMobileActionButton(
    UserCompleteProfileState state,
    String label,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: state.isSendingOtp ? null : onTap,
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

  Widget _buildAddressSection(UserCompleteProfileState state) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SearchablePickerField(
                label: "Country",
                hintText: "Select Country",
                value: state.selectedCountry?.name,
                options: [for (final c in state.countries) c.name],
                isLoading: state.isLoadingCountries,
                onSelected: _notifier.setCountry,
                validator: _notifier.validateRequired,
              ),
            ),
            SizedBox(width: AppDimensions.padding15w),
            Expanded(
              child: SearchablePickerField(
                label: "State",
                hintText: "Select State",
                value: state.selectedState?.name,
                options: [for (final s in state.states) s.name],
                isLoading: state.isLoadingStates,
                onSelected: _notifier.setSelectedState,
                validator: _notifier.validateRequired,
              ),
            ),
          ],
        ),
        SizedBox(height: AppDimensions.padding15h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SearchablePickerField(
                label: "City",
                hintText: "Select City",
                value: state.selectedCity,
                options: state.cities,
                isLoading: state.isLoadingCities,
                onSelected: _notifier.setCity,
                validator: _notifier.validateRequired,
              ),
            ),
            SizedBox(width: AppDimensions.padding15w),
            Expanded(
              child: AddressFormField(
                label: "Pincode",
                hintText: "Enter Pincode",
                controller: _pincodeController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                validator: _notifier.validatePincode,
              ),
            ),
          ],
        ),
        SizedBox(height: AppDimensions.padding15h),
        AddressFormField(
          label: "Full Address",
          hintText: "Full Address",
          controller: _fullAddressController,
          maxLines: 3,
          validator: _notifier.validateRequired,
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
