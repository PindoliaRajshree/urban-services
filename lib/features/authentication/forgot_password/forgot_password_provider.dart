// File: lib/features/authentication/forgot_password/forgot_password_provider.dart
// Purpose: Owns the entire forgot-password flow — send OTP, verify OTP,
// reset password — all three of which call the same POST /forgot-password
// endpoint, plus resend OTP (POST /resend-otp) with a 30s cooldown and a
// 2-resend cap. One provider carries the email/OTP state across the three
// screens (ForgotPassword → CheckEmail → ResetPassword). It is autoDispose,
// so it lives while any of those screens is on the stack and starts fresh
// the next time the flow is opened.
//
// Flow is identical for both 'user' and 'provider' accounts — no role is
// involved anywhere here.

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_services/core/constants/api_status.dart';
import 'package:urban_services/core/network/api_result.dart';
import 'package:urban_services/core/utils/password_validator.dart';
import 'package:urban_services/core/utils/validators.dart';
import 'package:urban_services/features/authentication/forgot_password/models/forgot_password_request.dart';
import 'package:urban_services/features/authentication/forgot_password/models/resend_otp_request.dart';
import 'package:urban_services/features/authentication/register/register_repository.dart';
import 'package:urban_services/routes/app_router.dart';
import 'package:urban_services/routes/route_names.dart';
import 'package:urban_services/widgets/custom_snackbar.dart';

class ForgotPasswordState {
  const ForgotPasswordState({
    this.status = ApiStatus.initial,
    this.email,
    this.verifiedOtp,
    this.emailError,
    this.resendSecondsRemaining = 0,
    this.resendAttempts = 0,
    this.passwordError,
    this.confirmPasswordError,
    this.obscurePassword = true,
    this.obscureConfirmPassword = true,
  });

  /// Tracks the current /forgot-password call (any step) so the UI can
  /// disable buttons and show a loading state.
  final ApiStatus status;

  /// Captured once the OTP has been sent; carried through steps 2 and 3.
  final String? email;

  /// Captured once the OTP has been verified; carried through to step 3.
  final String? verifiedOtp;

  final String? emailError;
  final int resendSecondsRemaining;
  final int resendAttempts;
  final String? passwordError;
  final String? confirmPasswordError;
  final bool obscurePassword;
  final bool obscureConfirmPassword;

  bool get isLoading => status == ApiStatus.loading;

  /// True once the user has used up all resends.
  bool get resendLimitReached =>
      resendAttempts >= ForgotPasswordNotifier.maxResendAttempts;

  ForgotPasswordState copyWith({
    ApiStatus? status,
    String? Function()? email,
    String? Function()? verifiedOtp,
    String? Function()? emailError,
    int? resendSecondsRemaining,
    int? resendAttempts,
    String? Function()? passwordError,
    String? Function()? confirmPasswordError,
    bool? obscurePassword,
    bool? obscureConfirmPassword,
  }) => ForgotPasswordState(
    status: status ?? this.status,
    email: email != null ? email() : this.email,
    verifiedOtp: verifiedOtp != null ? verifiedOtp() : this.verifiedOtp,
    emailError: emailError != null ? emailError() : this.emailError,
    resendSecondsRemaining:
        resendSecondsRemaining ?? this.resendSecondsRemaining,
    resendAttempts: resendAttempts ?? this.resendAttempts,
    passwordError: passwordError != null ? passwordError() : this.passwordError,
    confirmPasswordError: confirmPasswordError != null
        ? confirmPasswordError()
        : this.confirmPasswordError,
    obscurePassword: obscurePassword ?? this.obscurePassword,
    obscureConfirmPassword:
        obscureConfirmPassword ?? this.obscureConfirmPassword,
  );
}

class ForgotPasswordNotifier extends Notifier<ForgotPasswordState> {
  /// Number of digits in the OTP the backend sends.
  static const int otpLength = 4;

  /// Seconds to wait before "Resend code" becomes tappable again. Restarts
  /// after the OTP is first sent (step 1) and after every successful resend.
  static const int resendCooldownSeconds = 30;

