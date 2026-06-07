// File: lib/features/authentication/forgot_password/forgot_password_controller.dart
// Purpose: State management and logic for the Forgot Password screen.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urban_services/routes/route_names.dart';

class ForgotPasswordController extends GetxController {
  // Controller for capturing the mobile number
  final mobileController = TextEditingController();

  // Focus node for the mobile input field
  final mobileFocusNode = FocusNode();

  // Reactive error string for validation feedback
  final mobileError = RxnString();

  /// Validates the mobile number input.
  bool validate() {
    if (mobileController.text.trim().isEmpty) {
      mobileError.value = "Mobile number is required";
      return false;
    }
    // Basic mobile validation (can be enhanced with AppValidators)
    if (mobileController.text.trim().length < 10) {
      mobileError.value = "Please enter a valid mobile number";
      return false;
    }
    mobileError.value = null;
    return true;
  }

  /// Initiates the password reset process.
  void resetPassword() {
    if (validate()) {
      debugPrint("Resetting password for: ${mobileController.text}");
      // Navigate to OTP screen
      Get.toNamed(RouteNames.checkEmailScreen);
    }
  }

  @override
  void onClose() {
    mobileController.dispose();
    mobileFocusNode.dispose();
    super.onClose();
  }
}
