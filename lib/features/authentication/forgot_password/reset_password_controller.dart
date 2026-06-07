// File: lib/features/authentication/forgot_password/reset_password_controller.dart
// Purpose: State management and logic for the Reset Password screen.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urban_services/routes/route_names.dart';

class ResetPasswordController extends GetxController {
  // Controllers for password and confirm password fields
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Focus nodes for managing input flow
  final passwordFocus = FocusNode();
  final confirmPasswordFocus = FocusNode();

  // Reactive state for password visibility toggles
  final obscurePassword = true.obs;
  final obscureConfirmPassword = true.obs;

  // Reactive error strings for validation feedback
  final passwordError = RxnString();
  final confirmPasswordError = RxnString();

  /// Toggles visibility for the password field.
  void togglePasswordVisibility() =>
      obscurePassword.value = !obscurePassword.value;

  /// Toggles visibility for the confirm password field.
  void toggleConfirmPasswordVisibility() =>
      obscureConfirmPassword.value = !obscureConfirmPassword.value;

  /// Validates password inputs.
  bool validate() {
    bool isValid = true;

    // Password validation
    if (passwordController.text.isEmpty) {
      passwordError.value = "Password is required";
      isValid = false;
    } else if (passwordController.text.length < 8) {
      passwordError.value = "Password must be at least 8 characters";
      isValid = false;
    } else {
      passwordError.value = null;
    }

    // Confirm password validation
    if (confirmPasswordController.text.isEmpty) {
      confirmPasswordError.value = "Please confirm your password";
      isValid = false;
    } else if (confirmPasswordController.text != passwordController.text) {
      confirmPasswordError.value = "Passwords do not match";
      isValid = false;
    } else {
      confirmPasswordError.value = null;
    }

    return isValid;
  }

  /// Updates the password and redirects to login.
  void updatePassword() {
    if (validate()) {
      debugPrint("Updating password...");
      // TODO: Implement API call for password update
      Get.offAllNamed(RouteNames.loginScreen);
    }
  }

  @override
  void onClose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    passwordFocus.dispose();
    confirmPasswordFocus.dispose();
    super.onClose();
  }
}
