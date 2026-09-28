// File: lib/features/authentication/register/register_provider.dart
// Purpose: State management and logic for registration via POST /register
// — manual (name, mobile, email, password) and Google (google_id + id_token).

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:urban_services/core/constants/api_status.dart';
import 'package:urban_services/core/network/api_result.dart';
import 'package:urban_services/core/session/session_provider.dart';
import 'package:urban_services/core/session/user_role.dart';
import 'package:urban_services/core/utils/password_validator.dart';
import 'package:urban_services/core/utils/validators.dart';
import 'package:urban_services/features/authentication/register/models/register_request.dart';
import 'package:urban_services/features/authentication/register/models/register_response.dart';
import 'package:urban_services/features/authentication/register/register_repository.dart';
import 'package:urban_services/routes/app_router.dart';
import 'package:urban_services/routes/route_names.dart';
import 'package:urban_services/widgets/custom_snackbar.dart';

/// Raw form values, read from the screen's TextEditingControllers.
class RegisterForm {
  const RegisterForm({
    required this.name,
    required this.mobile,
    required this.email,
    required this.password,
    required this.confirmPassword,
  });

  final String name;
  final String mobile;
  final String email;
  final String password;
  final String confirmPassword;
}

class RegisterState {
  const RegisterState({
    this.nameError,
    this.mobileError,
    this.emailError,
    this.passwordError,
    this.confirmPasswordError,
    this.termsError,
    this.agreeToTerms = false,
    this.status = ApiStatus.initial,
    this.googleInProgress = false,
  });

  final String? nameError;
  final String? mobileError;
  final String? emailError;
  final String? passwordError;
  final String? confirmPasswordError;
  final String? termsError;
  final bool agreeToTerms;

  /// Tracks the current /register call so the UI can disable buttons and
  /// show a loading state.
  final ApiStatus status;

  /// Whether the running request is the Google flow (vs the form), so only
  /// the tapped button shows a spinner.
  final bool googleInProgress;

  bool get isLoading => status == ApiStatus.loading;
  bool get isFormLoading => isLoading && !googleInProgress;
  bool get isGoogleLoading => isLoading && googleInProgress;

  RegisterState copyWith({
    bool? agreeToTerms,
    ApiStatus? status,
    bool? googleInProgress,
  }) => RegisterState(
    nameError: nameError,
    mobileError: mobileError,
    emailError: emailError,
    passwordError: passwordError,
    confirmPasswordError: confirmPasswordError,
    termsError: termsError,
    agreeToTerms: agreeToTerms ?? this.agreeToTerms,
    status: status ?? this.status,
    googleInProgress: googleInProgress ?? this.googleInProgress,
  );
}

