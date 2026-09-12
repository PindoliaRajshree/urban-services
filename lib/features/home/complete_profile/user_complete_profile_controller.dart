// File: lib/features/home/complete_profile/user_complete_profile_controller.dart
// Purpose: State management for the regular user's basic profile completion
// form (photo, name, mobile, email, gender, DOB) with inline validation.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:urban_services/core/utils/validators.dart';
import 'package:urban_services/features/home/complete_profile/verify_number_dialog.dart';
import 'package:urban_services/routes/route_names.dart';

class UserCompleteProfileController extends GetxController {
  final ImagePicker _picker = ImagePicker();

  // --- Basic Details ---
  final profileImage = Rxn<File>();
  final fullNameController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final gender = RxnString();
  final dob = RxnString();

  // --- Inline Error States ---
  final profileImageError = RxnString();
  final genderError = RxnString();
  final dobError = RxnString();
  final mobileError = RxnString();
  final otpError = RxnString();

  // --- OTP Controller for dialog ---
  final otpController = TextEditingController();

  // --- Validation State ---
  final formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();

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
  }

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

  String? validateEmail(String? value) {
    if (value != null && value.isNotEmpty) {
      if (!AppValidators.isValidEmail(value)) {
        return "Enter a valid email address";
      }
    }
    return null;
  }

  /// Validates the non-TextFormField parts of Basic Details: profile photo,
  /// gender and dob.
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

    return isValid;
  }

  /// Validates all mandatory fields and submits the profile
  void submitProfile() {
    final isFormValid = formKey.currentState?.validate() ?? false;
    final areCustomFieldsValid = validateBasicInfoFields();

    if (isFormValid && areCustomFieldsValid) {
      debugPrint("Submitting User Profile...");
      Get.offAllNamed(RouteNames.homeMain);
    }
  }

  @override
  void onClose() {
    fullNameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    otpController.dispose();
    super.onClose();
  }
}
