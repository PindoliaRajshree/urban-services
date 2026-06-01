import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urban_services/routes/route_names.dart';

class LoginController extends GetxController {
  final mobileController = TextEditingController();
  final passwordController = TextEditingController();
  
  final mobileFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();

  final mobileError = RxnString();
  final passwordError = RxnString();

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
      final password = passwordController.text;
      final hasUpperCase = password.contains(RegExp(r'[A-Z]'));
      final hasLowerCase = password.contains(RegExp(r'[a-z]'));
      final hasDigit = password.contains(RegExp(r'[0-9]'));
      final hasSpecialCharacters = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
      final hasMinLength = password.length >= 8;
      final hasMaxLength = password.length <= 20;

      if (!hasMinLength || !hasMaxLength) {
        passwordError.value = "Password must be between 8 and 20 characters";
        isValid = false;
      } else if (!hasUpperCase) {
        passwordError.value = "At least one uppercase letter required";
        isValid = false;
      } else if (!hasLowerCase) {
        passwordError.value = "At least one lowercase letter required";
        isValid = false;
      } else if (!hasDigit) {
        passwordError.value = "At least one digit required";
        isValid = false;
      } else if (!hasSpecialCharacters) {
        passwordError.value = "At least one special character required";
        isValid = false;
      } else {
        passwordError.value = null;
      }
    }

    return isValid;
  }

  void login() {
    if (validate()) {
      debugPrint("Login with: ${mobileController.text}");
      Get.offAllNamed(RouteNames.homeMain);
    }
  }

  void loginWithGoogle() {
    debugPrint("Login with Google");
  }

  @override
  void onClose() {
    mobileController.dispose();
    passwordController.dispose();
    mobileFocusNode.dispose();
    passwordFocusNode.dispose();
    super.onClose();
  }
}
