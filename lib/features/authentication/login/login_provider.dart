// File: lib/features/authentication/login/login_provider.dart
// Purpose: State management and logic for user authentication via
// POST /login — manual (email + password) and Google (google_id + id_token).

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:urban_services/core/constants/api_status.dart';
import 'package:urban_services/core/network/api_result.dart';
import 'package:urban_services/core/session/session_provider.dart';
import 'package:urban_services/core/session/user_role.dart';
import 'package:urban_services/core/utils/validators.dart';
import 'package:urban_services/features/authentication/login/models/login_request.dart';
import 'package:urban_services/features/authentication/login/models/login_response.dart';
import 'package:urban_services/features/authentication/register/register_repository.dart';
import 'package:urban_services/routes/app_router.dart';
import 'package:urban_services/widgets/custom_snackbar.dart';

class LoginState {
  const LoginState({
    this.emailError,
    this.passwordError,
    this.status = ApiStatus.initial,
  });

  final String? emailError;
  final String? passwordError;

  /// Tracks the current /login call so the UI can disable buttons and show
  /// a loading state.
  final ApiStatus status;

  bool get isLoading => status == ApiStatus.loading;

  LoginState copyWith({
    String? Function()? emailError,
    String? Function()? passwordError,
    ApiStatus? status,
  }) => LoginState(
    emailError: emailError != null ? emailError() : this.emailError,
    passwordError: passwordError != null ? passwordError() : this.passwordError,
    status: status ?? this.status,
  );
}

class LoginNotifier extends Notifier<LoginState> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: const ['email']);

  AuthRepository get _authRepository => ref.read(authRepositoryProvider);

  @override
  LoginState build() => const LoginState();

  /// Validates the login form fields
  bool validate({required String email, required String password}) {
    String? emailError;
    String? passwordError;

    if (email.trim().isEmpty) {
      emailError = "Email is required";
    } else if (!AppValidators.isValidEmail(email)) {
      emailError = "Please enter a valid email";
    }

    if (password.isEmpty) {
      passwordError = "Password is required";
    }

    state = state.copyWith(
      emailError: () => emailError,
      passwordError: () => passwordError,
    );
    return emailError == null && passwordError == null;
  }

  /// Performs the login action against POST /login.
  Future<void> login({required String email, required String password}) async {
    if (state.isLoading) return;
    if (!validate(email: email, password: password)) return;

    state = state.copyWith(status: ApiStatus.loading);

    final request = LoginRequest(
      loginType: 'manual',
      email: email.trim(),
      password: password,
    );

    final result = await _authRepository.login(request);
    await _handleResult(result);
  }

  Future<void> _handleResult(ApiResult<LoginResponse> result) async {
    switch (result) {
      case ApiSuccess(data: final data):
        // Read before saving: saveLogin resets selectedRole to the stored
        // role.
        final pickedRole = ref.read(sessionProvider).selectedRole;
        final session = ref.read(sessionProvider.notifier);
        final saved = await session.saveLogin(data);
        if (!ref.mounted) return;

        if (!saved) {
          state = state.copyWith(status: ApiStatus.error);
          CustomSnackBar.showError(
            title: "Login Failed",
            message: "No session token was received. Please try again.",
          );
          return;
        }

        // Decided while the button still shows loading: users with a saved
        // address go straight to Home.
        final route = await postLoginRoute(ref);
        if (!ref.mounted) return;

        state = const LoginState(status: ApiStatus.successful);

        final mismatch = roleMismatchMessage(
          pickedRole,
          ref.read(sessionProvider).role,
        );
        if (mismatch != null) {
          CustomSnackBar.showInfo(title: "Logged in", message: mismatch);
        } else {
          CustomSnackBar.showSuccess(
            title: "Success",
            message: data.message ?? "Login successful",
          );
        }

        ref.read(routerProvider).go(route);

      case ApiError(failure: final failure):
        if (!ref.mounted) return;
        state = state.copyWith(status: ApiStatus.error);
        CustomSnackBar.showError(
          title: "Login Failed",
          message: failure.message,
        );
    }
  }

  /// Signs in with Google, then calls POST /login with `login_type: google`
  /// plus the account id (`google_id`) and auth token (`id_token`) — no
  /// password is sent for this flow. Mirrors RegisterNotifier's Google
  /// flow.
  Future<void> loginWithGoogle() async {
    if (state.isLoading) return;
    state = state.copyWith(status: ApiStatus.loading);

    try {
      // Google caches the last-picked account and will silently re-sign
      // into it on the next call, skipping the account chooser. Sign out
      // first so the picker shows every time, even if the user picked one
      // before.
      await _googleSignIn.signOut();

      final account = await _googleSignIn.signIn();
      if (!ref.mounted) return;
      if (account == null) {
        // User cancelled the Google sign-in flow.
        state = state.copyWith(status: ApiStatus.initial);
        return;
      }

      // Pull the actual auth token from the completed sign-in — prefer the
      // ID token (signed JWT the backend can verify with Google); fall back
      // to the access token if for some reason the ID token isn't returned.
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

      final request = LoginRequest(
        loginType: 'google',
        email: account.email,
        googleId: account.id,
        idToken: googleToken,
      );

      final result = await _authRepository.login(request);
      await _handleResult(result);
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
}

final loginProvider = NotifierProvider.autoDispose<LoginNotifier, LoginState>(
  LoginNotifier.new,
);
