// File: lib/features/home_provider/complete_profile/complete_profile_controller.dart
// Purpose: State management for the 7-step provider profile completion form with dynamic progress tracking and inline validation.

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:urban_services/core/utils/validators.dart';
import 'package:urban_services/features/home_provider/complete_profile/verify_number_dialog.dart';
import 'package:urban_services/routes/route_names.dart';

class CompleteProfileController extends GetxController {
  final ImagePicker _picker = ImagePicker();

  // --- Step Tracking ---
  final currentStep = 0.obs;

  // --- Basic Information (Step 0) ---
  final profileImage = Rxn<File>();
  final fullNameController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final gender = RxnString();
  final dob = RxnString();

  // --- Service Details (Step 1) ---
  final serviceCategory = RxnString();
  final subServices = RxnString();
  final experience = RxnString();
  final descriptionController = TextEditingController();

  // --- Pricing (Step 2) ---
  final startingPriceController = TextEditingController();
  final perHourRateController = TextEditingController();
  final perVisitRateController = TextEditingController();
  final customPricingController = TextEditingController();

  // --- Service Area (Step 3) ---
  final cityController = TextEditingController();
  final areaController = TextEditingController();
  final selectedRadius = '5km'.obs;

  // --- Availability (Step 4) ---
  final workType = 'Full Time'.obs;

  // --- Documents (Step 5) ---
  final adhaarFront = Rxn<File>();
  final adhaarBack = Rxn<File>();
  final panCard = Rxn<File>();

  // --- Bank Details (Step 6) ---
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
  // Service dropdown errors
  final categoryError = RxnString();
  final subServiceError = RxnString();
  final experienceError = RxnString();
  // IFSC and OTP errors
  final ifscError = RxnString();
  final otpError = RxnString();

  // --- OTP Controller for dialog ---
  final otpController = TextEditingController();

  // --- Validation States ---
  final formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    // Add listeners to all required fields to update progress in real-time
    fullNameController.addListener(updateProgress);
    mobileController.addListener(updateProgress);
    descriptionController.addListener(updateProgress);
    startingPriceController.addListener(updateProgress);
    perHourRateController.addListener(updateProgress);
    cityController.addListener(updateProgress);
    areaController.addListener(updateProgress);
    accountHolderController.addListener(updateProgress);
    accountNumberController.addListener(updateProgress);
    ifscController.addListener(updateProgress);

    // Ever listeners for reactive variables to clear errors and update progress
    ever(profileImage, (val) {
      if (val != null) profileImageError.value = null;
      updateProgress();
    });
    ever(gender, (val) {
      if (val != null) genderError.value = null;
      updateProgress();
    });
    ever(dob, (val) {
      if (val != null) dobError.value = null;
      updateProgress();
    });
    ever(serviceCategory, (val) {
      if (val != null) categoryError.value = null;
      updateProgress();
    });
    ever(subServices, (val) {
      if (val != null) subServiceError.value = null;
      updateProgress();
    });
    ever(experience, (val) {
      if (val != null) experienceError.value = null;
      updateProgress();
    });
    ever(adhaarFront, (val) {
      if (val != null) adhaarFrontError.value = null;
      updateProgress();
    });
    ever(adhaarBack, (val) {
      if (val != null) adhaarBackError.value = null;
      updateProgress();
    });

    // Clear OTP error when typing
    otpController.addListener(() {
      if (otpController.text.isNotEmpty) {
        otpError.value = null;
      }
    });

    // Clear IFSC error when typing
    ifscController.addListener(() {
      if (ifscController.text.isNotEmpty) {
        ifscError.value = null;
      }
    });
  }

  /// Calculates the highest valid sequential step and updates currentStep.
  void updateProgress() {
    int progress = 0;

    // Check Step 0: Basic Info
    if (profileImage.value != null &&
        fullNameController.text.trim().isNotEmpty &&
        mobileController.text.trim().length == 10 &&
        gender.value != null &&
        dob.value != null) {
      progress = 1;
    } else {
      currentStep.value = 0;
      return;
    }

    // Check Step 1: Service Details
    if (serviceCategory.value != null &&
        subServices.value != null &&
        experience.value != null &&
        descriptionController.text.trim().isNotEmpty) {
      progress = 2;
    } else {
      currentStep.value = 1;
      return;
    }

    // Check Step 2: Pricing
    if (startingPriceController.text.trim().isNotEmpty &&
        perHourRateController.text.trim().isNotEmpty) {
      progress = 3;
    } else {
      currentStep.value = 2;
      return;
    }

    // Check Step 3: Service Area
    if (cityController.text.trim().isNotEmpty &&
        areaController.text.trim().isNotEmpty) {
      progress = 4;
    } else {
      currentStep.value = 3;
      return;
    }

    // Check Step 4: Availability
    progress = 5;

    // Check Step 5: Documents
    if (adhaarFront.value != null && adhaarBack.value != null) {
      progress = 6;
    } else {
      currentStep.value = 5;
      return;
    }

    // Check Step 6: Bank Details
    if (accountHolderController.text.trim().isNotEmpty &&
        accountNumberController.text.trim().isNotEmpty &&
        ifscController.text.trim().isNotEmpty) {
      progress = 7;
    } else {
      currentStep.value = 6;
      return;
    }

    currentStep.value = progress;
  }

  // --- Methods ---

  /// Picks an image from camera or gallery for profile
  Future<void> pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      profileImage.value = File(pickedFile.path);
    }
  }

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
      Get.snackbar(
        "Error",
        "Enter a valid 10-digit mobile number",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
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
    Get.snackbar(
      "Success",
      "IFSC Code Verified",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  /// Sets the service radius selection
  void setRadius(String radius) {
    selectedRadius.value = radius;
    updateProgress();
  }

  /// Sets the work type selection
  void setWorkType(String type) {
    workType.value = type;
    updateProgress();
  }

  /// Picks a document (image, pdf, doc) with 4MB limit
  Future<void> pickDocument(String type) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      int sizeInBytes = await file.length();
      double sizeInMb = sizeInBytes / (1024 * 1024);

      if (sizeInMb > 4) {
        Get.snackbar(
          "Error",
          "File size must be less than 4MB",
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      if (type == 'aadhaarFront') adhaarFront.value = file;
      if (type == 'aadhaarBack') adhaarBack.value = file;
      if (type == 'pan') panCard.value = file;
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

  /// Validates all mandatory fields and updates inline errors
  bool validateCustomFields() {
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

  /// Validates all mandatory fields and submits the profile
  void submitProfile() {
    bool isFormValid = formKey.currentState?.validate() ?? false;
    bool areCustomFieldsValid = validateCustomFields();

    if (isFormValid && areCustomFieldsValid) {
      debugPrint("Submitting Provider Profile...");
      Get.offAllNamed(RouteNames.homeMain);
    }
  }

  @override
  void onClose() {
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
