// File: lib/features/profile/profile_controller.dart
// Purpose: State management and logic for the Profile screen, including
// logout via POST /logout. Logout fully wipes local storage and disposes
// every GetX controller in memory so nothing from this account's session
// carries over into the next login.

import 'package:get/get.dart';
import 'package:urban_services/core/constants/api_status.dart';
import 'package:urban_services/core/services/api_result.dart';
import 'package:urban_services/features/authentication/register/register_repository.dart';
import 'package:urban_services/routes/route_names.dart';
import 'package:urban_services/shared_preferences/sharedpreference_helper.dart';
import 'package:urban_services/widgets/custom_snackbar.dart';

class ProfileController extends GetxController {
  ProfileController({AuthRepository? authRepository})
    : _authRepository = authRepository ?? AuthRepository();

  final AuthRepository _authRepository;

  /// Tracks the current /logout call so the confirmation dialog can show a
  /// loading state and avoid double taps.
  final status = ApiStatus.initial.obs;

  bool get isLoggingOut => status.value == ApiStatus.loading;

  /// Calls POST /logout, then clears the local session regardless of the
  /// API result — a failed network call shouldn't be able to trap the user
  /// in a logged-in state on their own device.
  Future<void> logout() async {
    if (isLoggingOut) return;
    status.value = ApiStatus.loading;

    final result = await _authRepository.logout();

    switch (result) {
      case ApiSuccess(data: final message):
        status.value = ApiStatus.successful;
        CustomSnackBar.showSuccess(title: "Success", message: message);
      case ApiFailure(message: final message):
        status.value = ApiStatus.error;
        CustomSnackBar.showWarning(
          title: "Logout",
          message: message,
        );
    }

    await _clearSession();

    if (Get.isDialogOpen ?? false) Get.back();

    // Dispose every GetX controller currently held in memory — including
    // ones registered with `permanent: true` (LoginController,
    // ForgotPasswordController) — so no cached state from this account
    // (role, address, profile data, form inputs, etc.) survives into the
    // next login. Must run BEFORE the navigation below: screens re-create
    // their controllers with Get.put(...) on build, and Get.put() reuses
    // an already-registered instance instead of making a fresh one, so
    // deleting first is what actually resets them.
    Get.deleteAll(force: true);

    Get.offAllNamed(RouteNames.welcomeScreen);
  }

  /// Wipes ALL locally stored data (not just auth/profile keys) so the
  /// next login starts from a completely clean slate — any screen-local
  /// cache written under a key this controller doesn't know about is
  /// cleared too.
  Future<void> _clearSession() async {
    await SharedPreferencesHelper.instance.clear();
  }

  /// Closes the current active dialog.
  void closeDialog() {
    Get.back();
  }
}
