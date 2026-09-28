// File: lib/features/profile/profile_provider.dart
// Purpose: Logout via POST /logout. Logout removes the account's stored
// data, ends the session and signs out of Google, so nothing from this
// account carries over into the next login (every provider that watches
// sessionProvider rebuilds).

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:urban_services/core/constants/api_status.dart';
import 'package:urban_services/core/navigation/app_keys.dart';
import 'package:urban_services/core/network/api_result.dart';
import 'package:urban_services/core/session/session_provider.dart';
import 'package:urban_services/features/authentication/register/register_repository.dart';
import 'package:urban_services/routes/app_router.dart';
import 'package:urban_services/routes/route_names.dart';
import 'package:urban_services/widgets/custom_snackbar.dart';

class LogoutNotifier extends Notifier<ApiStatus> {
  /// Tracks the current /logout call so the confirmation dialog can show a
  /// loading state and avoid double taps.
  @override
  ApiStatus build() => ApiStatus.initial;

  bool get isLoggingOut => state == ApiStatus.loading;

  /// Calls POST /logout, then clears the local session regardless of the
  /// API result — a failed network call shouldn't be able to trap the user
  /// in a logged-in state on their own device.
  Future<void> logout() async {
    if (isLoggingOut) return;
    state = ApiStatus.loading;

    // Grab everything we need up front: closing the dialog below disposes
    // this (autoDispose) provider.
    final session = ref.read(sessionProvider.notifier);
    final router = ref.read(routerProvider);
    final token = ref.read(sessionProvider).token;

    final result = await ref.read(authRepositoryProvider).logout(token);

    switch (result) {
      case ApiSuccess(data: final message):
        if (ref.mounted) state = ApiStatus.successful;
        CustomSnackBar.showSuccess(title: "Success", message: message);
      case ApiError(failure: final failure):
        if (ref.mounted) state = ApiStatus.error;
        CustomSnackBar.showWarning(title: "Logout", message: failure.message);
    }

    // Close the confirmation dialog, then clear the account's data so the
    // next login starts from a clean slate. Signing out of Google makes
    // the next Google login show the account picker; it's a no-op for
    // manual logins.
    rootNavigatorKey.currentState?.maybePop();
    try {
      await GoogleSignIn().signOut();
    } catch (e) {
      debugPrint("Google sign-out failed: $e");
    }
    await session.logout();
    router.go(RouteNames.welcomeScreen);
  }
}

final logoutProvider = NotifierProvider.autoDispose<LogoutNotifier, ApiStatus>(
  LogoutNotifier.new,
);