class RegisterNotifier extends Notifier<RegisterState> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: const ['email']);

  AuthRepository get _authRepository => ref.read(authRepositoryProvider);

  /// The role ('user' or 'provider') is chosen on the Welcome screen and
  /// stored on the session. Registration reuses it rather than asking again.
  String get _role => ref.read(sessionProvider).selectedRole.apiValue;

  @override
  RegisterState build() => const RegisterState();

  void setAgreeToTerms(bool value) {
    state = state.copyWith(agreeToTerms: value);
  }

  bool validate(RegisterForm form) {
    String? nameError;
    String? mobileError;
    String? emailError;
    String? passwordError;
    String? confirmPasswordError;
    String? termsError;

    if (form.name.trim().isEmpty) {
      nameError = "Name is required";
    }

    if (form.mobile.trim().isEmpty) {
      mobileError = "Mobile number is required";
    } else if (form.mobile.trim().length != 10) {
      mobileError = "Please enter a valid 10-digit mobile number";
    }

    if (form.email.trim().isEmpty) {
      emailError = "Email is required";
    } else if (!AppValidators.isValidEmail(form.email)) {
      emailError = "Please enter a valid email";
    }

    // Same rules as the password reset screen.
    passwordError = PasswordValidator.getPasswordError(form.password);

    if (form.confirmPassword != form.password) {
      confirmPasswordError = "Passwords do not match";
    }

    if (!state.agreeToTerms) {
      termsError = "You must agree to terms and conditions";
    }

    state = RegisterState(
      nameError: nameError,
      mobileError: mobileError,
      emailError: emailError,
      passwordError: passwordError,
      confirmPasswordError: confirmPasswordError,
      termsError: termsError,
      agreeToTerms: state.agreeToTerms,
      status: state.status,
    );

    return nameError == null &&
        mobileError == null &&
        emailError == null &&
        passwordError == null &&
        confirmPasswordError == null &&
        termsError == null;
  }

  /// Manual registration: name, mobile, email, password.
  Future<void> register(RegisterForm form) async {
    if (state.isLoading) return;
    if (!validate(form)) return;

    state = state.copyWith(status: ApiStatus.loading, googleInProgress: false);

    final request = RegisterRequest(
      loginType: 'manual',
      role: _role,
      name: form.name.trim(),
      mobile: form.mobile.trim(),
      email: form.email.trim(),
      password: form.password,
    );

    final result = await _authRepository.register(request);
    await _handleResult(result, isGoogle: false);
  }

  /// Google registration/login: sign in with Google, then pass both the
  /// account id (`google_id`) and the auth token (`id_token`) to /register.
  /// name/email are passed along when Google provides them.
  Future<void> loginWithGoogle() async {
    if (state.isLoading) return;
    state = state.copyWith(status: ApiStatus.loading, googleInProgress: true);

    try {
      // Google caches the last-picked account and will silently re-sign
      // into it on the next call, skipping the account chooser. Sign out
      // first so the picker (with "Add account" / other Gmail options)
      // shows every time, even if the user picked one before.
      await _googleSignIn.signOut();

      final account = await _googleSignIn.signIn();
      if (!ref.mounted) return;
      if (account == null) {
        // User cancelled the Google sign-in flow.
        state = state.copyWith(status: ApiStatus.initial);
        return;
      }

      // Pull the actual auth token from the completed sign-in — prefer the
      // ID token (signed JWT the backend can verify with Google); fall
      // back to the access token if for some reason the ID token isn't
      // returned.
      final GoogleSignInAuthentication auth = await account.authentication;
      final String? googleToken = auth.idToken ?? auth.accessToken;
      if (!ref.mounted) return;

      if (googleToken == null || googleToken.isEmpty) {
        state = state.copyWith(status: ApiStatus.error);
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
      debugPrint("Google sign-in error: $e");
      if (!ref.mounted) return;
      state = state.copyWith(status: ApiStatus.error);
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
        final router = ref.read(routerProvider);

        if (!isGoogle) {
          // Manual sign-up doesn't log the user in: nothing is stored, and
          // they sign in on the Login screen with the new credentials.
          state = const RegisterState(status: ApiStatus.successful);
          CustomSnackBar.showSuccess(
            title: "Success",
            message: data.message ?? "Registered successfully",
          );
          // Back to the Login screen underneath, not a second copy of it.
          if (router.canPop()) {
            router.pop();
          } else {
            router.go(RouteNames.loginScreen);
          }
          return;
        }

        // Google sign-up doubles as sign-in, so store the full session.
        // Read the picked role first: saving resets it to the stored role.
        final pickedRole = ref.read(sessionProvider).selectedRole;
        final saved = await ref
            .read(sessionProvider.notifier)
            .saveRegister(data);
        if (!ref.mounted) return;

        if (!saved) {
          state = state.copyWith(status: ApiStatus.error);
          CustomSnackBar.showError(
            title: "Registration Failed",
            message:
                "Sign-up succeeded but no session was returned. Please log in.",
          );
          return;
        }

        // Decided while the button still shows loading.
        final route = await postLoginRoute(ref);
        if (!ref.mounted) return;

        state = const RegisterState(status: ApiStatus.successful);
        final mismatch = roleMismatchMessage(
          pickedRole,
          ref.read(sessionProvider).role,
        );
        if (mismatch != null) {
          CustomSnackBar.showInfo(title: "Signed in", message: mismatch);
        } else {
          CustomSnackBar.showSuccess(
            title: "Success",
            message: data.message ?? "Registered successfully",
          );
        }

        router.go(route);

      case ApiError(failure: final failure):
        if (!ref.mounted) return;
        state = state.copyWith(status: ApiStatus.error);
        CustomSnackBar.showError(
          title: "Registration Failed",
          message: failure.message,
        );
    }
  }
}

final registerProvider =
    NotifierProvider.autoDispose<RegisterNotifier, RegisterState>(
      RegisterNotifier.new,
    );