  /// Resend is capped at [maxResendAttempts] per flow. The attempt beyond
  /// that is blocked client-side with a "try again later" message instead
  /// of hitting the API.
  static const int maxResendAttempts = 2;

  Timer? _resendTimer;

  AuthRepository get _authRepository => ref.read(authRepositoryProvider);

  @override
  ForgotPasswordState build() {
    ref.onDispose(() => _resendTimer?.cancel());
    return const ForgotPasswordState();
  }

  // ---------------------------------------------------------------------
  // Step 1 — email
  // ---------------------------------------------------------------------

  bool _validateEmail(String email) {
    String? error;
    if (email.isEmpty) {
      error = "Email is required";
    } else if (!AppValidators.isValidEmail(email)) {
      error = "Please enter a valid email";
    }
    state = state.copyWith(emailError: () => error);
    return error == null;
  }

  /// Step 1 — sends the OTP to the given email.
  Future<void> sendOtp(String rawEmail) async {
    if (state.isLoading) return;
    final email = rawEmail.trim();
    if (!_validateEmail(email)) return;

    state = state.copyWith(status: ApiStatus.loading);

    final result = await _authRepository.forgotPassword(
      ForgotPasswordRequest(email: email),
    );
    if (!ref.mounted) return;

    switch (result) {
      case ApiSuccess(data: final message):
        state = state.copyWith(
          status: ApiStatus.successful,
          email: () => email,
          resendAttempts: 0,
        );
        _startResendCooldown();
        CustomSnackBar.showSuccess(title: "Success", message: message);
        ref.read(routerProvider).push(RouteNames.checkEmailScreen);
      case ApiError(failure: final failure):
        state = state.copyWith(status: ApiStatus.error);
        CustomSnackBar.showError(title: "Error", message: failure.message);
    }
  }

  // ---------------------------------------------------------------------
  // Step 2 — OTP
  // ---------------------------------------------------------------------

  /// Step 2 — verifies the code against the email from step 1. Returns
  /// false when the code was rejected, so the screen can clear the boxes.
  Future<bool> verifyOtp(String code) async {
    if (state.isLoading) return true;

    if (code.length != otpLength) {
      CustomSnackBar.showError(
        title: "Error",
        message: "Please enter the full $otpLength-digit code",
        position: SnackPosition.bottom,
      );
      return true;
    }

    final email = state.email;
    if (email == null) {
      // Guards against a user deep-linking straight into this screen.
      CustomSnackBar.showError(
        title: "Error",
        message: "Please request a new code first.",
      );
      ref.read(routerProvider).pushReplacement(RouteNames.forgotPasswordScreen);
      return true;
    }

    state = state.copyWith(status: ApiStatus.loading);

    final result = await _authRepository.forgotPassword(
      ForgotPasswordRequest(email: email, otp: code),
    );
    if (!ref.mounted) return true;

    switch (result) {
      case ApiSuccess(data: final message):
        state = state.copyWith(
          status: ApiStatus.successful,
          verifiedOtp: () => code,
        );
        CustomSnackBar.showSuccess(title: "Success", message: message);
        ref.read(routerProvider).push(RouteNames.resetPasswordScreen);
        return true;
      case ApiError(failure: final failure):
        state = state.copyWith(status: ApiStatus.error);
        CustomSnackBar.showError(
          title: "Invalid Code",
          message: failure.message,
        );
        return false;
    }
  }

  // ---------------------------------------------------------------------
  // Resend OTP — 30s cooldown after every send, capped at 2 resends
  // ---------------------------------------------------------------------

