// File: lib/features/home_provider/complete_profile/complete_profile_provider.dart
// Purpose: State management for the 3-step provider profile completion form
// (Basic Information -> Service Details -> Bank Details) with per-step
// validation and submission. Text fields, form keys and the PageController
// live in the screen (see ProviderProfileForm); this holds everything else.

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:urban_services/core/network/api_result.dart';
import 'package:urban_services/core/utils/validators.dart';
import 'package:urban_services/features/home_provider/complete_profile/complete_profile_repository.dart';
import 'package:urban_services/features/home_provider/complete_profile/models/profile_update_request.dart';
import 'package:urban_services/routes/app_router.dart';
import 'package:urban_services/routes/route_names.dart';
import 'package:urban_services/widgets/custom_snackbar.dart';

/// Text values of the whole form, read from the screen's controllers.
class ProviderProfileTextValues {
  const ProviderProfileTextValues({
    required this.fullName,
    required this.mobile,
    required this.email,
    required this.description,
    required this.startingPrice,
    required this.perHourRate,
    required this.perVisitRate,
    required this.customPricing,
    required this.city,
    required this.area,
    required this.accountHolder,
    required this.accountNumber,
    required this.ifsc,
    required this.upiId,
  });

  final String fullName;
  final String mobile;
  final String email;
  final String description;
  final String startingPrice;
  final String perHourRate;
  final String perVisitRate;
  final String customPricing;
  final String city;
  final String area;
  final String accountHolder;
  final String accountNumber;
  final String ifsc;
  final String upiId;
}

class ProviderProfileState {
  const ProviderProfileState({
    this.currentStep = 0,
    this.profileImage,
    this.gender,
    this.dob,
    this.adhaarFront,
    this.adhaarBack,
    this.panCard,
    this.serviceCategory,
    this.subServices,
    this.experience,
    this.selectedRadius = '5km',
    this.workType = 'Full Time',
    this.profileImageError,
    this.genderError,
    this.dobError,
    this.adhaarFrontError,
    this.adhaarBackError,
    this.panCardError,
    this.categoryError,
    this.subServiceError,
    this.experienceError,
    this.ifscError,
    this.mobileError,
    this.isSubmitting = false,
  });

  // --- Step Tracking ---
  // Step 0 = Basic Information, Step 1 = Service Details, Step 2 = Bank Details
  final int currentStep;

  // --- Basic Information (Step 0) ---
  final File? profileImage;
  final String? gender;
  final String? dob;

  // Documents Verification (part of Basic Information)
  final File? adhaarFront;
  final File? adhaarBack;
  final File? panCard;

  // --- Service Details (Step 1) ---
  // Hold the selected service-type / sub-service-type id (not a display
  // string) so they map directly to what the backend expects.
  final int? serviceCategory;
  final int? subServices;
  final String? experience;
  final String selectedRadius;
  final String workType;

  // --- Inline Error States ---
  final String? profileImageError;
  final String? genderError;
  final String? dobError;
  final String? adhaarFrontError;
  final String? adhaarBackError;
  final String? panCardError;
  final String? categoryError;
  final String? subServiceError;
  final String? experienceError;
  final String? ifscError;
  final String? mobileError;

  // --- Submission state ---
  final bool isSubmitting;

  bool get isFirstStep => currentStep == 0;
  bool get isLastStep => currentStep == ProviderProfileNotifier.totalSteps - 1;

  ProviderProfileState copyWith({
    int? currentStep,
    File? Function()? profileImage,
    String? gender,
    String? dob,
    File? Function()? adhaarFront,
    File? Function()? adhaarBack,
    File? Function()? panCard,
    int? serviceCategory,
    int? Function()? subServices,
    String? experience,
    String? selectedRadius,
    String? workType,
    String? Function()? profileImageError,
    String? Function()? genderError,
    String? Function()? dobError,
    String? Function()? adhaarFrontError,
    String? Function()? adhaarBackError,
    String? Function()? panCardError,
    String? Function()? categoryError,
    String? Function()? subServiceError,
    String? Function()? experienceError,
    String? Function()? ifscError,
    String? Function()? mobileError,
    bool? isSubmitting,
  }) => ProviderProfileState(
    currentStep: currentStep ?? this.currentStep,
    profileImage: profileImage != null ? profileImage() : this.profileImage,
    gender: gender ?? this.gender,
    dob: dob ?? this.dob,
    adhaarFront: adhaarFront != null ? adhaarFront() : this.adhaarFront,
    adhaarBack: adhaarBack != null ? adhaarBack() : this.adhaarBack,
    panCard: panCard != null ? panCard() : this.panCard,
    serviceCategory: serviceCategory ?? this.serviceCategory,
    subServices: subServices != null ? subServices() : this.subServices,
    experience: experience ?? this.experience,
    selectedRadius: selectedRadius ?? this.selectedRadius,
    workType: workType ?? this.workType,
    profileImageError: profileImageError != null
        ? profileImageError()
        : this.profileImageError,
    genderError: genderError != null ? genderError() : this.genderError,
    dobError: dobError != null ? dobError() : this.dobError,
    adhaarFrontError: adhaarFrontError != null
        ? adhaarFrontError()
        : this.adhaarFrontError,
    adhaarBackError: adhaarBackError != null
        ? adhaarBackError()
        : this.adhaarBackError,
    panCardError: panCardError != null ? panCardError() : this.panCardError,
    categoryError: categoryError != null ? categoryError() : this.categoryError,
    subServiceError: subServiceError != null
        ? subServiceError()
        : this.subServiceError,
    experienceError: experienceError != null
        ? experienceError()
        : this.experienceError,
    ifscError: ifscError != null ? ifscError() : this.ifscError,
    mobileError: mobileError != null ? mobileError() : this.mobileError,
    isSubmitting: isSubmitting ?? this.isSubmitting,
  );
}

