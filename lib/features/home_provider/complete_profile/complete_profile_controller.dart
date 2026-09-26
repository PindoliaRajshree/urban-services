// File: lib/features/home_provider/complete_profile/complete_profile_controller.dart
// Purpose: State management for the 3-step provider profile completion form
// (Basic Information -> Service Details -> Bank Details) with per-step
// validation and page navigation.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:urban_services/core/services/api_result.dart';
import 'package:urban_services/core/utils/validators.dart';
import 'package:urban_services/features/home_provider/complete_profile/complete_profile_repository.dart';
import 'package:urban_services/features/home_provider/complete_profile/models/profile_update_request.dart';
import 'package:urban_services/features/home_provider/complete_profile/service_type_controller.dart';
import 'package:urban_services/features/home_provider/complete_profile/verify_number_dialog.dart';
import 'package:urban_services/routes/route_names.dart';
import 'package:urban_services/widgets/custom_snackbar.dart';

class CompleteProfileController extends GetxController {
  CompleteProfileController({CompleteProfileRepository? repository})
    : _repository = repository ?? CompleteProfileRepository();

  final CompleteProfileRepository _repository;
  final ImagePicker _picker = ImagePicker();

  // Shared with ProviderHomeScreen, which preloads service categories on
  // Home so they're already available here. Falls back to fetching directly
  // in onInit() below in case this screen is somehow reached first.
  final serviceTypeController = Get.isRegistered<ServiceTypeController>()
      ? Get.find<ServiceTypeController>()
      : Get.put(ServiceTypeController());

  // --- Step Tracking ---
  // Step 0 = Basic Information, Step 1 = Service Details, Step 2 = Bank Details
  static const int totalSteps = 3;
  final currentStep = 0.obs;
  final pageController = PageController();

  bool get isFirstStep => currentStep.value == 0;
  bool get isLastStep => currentStep.value == totalSteps - 1;

  // --- Per-step form keys (each page validates only its own fields) ---
  final basicInfoFormKey = GlobalKey<FormState>();
  final serviceDetailsFormKey = GlobalKey<FormState>();
  final bankDetailsFormKey = GlobalKey<FormState>();

  // --- Basic Information (Step 0): photo, name, mobile, email, gender, dob, documents ---
  final profileImage = Rxn<File>();
  final fullNameController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final gender = RxnString();
  final dob = RxnString();

  // Documents Verification (part of Basic Information)
  final adhaarFront = Rxn<File>();
  final adhaarBack = Rxn<File>();
  final panCard = Rxn<File>();

  // --- Service Details (Step 1): category, sub services, experience, description,
  // pricing, service area, availability ---
  // Hold the selected service-type / sub-service-type id (not a display
  // string) so they map directly to what the backend expects.
  final serviceCategory = RxnInt();
  final subServices = RxnInt();
  final experience = RxnString();
  final descriptionController = TextEditingController();

  // Pricing
  final startingPriceController = TextEditingController();
  final perHourRateController = TextEditingController();
  final perVisitRateController = TextEditingController();
  final customPricingController = TextEditingController();

  // Service Area
  final cityController = TextEditingController();
  final areaController = TextEditingController();
  final selectedRadius = '5km'.obs;

  // Availability
  final workType = 'Full Time'.obs;

  // --- Bank Details (Step 2) ---
  final accountHolderController = TextEditingController();
  final accountNumberController = TextEditingController();
  final ifscController = TextEditingController();
  final upiIdController = TextEditingController();

  // --- Inline Error States ---
  final profileImageError = RxnString();
  final genderError = RxnString();
  final dobError = RxnString();
  final adhaarFrontError = RxnString();
  final adhaarBackError = RxnString();
  final panCardError = RxnString();
  // Service dropdown errors
  final categoryError = RxnString();
  final subServiceError = RxnString();
  final experienceError = RxnString();
  // IFSC and OTP errors
  final ifscError = RxnString();
  final otpError = RxnString();
  final mobileError = RxnString();

  // --- OTP Controller for dialog ---
  final otpController = TextEditingController();

  // --- Submission state ---
  final isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();

    // Fallback in case this screen is somehow reached without visiting Home
    // first (fetchServiceTypes() is a no-op if already loaded there).
    if (serviceTypeController.serviceTypes.isEmpty) {
      serviceTypeController.fetchServiceTypes();
    }

