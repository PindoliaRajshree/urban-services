import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:urban_services/core/constants/api_status.dart';
import 'package:urban_services/core/constants/storage_keys.dart';
import 'package:urban_services/core/services/api_result.dart';
import 'package:urban_services/core/utils/validators.dart';
import 'package:urban_services/features/authentication/login/login_controller.dart';
import 'package:urban_services/features/authentication/register/models/register_request.dart';
import 'package:urban_services/features/authentication/register/models/register_response.dart';
import 'package:urban_services/features/authentication/register/register_repository.dart';
import 'package:urban_services/routes/route_names.dart';
import 'package:urban_services/shared_preferences/sharedpreference_helper.dart';
import 'package:urban_services/widgets/custom_snackbar.dart';

class RegisterController extends GetxController {
  RegisterController({AuthRepository? authRepository})
    : _authRepository = authRepository ?? AuthRepository();

  final AuthRepository _authRepository;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: const ['email']);

  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final nameFocusNode = FocusNode();
  final mobileFocusNode = FocusNode();
  final emailFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();
  final confirmPasswordFocusNode = FocusNode();

  final nameError = RxnString();
  final mobileError = RxnString();
  final emailError = RxnString();
  final passwordError = RxnString();
  final confirmPasswordError = RxnString();
  final termsError = RxnString();

  final agreeToTerms = false.obs;

  /// Tracks the current /register call so the UI can disable buttons and
  /// show a loading state.
  final status = ApiStatus.initial.obs;

  bool get isLoading => status.value == ApiStatus.loading;

  /// The role ('user' or 'provider') is chosen on the Welcome screen and
  /// stored on the shared, permanent LoginController. Registration reuses
  /// it rather than asking again.
  String get _role {
    if (Get.isRegistered<LoginController>()) {
      return Get.find<LoginController>().userRole.value.toLowerCase();
    }
    return 'user';
  }

  bool validate() {
    bool isValid = true;

    if (nameController.text.trim().isEmpty) {
      nameError.value = "Name is required";
      isValid = false;
    } else {
      nameError.value = null;
    }

    if (mobileController.text.trim().isEmpty) {
      mobileError.value = "Mobile number is required";
      isValid = false;
    } else if (mobileController.text.trim().length != 10) {
      mobileError.value = "Please enter a valid 10-digit mobile number";
      isValid = false;
    } else {
      mobileError.value = null;
    }

    if (emailController.text.trim().isEmpty) {
      emailError.value = "Email is required";
      isValid = false;
    } else if (!AppValidators.isValidEmail(emailController.text)) {
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
      final hasSpecialCharacters = password.contains(
        RegExp(r'[!@#$%^&*(),.?":{}|<>]'),
      );
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

  /// Manual registration: name, mobile, email (optional), password.
  Future<void> register() async {
    if (isLoading) return;
    if (!validate()) return;

    status.value = ApiStatus.loading;

    final request = RegisterRequest(
      loginType: 'manual',
      role: _role,
      name: nameController.text.trim(),
      mobile: mobileController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text,
    );

    final result = await _authRepository.register(request);
    await _handleResult(result, isGoogle: false);
  }

  /// Google registration/login: sign in with Google, then pass both the
  /// account id (`google_id`) and the auth token (`id_token`) to /register.
  /// name/email are passed along when Google provides them.
  Future<void> loginWithGoogle() async {
    if (isLoading) return;
    status.value = ApiStatus.loading;

    try {
      // Google caches the last-picked account and will silently re-sign
      // into it on the next call, skipping the account chooser. Sign out
      // first so the picker (with "Add account" / other Gmail options)
      // shows every time, even if the user picked one before.
      await _googleSignIn.signOut();

      final account = await _googleSignIn.signIn();
      if (account == null) {
        // User cancelled the Google sign-in flow.
        status.value = ApiStatus.initial;
        return;
      }

      // Pull the actual auth token from the completed sign-in — prefer the
      // ID token (signed JWT the backend can verify with Google); fall
      // back to the access token if for some reason the ID token isn't
      // returned.
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

      final request = RegisterRequest(
        loginType: 'google',
        role: _role,
        name: account.displayName,
        email: account.email,
        googleId: account.id,
        idToken: googleToken,
      );

      final result = await _authRepository.register(request);
      await _handleResult(result, isGoogle: true);
    } catch (e) {
      status.value = ApiStatus.error;
      debugPrint("Google sign-in error: $e");
      CustomSnackBar.showError(
        title: "Error",
        message: "Google sign-in failed. Please try again.",
      );
    }
  }

  Future<void> _handleResult(
    ApiResult<RegisterResponse> result, {
    required bool isGoogle,
  }) async {
    switch (result) {
      case ApiSuccess(data: final data):
        status.value = ApiStatus.successful;

        if (data.token != null && data.token!.isNotEmpty) {
          await SharedPreferencesHelper.instance.setValue(
            StorageKeys.authToken,
            data.token!,
          );
        }
        await SharedPreferencesHelper.instance.setValue(
          StorageKeys.userRole,
          data.role ?? _role,
        );

        CustomSnackBar.showSuccess(
          title: "Success",
          message: data.message ?? "Registered successfully",
        );

        _clearForm();

        if (isGoogle) {
          // Google sign-up doubles as sign-in — take the user straight in.
          // "set location" is a user-only step, so providers skip it and go
          // straight to their home dashboard.
          if (_role == 'provider') {
            Get.offAllNamed(RouteNames.homeMain);
          } else {
            Get.offAllNamed(RouteNames.addressScreen);
          }
        } else {
          Get.offNamed(RouteNames.loginScreen);
        }

      case ApiFailure(message: final message):
        status.value = ApiStatus.error;
        CustomSnackBar.showError(title: "Registration Failed", message: message);
    }
  }

  /// Resets every input field and validation error back to a blank state.
  /// Called after a successful register so the form doesn't carry stale
  /// values into the next screen/attempt.
  void _clearForm() {
    nameController.clear();
    mobileController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();

    nameError.value = null;
    mobileError.value = null;
    emailError.value = null;
    passwordError.value = null;
    confirmPasswordError.value = null;
    termsError.value = null;

    agreeToTerms.value = false;
  }

  void goToLogin() {
    Get.offNamed(RouteNames.loginScreen);
  }

  @override
  void onClose() {
    nameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameFocusNode.dispose();
    mobileFocusNode.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
    super.onClose();
  }
}
