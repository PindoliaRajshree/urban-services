// File: lib/features/authentication/login/login_controller.dart
// Purpose: State management and logic for user authentication via
// POST /login (email + password). Google login isn't available yet.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urban_services/core/constants/api_status.dart';
import 'package:urban_services/core/constants/storage_keys.dart';
import 'package:urban_services/core/services/api_result.dart';
import 'package:urban_services/core/utils/validators.dart';
import 'package:urban_services/features/authentication/login/models/login_request.dart';
import 'package:urban_services/features/authentication/login/models/login_response.dart';
import 'package:urban_services/features/authentication/register/register_repository.dart';
import 'package:urban_services/routes/route_names.dart';
import 'package:urban_services/shared_preferences/sharedpreference_helper.dart';
import 'package:urban_services/widgets/custom_snackbar.dart';

class LoginController extends GetxController {
  LoginController({AuthRepository? authRepository})
    : _authRepository = authRepository ?? AuthRepository();

  final AuthRepository _authRepository;

  // Input controllers for email and password
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Focus nodes for managing input focus flow
  final emailFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();

  // Reactive error strings for real-time validation feedback
  final emailError = RxnString();
  final passwordError = RxnString();

  // Track the selected user role (User or Provider) to determine post-login navigation
  final userRole = 'User'.obs;

  /// Tracks the current /login call so the UI can disable buttons and show
  /// a loading state.
  final status = ApiStatus.initial.obs;

  bool get isLoading => status.value == ApiStatus.loading;

  /// Sets the current user role based on the welcome screen selection
  void setRole(String role) {
    userRole.value = role;
  }

  /// Validates the login form fields
  bool validate() {
    bool isValid = true;

    if (emailController.text.trim().isEmpty) {
      emailError.value = "Email is required";
      isValid = false;
    } else if (!AppValidators.isValidEmail(emailController.text)) {
      emailError.value = "Please enter a valid email";
      isValid = false;
    } else {
      emailError.value = null;
    }

    if (passwordController.text.isEmpty) {
      passwordError.value = "Password is required";
      isValid = false;
    } else {
      passwordError.value = null;
    }

    return isValid;
  }

  /// Performs the login action against POST /login.
  Future<void> login() async {
    if (isLoading) return;
    if (!validate()) return;

    status.value = ApiStatus.loading;

    final request = LoginRequest(
      email: emailController.text.trim(),
      password: passwordController.text,
      loginType: 'manual',
    );

    final result = await _authRepository.login(request);
    await _handleResult(result);
  }

  Future<void> _handleResult(ApiResult<LoginResponse> result) async {
    switch (result) {
      case ApiSuccess(data: final data):
        status.value = ApiStatus.successful;

        if (data.token != null && data.token!.isNotEmpty) {
          await SharedPreferencesHelper.instance.setValue(
            StorageKeys.authToken,
            data.token!,
          );
        }

        final user = data.user;
        if (user != null) {
          if (user.id != null) {
            await SharedPreferencesHelper.instance.setValue(
              StorageKeys.userId,
              user.id!,
            );
          }
          if (user.name != null) {
            await SharedPreferencesHelper.instance.setValue(
              StorageKeys.userName,
              user.name!,
            );
          }
          if (user.email != null) {
            await SharedPreferencesHelper.instance.setValue(
              StorageKeys.userEmail,
              user.email!,
            );
          }
          if (user.mobile != null) {
            await SharedPreferencesHelper.instance.setValue(
              StorageKeys.userMobile,
              user.mobile!,
            );
          }
          if (user.role != null) {
            userRole.value = user.role!;
            await SharedPreferencesHelper.instance.setValue(
              StorageKeys.userRole,
              user.role!,
            );
          }
        }

        CustomSnackBar.showSuccess(
          title: "Success",
          message: data.message ?? "Login successful",
        );

        _clearForm();

        Get.offAllNamed(RouteNames.addressScreen);

      case ApiFailure(message: final message):
        status.value = ApiStatus.error;
        CustomSnackBar.showError(title: "Login Failed", message: message);
    }
  }

  /// Resets the input fields and validation errors back to a blank state.
  /// Called after a successful login so stale credentials don't linger if
  /// the user ever lands back on this screen.
  void _clearForm() {
    emailController.clear();
    passwordController.clear();
    emailError.value = null;
    passwordError.value = null;
  }

  /// Google login isn't available yet.
  void loginWithGoogle() {
    CustomSnackBar.showInfo(
      title: "Coming Soon",
      message: "Google login isn't available yet.",
    );
  }

  @override
  void onClose() {
    // Standard cleanup to prevent memory leaks
    emailController.dispose();
    passwordController.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    super.onClose();
  }
}