    // Clear inline errors as soon as the user provides a value.
    ever(profileImage, (val) {
      if (val != null) profileImageError.value = null;
    });
    ever(gender, (val) {
      if (val != null) genderError.value = null;
    });
    ever(dob, (val) {
      if (val != null) dobError.value = null;
    });
    ever(serviceCategory, (val) {
      if (val != null) {
        categoryError.value = null;
        // Sub-services belong to a category — reset the previous selection
        // and (re)fetch, served instantly from cache if seen before.
        subServices.value = null;
        serviceTypeController.fetchSubServiceTypes(val);
      }
    });
    ever(subServices, (val) {
      if (val != null) subServiceError.value = null;
    });
    ever(experience, (val) {
      if (val != null) experienceError.value = null;
    });
    ever(adhaarFront, (val) {
      if (val != null) adhaarFrontError.value = null;
    });
    ever(adhaarBack, (val) {
      if (val != null) adhaarBackError.value = null;
    });
    ever(panCard, (val) {
      if (val != null) panCardError.value = null;
    });

    // Clear OTP error when typing
    otpController.addListener(() {
      if (otpController.text.isNotEmpty) {
        otpError.value = null;
      }
    });

    // Clear mobile error when typing
    mobileController.addListener(() {
      if (mobileController.text.isNotEmpty) {
        mobileError.value = null;
      }
    });

