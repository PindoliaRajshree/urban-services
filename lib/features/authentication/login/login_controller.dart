// File: lib/features/authentication/login/login_controller.dart
// Purpose: Logic for user authentication, including validation and role-based navigation.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urban_services/routes/route_names.dart';

class LoginController extends GetxController {
  // Input controllers for mobile number and password
  final mobileController = TextEditingController();
  final passwordController = TextEditingController();

  // Focus nodes for managing input focus flow
  final mobileFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();

  // Reactive error strings for real-time validation feedback
  final mobileError = RxnString();
  final passwordError = RxnString();

  // Track the selected user role (User or Provider) to determine post-login navigation
  final userRole = 'User'.obs;

  /// Sets the current user role based on the welcome screen selection
  void setRole(String role) {
    userRole.value = role;
  }

  /// Validates the login form fields
  bool validate() {
    bool isValid = true;

    if (mobileController.text.isEmpty) {
      mobileError.value = "Mobile number is required";
      isValid = false;
    } else if (mobileController.text.length != 10) {
      mobileError.value = "Please enter a valid 10-digit mobile number";
      isValid = false;
    } else {
      mobileError.value = null;
    }

    if (passwordController.text.isEmpty) {
      passwordError.value = "Password is required";
      isValid = false;
    } else {
      // Basic password validation
      final password = passwordController.text;
      if (password.length < 8) {
        passwordError.value = "Password must be at least 8 characters";
        isValid = false;
      } else {
        passwordError.value = null;
      }
    }

    return isValid;
  }

  /// Performs the login action and navigates to the address selection flow
  void login() {
    if (validate()) {
      debugPrint("Login with: ${mobileController.text} as ${userRole.value}");

      // Navigate to the address screen first before reaching the home dashboard
      Get.offAllNamed(RouteNames.addressScreen);
    }
  }

  /// Placeholder for Google authentication logic
  void loginWithGoogle() {
    debugPrint("Login with Google");
  }

  @override
  void onClose() {
    // Standard cleanup to prevent memory leaks
    mobileController.dispose();
    passwordController.dispose();
    mobileFocusNode.dispose();
    passwordFocusNode.dispose();
    super.onClose();
  }
}
