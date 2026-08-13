// File: lib/features/authentication/forgot_password/forgot_password_controller.dart
// Purpose: Owns the entire forgot-password flow — send OTP, verify OTP,
// reset password — all three of which call the same POST /forgot-password
// endpoint. A single controller (put permanent on ForgotPasswordScreen, then
// found via Get.find on the OTP and Reset screens) carries the email/OTP
// state across the three screens, the same way LoginController carries the
// selected role across the login/register screens.
//
// Flow is identical for both 'user' and 'provider' accounts — no role is
// involved anywhere here.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urban_services/core/constants/api_status.dart';
import 'package:urban_services/core/services/api_result.dart';
import 'package:urban_services/core/utils/validators.dart';
import 'package:urban_services/features/authentication/forgot_password/models/forgot_password_request.dart';
import 'package:urban_services/features/authentication/register/register_repository.dart';
import 'package:urban_services/routes/route_names.dart';
import 'package:urban_services/widgets/custom_snackbar.dart';

class ForgotPasswordController extends GetxController {
  ForgotPasswordController({AuthRepository? authRepository})
    : _authRepository = authRepository ?? AuthRepository();

  final AuthRepository _authRepository;

  /// Tracks the current /forgot-password call (any step) so the UI can
  /// disable buttons and show a loading state.
  final status = ApiStatus.initial.obs;

  bool get isLoading => status.value == ApiStatus.loading;

  // ---------------------------------------------------------------------
  // Step 1 — email
  // ---------------------------------------------------------------------

  final emailController = TextEditingController();
  final emailFocusNode = FocusNode();
  final emailError = RxnString();

  /// Captured once the OTP has been sent; carried through steps 2 and 3.
  String? _email;

