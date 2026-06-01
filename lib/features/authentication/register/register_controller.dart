import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urban_services/core/utils/validators.dart';
import 'package:urban_services/routes/route_names.dart';

class RegisterController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final nameFocusNode = FocusNode();
  final emailFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();
  final confirmPasswordFocusNode = FocusNode();

  final nameError = RxnString();
  final emailError = RxnString();
  final passwordError = RxnString();
  final confirmPasswordError = RxnString();
  final termsError = RxnString();

  final agreeToTerms = false.obs;

  bool validate() {
    bool isValid = true;

    if (nameController.text.trim().isEmpty) {
      nameError.value = "Name is required";
      isValid = false;
    } else {
      nameError.value = null;
    }

    if (emailController.text.trim().isNotEmpty && !AppValidators.isValidEmail(emailController.text)) {
      emailError.value = "Please enter a valid email";
      isValid = false;
    } else {
      emailError.value = null;
    }

    // Password validation
    final password = passwordController.text;
    if (password.isEmpty) {
      passwordError.value = "Password is required";
      isValid = false;
    } else {
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

    if (confirmPasswordController.text != passwordController.text) {
      confirmPasswordError.value = "Passwords do not match";
      isValid = false;
    } else {
      confirmPasswordError.value = null;
    }

    if (!agreeToTerms.value) {
      termsError.value = "You must agree to terms and conditions";
      isValid = false;
    } else {
      termsError.value = null;
    }

    return isValid;
  }

  void register() {
    if (validate()) {
      debugPrint("Registering: ${nameController.text}");
    }
  }

  void loginWithGoogle() {
    debugPrint("Register with Google");
  }

  void goToLogin() {
    Get.offNamed(RouteNames.loginScreen);
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameFocusNode.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
    super.onClose();
  }
}