class ProviderProfileNotifier extends Notifier<ProviderProfileState> {
  static const int totalSteps = 3;

  final ImagePicker _picker = ImagePicker();

  @override
  ProviderProfileState build() => const ProviderProfileState();

  // --- Step Navigation ---

  void goToStep(int step) => state = state.copyWith(currentStep: step);

  // --- Field setters (each clears its inline error, replacing the GetX
  // `ever` listeners) ---

  void setGender(String? value) {
    if (value == null) return;
    state = state.copyWith(gender: value, genderError: () => null);
  }

  void setDob(DateTime picked) {
    state = state.copyWith(
      dob: DateFormat('dd/MM/yyyy').format(picked),
      dobError: () => null,
    );
  }

  /// Sub-services belong to a category — reset the previous selection. The
  /// screen watches subServiceTypesProvider(category), which fetches (or
  /// serves from cache) the new list.
  void setServiceCategory(int? value) {
    if (value == null) return;
    state = state.copyWith(
      serviceCategory: value,
      categoryError: () => null,
      subServices: () => null,
    );
  }

  void setSubService(int? value) {
    if (value == null) return;
    state = state.copyWith(
      subServices: () => value,
      subServiceError: () => null,
    );
  }

  void setExperience(String? value) {
    if (value == null) return;
    state = state.copyWith(experience: value, experienceError: () => null);
  }

  /// Sets the service radius selection
  void setRadius(String radius) =>
      state = state.copyWith(selectedRadius: radius);

  /// Sets the work type selection
  void setWorkType(String type) => state = state.copyWith(workType: type);

  void clearMobileError() {
    if (state.mobileError != null) {
      state = state.copyWith(mobileError: () => null);
    }
  }

  void clearIfscError() {
    if (state.ifscError != null) state = state.copyWith(ifscError: () => null);
  }

  void removeProfileImage() {
    state = state.copyWith(profileImage: () => null);
  }

  void removeDocument(String type) {
    if (type == 'aadhaarFront') state = state.copyWith(adhaarFront: () => null);
    if (type == 'aadhaarBack') state = state.copyWith(adhaarBack: () => null);
    if (type == 'pan') state = state.copyWith(panCard: () => null);
  }

  /// Picks an image (camera or gallery) for one of the four photo/document
  /// fields on this form — profile photo, Aadhaar front/back, or PAN card —
  /// identified by [field]. Aadhaar/PAN are capped at 4MB; the profile photo
  /// has no size cap (matches the previous per-field behavior).
  Future<void> pickPhotoFor(String field, ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile == null) return;

    final file = File(pickedFile.path);

    if (field != 'profile') {
      final sizeInMb = await file.length() / (1024 * 1024);
      if (!ref.mounted) return;
      if (sizeInMb > 4) {
        const error = "File size must be less than 4MB";
        if (field == 'aadhaarFront') {
          state = state.copyWith(adhaarFrontError: () => error);
        }
        if (field == 'aadhaarBack') {
          state = state.copyWith(adhaarBackError: () => error);
        }
        if (field == 'pan') state = state.copyWith(panCardError: () => error);
        return;
      }
    }
    if (!ref.mounted) return;

