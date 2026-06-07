// File: lib/features/authentication/forgot_password/otp_controller.dart
// Purpose: State management and logic for the Check Email (OTP) screen.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urban_services/routes/route_names.dart';

class OtpController extends GetxController {
  // Controllers for the 5 OTP input fields
  final List<TextEditingController> otpControllers = List.generate(
    5,
    (_) => TextEditingController(),
  );

  // Focus nodes for each field to handle auto-focus movement
  final List<FocusNode> focusNodes = List.generate(5, (_) => FocusNode());

  /// Handles logic when a digit is entered in one of the fields.
  void onDigitChanged(int index, String value) {
    if (value.isNotEmpty && index < 4) {
      // Move to next field automatically
      focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      // Move to previous field on backspace
      focusNodes[index - 1].requestFocus();
    }
  }

  /// Verifies the 5-digit code.
  void verifyCode() {
    String code = otpControllers.map((c) => c.text).join();
    if (code.length == 5) {
      debugPrint("Verifying OTP: $code");
      // TODO: Implement actual verification logic
      Get.toNamed(RouteNames.resetPasswordScreen);
    } else {
      Get.snackbar(
        "Error",
        "Please enter the full 5-digit code",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Logic to resend the code.
  void resendCode() {
    debugPrint("Resending code...");
    // TODO: Implement resend logic
  }

  @override
  void onClose() {
    for (var c in otpControllers) {
      c.dispose();
    }
    for (var n in focusNodes) {
      n.dispose();
    }
    super.onClose();
  }
}
