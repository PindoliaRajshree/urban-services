// File: lib/features/authentication/login/login_controller.dart
// Purpose: State management and logic for user authentication via
// POST /login — manual (email + password) and Google (google_id + id_token).

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: const ['email']);

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
      loginType: 'manual',
      email: emailController.text.trim(),
      password: passwordController.text,
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

        // Route by role: "set location" is a user-only onboarding step, so
        // providers skip straight to their home dashboard while users go
        // through the address/location screen first.
        if (userRole.value.toLowerCase() == 'provider') {
          Get.offAllNamed(RouteNames.homeMain);
        } else {
          Get.offAllNamed(RouteNames.addressScreen);
        }

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

  /// Signs in with Google, then calls POST /login with `login_type: google`
  /// plus the account id (`google_id`) and auth token (`id_token`) — no
  /// password is sent for this flow. Mirrors RegisterController's Google
  /// flow.
  Future<void> loginWithGoogle() async {
    if (isLoading) return;
    status.value = ApiStatus.loading;

    try {
      // Google caches the last-picked account and will silently re-sign
      // into it on the next call, skipping the account chooser. Sign out
      // first so the picker shows every time, even if the user picked one
      // before.
      await _googleSignIn.signOut();

      final account = await _googleSignIn.signIn();
      if (account == null) {
        // User cancelled the Google sign-in flow.
        status.value = ApiStatus.initial;
        return;
      }

      // Pull the actual auth token from the completed sign-in — prefer the
      // ID token (signed JWT the backend can verify with Google); fall back
      // to the access token if for some reason the ID token isn't returned.
      final GoogleSignInAuthentication auth = await account.authentication;
      final String? googleToken = auth.idToken ?? auth.accessToken;

      if (googleToken == null || googleToken.isEmpty) {
        status.value = ApiStatus.error;
        CustomSnackBar.showError(
          title: "Error",
          message: "Couldn't get Google auth token. Please try again.",
        );
        return;
      }

      final request = LoginRequest(
        loginType: 'google',
        email: account.email,
        googleId: account.id,
        idToken: googleToken,
      );

      final result = await _authRepository.login(request);
      await _handleResult(result);
    } catch (e) {
      status.value = ApiStatus.error;
      debugPrint("Google sign-in error: $e");
      CustomSnackBar.showError(
        title: "Error",
        message: "Google sign-in failed. Please try again.",
      );
    }
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