    switch (field) {
      case 'profile':
        state = state.copyWith(
          profileImage: () => file,
          profileImageError: () => null,
        );
      case 'aadhaarFront':
        state = state.copyWith(
          adhaarFront: () => file,
          adhaarFrontError: () => null,
        );
      case 'aadhaarBack':
        state = state.copyWith(
          adhaarBack: () => file,
          adhaarBackError: () => null,
        );
      case 'pan':
        state = state.copyWith(panCard: () => file, panCardError: () => null);
    }
  }

  /// Validates the mobile number before the OTP dialog is shown. Returns
  /// true when the dialog should open.
  bool sendOtp(String mobile) {
    if (mobile.length != 10) {
      state = state.copyWith(
        mobileError: () => "Enter a valid 10-digit mobile number",
      );
      return false;
    }
    state = state.copyWith(mobileError: () => null);
    debugPrint("Sending OTP to $mobile");
    return true;
  }

  /// Logic to verify IFSC code
  void verifyIfsc(String rawIfsc) {
    final ifsc = rawIfsc.trim();
    if (ifsc.isEmpty) {
      state = state.copyWith(ifscError: () => "Please enter IFSC code first");
      return;
    }
    // Basic IFSC regex: 4 chars, 0, then 6 alphanumeric
    if (!RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(ifsc)) {
      state = state.copyWith(ifscError: () => "Invalid IFSC code format");
      return;
    }
    state = state.copyWith(ifscError: () => null);
    debugPrint("Verifying IFSC: $ifsc");
    CustomSnackBar.showSuccess(title: "Success", message: "IFSC Code Verified");
  }

  /// --- Specific Field Validators ---

  String? validateEmail(String? value) {
    if (value != null && value.isNotEmpty) {
      if (!AppValidators.isValidEmail(value)) {
        return "Enter a valid email address";
      }
    }
    return null;
  }

  String? validateAccountNumber(String? value) {
    if (value == null || value.isEmpty) return "Required";
    if (value.length < 9 || value.length > 18) {
      return "Enter valid account number";
    }
    return null;
  }

  String? validateUpi(String? value) {
    if (value != null && value.isNotEmpty) {
      if (!RegExp(r'^[\w.-]+@[\w.-]+$').hasMatch(value)) {
        return "Enter a valid UPI ID (e.g., name@upi)";
      }
    }
    return null;
  }

  /// Validates the non-TextFormField parts of Step 0 (Basic Information):
  /// profile photo, gender, dob, and required documents.
  bool validateBasicInfoFields() {
    String? required(Object? value) => value == null ? "Required" : null;
    state = state.copyWith(
      profileImageError: () => required(state.profileImage),
      genderError: () => required(state.gender),
      dobError: () => required(state.dob),
      adhaarFrontError: () => required(state.adhaarFront),
      adhaarBackError: () => required(state.adhaarBack),
    );
    return state.profileImageError == null &&
        state.genderError == null &&
        state.dobError == null &&
        state.adhaarFrontError == null &&
        state.adhaarBackError == null;
  }

  /// Validates the non-TextFormField parts of Step 1 (Service Details):
  /// service category, sub services and experience dropdowns.
  bool validateServiceDetailsFields() {
    String? required(Object? value) => value == null ? "Required" : null;
    state = state.copyWith(
      categoryError: () => required(state.serviceCategory),
      subServiceError: () => required(state.subServices),
      experienceError: () => required(state.experience),
    );
    return state.categoryError == null &&
        state.subServiceError == null &&
        state.experienceError == null;
  }

  /// Submits the whole profile (all 3 steps) to
  /// provider/provide-profile/update. The screen validates the Bank Details
  /// form first. Returns the step to jump back to when an earlier step is
  /// incomplete, otherwise null.
  Future<int?> submitProfile(ProviderProfileTextValues values) async {
    if (state.isSubmitting) return null;

    // Earlier steps are validated on Next, but re-check here since the
    // required files/dropdowns aren't part of a Form's own validate().
    if (!validateBasicInfoFields()) {
      goToStep(0);
      return 0;
    }
    if (!validateServiceDetailsFields()) {
      goToStep(1);
      return 1;
    }

    state = state.copyWith(isSubmitting: true);
    final request = ProfileUpdateRequest(
      fullName: values.fullName.trim(),
      mobileNumber: values.mobile.trim(),
      email: values.email.trim(),
      gender: state.gender!,
      dob: state.dob!,
      serviceTypeId: state.serviceCategory!,
      subServiceTypeId: state.subServices!,
      experienceYears: state.experience!,
      description: values.description.trim(),
      startingPrice: values.startingPrice.trim(),
      perHourRate: values.perHourRate.trim(),
      perVisitRate: values.perVisitRate.trim(),
      customPricing: values.customPricing.trim(),
      city: values.city.trim(),
      area: values.area.trim(),
      serviceRadius: state.selectedRadius,
      workType: state.workType,
      accountHolderName: values.accountHolder.trim(),
      accountNumber: values.accountNumber.trim(),
      ifscCode: values.ifsc.trim(),
      upiId: values.upiId.trim(),
      profileImage: state.profileImage!,
      aadhaarFront: state.adhaarFront!,
      aadhaarBack: state.adhaarBack!,
      panCard: state.panCard,
    );

    final result = await ref
        .read(completeProfileRepositoryProvider)
        .updateProfile(request);
    if (!ref.mounted) return null;
    state = state.copyWith(isSubmitting: false);

    switch (result) {
      case ApiSuccess(data: final data):
        debugPrint(
          "Profile update success: message=${data.message}, data=${data.data}",
        );
        CustomSnackBar.showSuccess(
          message: data.message ?? "Profile submitted successfully",
        );
        ref.read(routerProvider).go(RouteNames.homeMain);
      case ApiError(failure: final failure):
        CustomSnackBar.showError(message: failure.message);
    }
    return null;
  }
}

final providerProfileProvider =
    NotifierProvider.autoDispose<ProviderProfileNotifier, ProviderProfileState>(
      ProviderProfileNotifier.new,
    );
