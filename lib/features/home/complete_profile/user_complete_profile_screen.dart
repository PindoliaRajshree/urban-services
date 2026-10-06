// File: lib/features/home/complete_profile/user_complete_profile_screen.dart
// Purpose: Single-section form for a regular user to complete their basic
// profile details (photo, name, mobile, email, gender, DOB) and address.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:urban_services/core/utils/input_formatters.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_images.dart';
import 'package:urban_services/core/constants/app_text_sizes.dart';
import 'package:urban_services/features/home/complete_profile/user_complete_profile_provider.dart';
import 'package:urban_services/features/profile_common/basic_info.dart';
import 'package:urban_services/widgets/address_form_field.dart';
import 'package:urban_services/widgets/common_app_bar.dart';
import 'package:urban_services/widgets/custom_dropdown.dart';
import 'package:urban_services/widgets/custom_text_style.dart';
import 'package:urban_services/widgets/dashed_border_painter.dart';
import 'package:urban_services/widgets/icon_header.dart';
import 'package:urban_services/widgets/primary_button.dart';
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
  final _countryController = TextEditingController();
  final _stateController = TextEditingController();
  final _cityController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _fullAddressController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  UserCompleteProfileNotifier get _notifier =>
      ref.read(userCompleteProfileProvider.notifier);

  @override
  void initState() {
    super.initState();
    // Clear mobile error when typing
    _mobileController.addListener(() {
      if (_mobileController.text.isNotEmpty) _notifier.clearMobileError();
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _countryController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    _fullAddressController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userCompleteProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.padding20w,
                ),
                child: const CommonAppBar(
                  title: 'Complete User Profile',
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
                      _buildBasicInfoSection(state),
                      const IconHeader(
                        icon: AppImages.location,
                        title: 'Address Information',
                      ),
                      _buildAddressSection(),
                      SizedBox(height: AppDimensions.padding40h),
                      PrimaryButton(
                        text: "Submit Profile",
                        onPressed: () => _notifier.submitProfile(
                          isFormValid:
                              _formKey.currentState?.validate() ?? false,
                        ),
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

  Widget _buildBasicInfoSection(UserCompleteProfileState state) {
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
                          child: state.profileImage == null
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
                                        state.profileImage!,
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
                    value: state.gender,
                    items: ["Male", "Female", "Other"]
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

  Widget _buildAddressSection() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AddressFormField(
                label: "Country",
                hintText: "Enter Country",
                controller: _countryController,
                validator: _notifier.validateRequired,
              ),
            ),
            SizedBox(width: AppDimensions.padding15w),
            Expanded(
              child: AddressFormField(
                label: "State",
                hintText: "Enter State",
                controller: _stateController,
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
              child: AddressFormField(
                label: "City",
                hintText: "Enter City",
                controller: _cityController,
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