  bool _validateEmail() {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      emailError.value = "Email is required";
      return false;
    }
    if (!AppValidators.isValidEmail(email)) {
      emailError.value = "Please enter a valid email";
      return false;
    }
    emailError.value = null;
    return true;
  }

  /// Step 1 — sends the OTP to the given email.
  Future<void> sendOtp() async {
    if (isLoading) return;
    if (!_validateEmail()) return;

    status.value = ApiStatus.loading;
    final email = emailController.text.trim();

    final result = await _authRepository.forgotPassword(
      ForgotPasswordRequest(email: email),
    );

    switch (result) {
      case ApiSuccess(data: final message):
        status.value = ApiStatus.successful;
        _email = email;
        CustomSnackBar.showSuccess(title: "Success", message: message);
        Get.toNamed(RouteNames.checkEmailScreen);
      case ApiFailure(message: final message):
        status.value = ApiStatus.error;
        CustomSnackBar.showError(title: "Error", message: message);
    }
  }

  // ---------------------------------------------------------------------
  // Step 2 — OTP
  // ---------------------------------------------------------------------

  /// Number of digits in the OTP the backend sends.
  static const int otpLength = 4;

  final List<TextEditingController> otpControllers = List.generate(
    otpLength,
    (_) => TextEditingController(),
  );
  final List<FocusNode> otpFocusNodes = List.generate(
    otpLength,
    (_) => FocusNode(),
  );

  /// Captured once the OTP has been verified; carried through to step 3.
  String? _verifiedOtp;

  /// Handles auto-advance/back between the OTP boxes.
  void onDigitChanged(int index, String value) {
    if (value.isNotEmpty && index < otpControllers.length - 1) {
      otpFocusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      otpFocusNodes[index - 1].requestFocus();
    }
  }

  /// Step 2 — verifies the code against the email from step 1.
  Future<void> verifyOtp() async {
    if (isLoading) return;

    final code = otpControllers.map((c) => c.text).join();
    if (code.length != otpLength) {
      CustomSnackBar.showError(
        title: "Error",
        message: "Please enter the full $otpLength-digit code",
        position: SnackPosition.BOTTOM,
      );
      return;
    }

    final email = _email;
    if (email == null) {
      // Guards against a user deep-linking straight into this screen.
      CustomSnackBar.showError(
        title: "Error",
        message: "Please request a new code first.",
      );
      Get.offNamed(RouteNames.forgotPasswordScreen);
      return;
    }

    status.value = ApiStatus.loading;

    final result = await _authRepository.forgotPassword(
      ForgotPasswordRequest(email: email, otp: code),
    );

    switch (result) {
      case ApiSuccess(data: final message):
        status.value = ApiStatus.successful;
        _verifiedOtp = code;
        CustomSnackBar.showSuccess(title: "Success", message: message);
        Get.toNamed(RouteNames.resetPasswordScreen);
      case ApiFailure(message: final message):
        status.value = ApiStatus.error;
        CustomSnackBar.showError(title: "Invalid Code", message: message);
    }
  }

  /// Resends the OTP for the email captured in step 1.
  Future<void> resendCode() async {
    if (isLoading) return;

    final email = _email;
    if (email == null) return;

    status.value = ApiStatus.loading;

    final result = await _authRepository.forgotPassword(
      ForgotPasswordRequest(email: email),
    );

    switch (result) {
      case ApiSuccess(data: final message):
        status.value = ApiStatus.successful;
        CustomSnackBar.showSuccess(title: "Code Sent", message: message);
      case ApiFailure(message: final message):
        status.value = ApiStatus.error;
        CustomSnackBar.showError(title: "Error", message: message);
    }
  }

  // ---------------------------------------------------------------------
  // Step 3 — reset password
  // ---------------------------------------------------------------------

  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final passwordFocus = FocusNode();
  final confirmPasswordFocus = FocusNode();

  final obscurePassword = true.obs;
  final obscureConfirmPassword = true.obs;

  final passwordError = RxnString();
  final confirmPasswordError = RxnString();

  void togglePasswordVisibility() =>
      obscurePassword.value = !obscurePassword.value;

  void toggleConfirmPasswordVisibility() =>
      obscureConfirmPassword.value = !obscureConfirmPassword.value;

  bool _validateNewPassword() {
    bool isValid = true;

    if (passwordController.text.isEmpty) {
      passwordError.value = "Password is required";
      isValid = false;
    } else if (passwordController.text.length < 8) {
      passwordError.value = "Password must be at least 8 characters";
      isValid = false;
    } else {
      passwordError.value = null;
    }

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

  /// Step 3 — sets the new password, then returns to Login on success.
  Future<void> updatePassword() async {
    if (isLoading) return;
    if (!_validateNewPassword()) return;

    final email = _email;
    if (email == null) {
      CustomSnackBar.showError(
        title: "Error",
        message: "Session expired. Please start again.",
      );
      Get.offAllNamed(RouteNames.forgotPasswordScreen);
      return;
    }

    status.value = ApiStatus.loading;

    final result = await _authRepository.forgotPassword(
      ForgotPasswordRequest(
        email: email,
        otp: _verifiedOtp,
        password: passwordController.text,
        passwordConfirmation: confirmPasswordController.text,
      ),
    );

    switch (result) {
      case ApiSuccess(data: final message):
        status.value = ApiStatus.successful;
        CustomSnackBar.showSuccess(title: "Success", message: message);
        _resetFlow();
        Get.offAllNamed(RouteNames.loginScreen);
      case ApiFailure(message: final message):
        status.value = ApiStatus.error;
        CustomSnackBar.showError(title: "Error", message: message);
    }
  }

  /// Clears every field and the captured email/OTP so a stale session
  /// can't leak into the next time this flow is started.
  void _resetFlow() {
    emailController.clear();
    for (final c in otpControllers) {
      c.clear();
    }
    passwordController.clear();
    confirmPasswordController.clear();

    emailError.value = null;
    passwordError.value = null;
    confirmPasswordError.value = null;

    _email = null;
    _verifiedOtp = null;
  }

  @override
  void onClose() {
    emailController.dispose();
    emailFocusNode.dispose();
    for (final c in otpControllers) {
      c.dispose();
    }
    for (final n in otpFocusNodes) {
      n.dispose();
    }
    passwordController.dispose();
    confirmPasswordController.dispose();
    passwordFocus.dispose();
    confirmPasswordFocus.dispose();
    super.onClose();
  }
}