  void _startResendCooldown() {
    _resendTimer?.cancel();
    state = state.copyWith(resendSecondsRemaining: resendCooldownSeconds);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final remaining = state.resendSecondsRemaining;
      if (remaining <= 1) {
        state = state.copyWith(resendSecondsRemaining: 0);
        timer.cancel();
      } else {
        state = state.copyWith(resendSecondsRemaining: remaining - 1);
      }
    });
  }

  /// Resends the OTP for the email captured in step 1 by calling
  /// POST /resend-otp. Gated by the 30s cooldown (UI disables the tap
  /// target while it's running, this is a belt-and-braces guard) and by
  /// [maxResendAttempts] — once reached, the user is told to try later
  /// instead of another request going out.
  Future<void> resendCode() async {
    if (state.isLoading) return;
    if (state.resendSecondsRemaining > 0) return;

    final email = state.email;
    if (email == null) return;

    if (state.resendLimitReached) {
      CustomSnackBar.showWarning(
        title: "Please try again later",
        message:
            "You've reached the maximum number of resend attempts. "
            "Please try again after some time.",
      );
      return;
    }

    state = state.copyWith(status: ApiStatus.loading);

    final result = await _authRepository.resendOtp(
      ResendOtpRequest(email: email),
    );
    if (!ref.mounted) return;

    switch (result) {
      case ApiSuccess(data: final message):
        state = state.copyWith(
          status: ApiStatus.successful,
          resendAttempts: state.resendAttempts + 1,
        );
        _startResendCooldown();
        CustomSnackBar.showSuccess(title: "Code Sent", message: message);
      case ApiError(failure: final failure):
        state = state.copyWith(status: ApiStatus.error);
        CustomSnackBar.showError(title: "Error", message: failure.message);
    }
  }

  // ---------------------------------------------------------------------
  // Step 3 — reset password
  // ---------------------------------------------------------------------

  void togglePasswordVisibility() =>
      state = state.copyWith(obscurePassword: !state.obscurePassword);

  void toggleConfirmPasswordVisibility() => state = state.copyWith(
    obscureConfirmPassword: !state.obscureConfirmPassword,
  );

  bool _validateNewPassword(String password, String confirmPassword) {
    // Same rules as sign-up.
    final passwordError = PasswordValidator.getPasswordError(password);
    String? confirmPasswordError;

    if (confirmPassword.isEmpty) {
      confirmPasswordError = "Please confirm your password";
    } else if (confirmPassword != password) {
      confirmPasswordError = "Passwords do not match";
    }

    state = state.copyWith(
      passwordError: () => passwordError,
      confirmPasswordError: () => confirmPasswordError,
    );
    return passwordError == null && confirmPasswordError == null;
  }

  /// Step 3 — sets the new password, then returns to Login on success.
  Future<void> updatePassword({
    required String password,
    required String confirmPassword,
  }) async {
    if (state.isLoading) return;
    if (!_validateNewPassword(password, confirmPassword)) return;

    final router = ref.read(routerProvider);
    final email = state.email;
    if (email == null) {
      CustomSnackBar.showError(
        title: "Error",
        message: "Session expired. Please start again.",
      );
      router.go(RouteNames.forgotPasswordScreen);
      return;
    }

    state = state.copyWith(status: ApiStatus.loading);

    final result = await _authRepository.forgotPassword(
      ForgotPasswordRequest(
        email: email,
        otp: state.verifiedOtp,
        password: password,
        passwordConfirmation: confirmPassword,
      ),
    );
    if (!ref.mounted) return;

    switch (result) {
      case ApiSuccess(data: final message):
        _resendTimer?.cancel();
        state = const ForgotPasswordState(status: ApiStatus.successful);
        CustomSnackBar.showSuccess(title: "Success", message: message);
        // Back to Login with Welcome underneath (a plain go(login) would
        // leave Login as the only screen).
        router.go(RouteNames.welcomeScreen);
        router.push(RouteNames.loginScreen);
      case ApiError(failure: final failure):
        state = state.copyWith(status: ApiStatus.error);
        CustomSnackBar.showError(title: "Error", message: failure.message);
    }
  }
}

final forgotPasswordProvider =
    NotifierProvider.autoDispose<ForgotPasswordNotifier, ForgotPasswordState>(
      ForgotPasswordNotifier.new,
    );