    // Clear IFSC error when typing
    ifscController.addListener(() {
      if (ifscController.text.isNotEmpty) {
        ifscError.value = null;
      }
    });
  }

  // --- Step Navigation ---

  /// Validates the current step and, if valid, advances to the next page.
  void nextStep() {
    if (!_validateStep(currentStep.value)) return;

    if (currentStep.value < totalSteps - 1) {
      currentStep.value++;
      pageController.animateToPage(
        currentStep.value,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Goes back to the previous page, or leaves the screen if already on step 0.
  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
      pageController.animateToPage(
        currentStep.value,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Get.back();
    }
  }

  bool _validateStep(int step) {
    switch (step) {
      case 0:
        final formValid = basicInfoFormKey.currentState?.validate() ?? false;
        final customValid = validateBasicInfoFields();
        return formValid && customValid;
      case 1:
        final formValid =
            serviceDetailsFormKey.currentState?.validate() ?? false;
        final customValid = validateServiceDetailsFields();
        return formValid && customValid;
      default:
        return true;
    }
  }

  // --- Methods ---

  void removeProfileImage() {
    profileImage.value = null;
  }

  /// Opens the system date picker for DOB
  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      dob.value = DateFormat('dd/MM/yyyy').format(picked);
    }
  }

  /// Handles OTP verification dialog logic
  void sendOtp() {
    if (mobileController.text.length != 10) {
      mobileError.value = "Enter a valid 10-digit mobile number";
      return;
    }
    mobileError.value = null;
    otpError.value = null;
    otpController.clear();
    debugPrint("Sending OTP to ${mobileController.text}");
    Get.dialog(
      VerifyNumberDialog(phoneNumber: mobileController.text),
      barrierDismissible: false,
    );
  }

  /// Verifies the OTP entered in the dialog
  void verifyOtp() {
    if (otpController.text.trim().isEmpty) {
      otpError.value = "Please enter OTP";
      return;
    }
    debugPrint("Verifying OTP: ${otpController.text}");
    Get.back(); // Close dialog on success
  }

  /// Logic to verify IFSC code
  void verifyIfsc() {
    final ifsc = ifscController.text.trim();
    if (ifsc.isEmpty) {
      ifscError.value = "Please enter IFSC code first";
      return;
    }
    // Basic IFSC regex: 4 chars, 0, then 6 alphanumeric
    if (!RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(ifsc)) {
      ifscError.value = "Invalid IFSC code format";
      return;
    }
    ifscError.value = null;
    debugPrint("Verifying IFSC: $ifsc");
    CustomSnackBar.showSuccess(title: "Success", message: "IFSC Code Verified");
  }

  /// Sets the service radius selection
  void setRadius(String radius) {
    selectedRadius.value = radius;
  }

  /// Sets the work type selection
  void setWorkType(String type) {
    workType.value = type;
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
      if (sizeInMb > 4) {
        if (field == 'aadhaarFront') {
          adhaarFrontError.value = "File size must be less than 4MB";
        }
        if (field == 'aadhaarBack') {
          adhaarBackError.value = "File size must be less than 4MB";
        }
        if (field == 'pan') panCardError.value = "File size must be less than 4MB";
        return;
      }
    }

    switch (field) {
      case 'profile':
        profileImage.value = file;
      case 'aadhaarFront':
        adhaarFront.value = file;
      case 'aadhaarBack':
        adhaarBack.value = file;
      case 'pan':
        panCard.value = file;
    }
  }

  void removeDocument(String type) {
    if (type == 'aadhaarFront') adhaarFront.value = null;
    if (type == 'aadhaarBack') adhaarBack.value = null;
    if (type == 'pan') panCard.value = null;
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
    bool isValid = true;

    if (profileImage.value == null) {
      profileImageError.value = "Required";
      isValid = false;
    } else {
      profileImageError.value = null;
    }

    if (gender.value == null) {
      genderError.value = "Required";
      isValid = false;
    } else {
      genderError.value = null;
    }

    if (dob.value == null) {
      dobError.value = "Required";
      isValid = false;
    } else {
      dobError.value = null;
    }

    if (adhaarFront.value == null) {
      adhaarFrontError.value = "Required";
      isValid = false;
    } else {
      adhaarFrontError.value = null;
    }

    if (adhaarBack.value == null) {
      adhaarBackError.value = "Required";
      isValid = false;
    } else {
      adhaarBackError.value = null;
    }

    return isValid;
  }

  /// Validates the non-TextFormField parts of Step 1 (Service Details):
  /// service category, sub services and experience dropdowns.
  bool validateServiceDetailsFields() {
    bool isValid = true;

    if (serviceCategory.value == null) {
      categoryError.value = "Required";
      isValid = false;
    } else {
      categoryError.value = null;
    }

    if (subServices.value == null) {
      subServiceError.value = "Required";
      isValid = false;
    } else {
      subServiceError.value = null;
    }

    if (experience.value == null) {
      experienceError.value = "Required";
      isValid = false;
    } else {
      experienceError.value = null;
    }

    return isValid;
  }

  /// Validates the final (Bank Details) step and submits the whole profile
  /// (all 3 steps) to provider/provide-profile/update.
  Future<void> submitProfile() async {
    final isFormValid = bankDetailsFormKey.currentState?.validate() ?? false;
    if (!isFormValid) return;

    // Earlier steps are validated on nextStep(), but re-check here since
    // the required files/dropdowns aren't part of a Form's own validate().
    if (!validateBasicInfoFields()) {
      currentStep.value = 0;
      pageController.jumpToPage(0);
      return;
    }
    if (!validateServiceDetailsFields()) {
      currentStep.value = 1;
      pageController.jumpToPage(1);
      return;
    }

    isSubmitting.value = true;
    final request = ProfileUpdateRequest(
      fullName: fullNameController.text.trim(),
      mobileNumber: mobileController.text.trim(),
      email: emailController.text.trim(),
      gender: gender.value!,
      dob: dob.value!,
      serviceTypeId: serviceCategory.value!,
      subServiceTypeId: subServices.value!,
      experienceYears: experience.value!,
      description: descriptionController.text.trim(),
      startingPrice: startingPriceController.text.trim(),
      perHourRate: perHourRateController.text.trim(),
      perVisitRate: perVisitRateController.text.trim(),
      customPricing: customPricingController.text.trim(),
      city: cityController.text.trim(),
      area: areaController.text.trim(),
      serviceRadius: selectedRadius.value,
      workType: workType.value,
      accountHolderName: accountHolderController.text.trim(),
      accountNumber: accountNumberController.text.trim(),
      ifscCode: ifscController.text.trim(),
      upiId: upiIdController.text.trim(),
      profileImage: profileImage.value!,
      aadhaarFront: adhaarFront.value!,
      aadhaarBack: adhaarBack.value!,
      panCard: panCard.value,
    );

    final result = await _repository.updateProfile(request);
    isSubmitting.value = false;

    switch (result) {
      case ApiSuccess(data: final data):
        debugPrint(
          "Profile update success: message=${data.message}, data=${data.data}",
        );
        CustomSnackBar.showSuccess(
          message: data.message ?? "Profile submitted successfully",
        );
        Get.offAllNamed(RouteNames.homeMain);
      case ApiFailure(message: final message):
        CustomSnackBar.showError(message: message);
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    fullNameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    descriptionController.dispose();
    startingPriceController.dispose();
    perHourRateController.dispose();
    perVisitRateController.dispose();
    customPricingController.dispose();
    cityController.dispose();
    areaController.dispose();
    accountHolderController.dispose();
    accountNumberController.dispose();
    ifscController.dispose();
    upiIdController.dispose();
    otpController.dispose();
    super.onClose();
  }
}
