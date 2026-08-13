// File: lib/features/profile/profile_controller.dart
// Purpose: State management and logic for the Profile screen, including
// logout via POST /logout.

import 'package:get/get.dart';
import 'package:urban_services/core/constants/api_status.dart';
import 'package:urban_services/core/constants/storage_keys.dart';
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
    Get.offAllNamed(RouteNames.welcomeScreen);
  }

  /// Removes locally stored auth/session data.
  Future<void> _clearSession() async {
    final prefs = SharedPreferencesHelper.instance;
    await prefs.remove(StorageKeys.authToken);
    await prefs.remove(StorageKeys.userId);
    await prefs.remove(StorageKeys.userName);
    await prefs.remove(StorageKeys.userEmail);
    await prefs.remove(StorageKeys.userMobile);
    await prefs.remove(StorageKeys.userRole);
  }

  /// Closes the current active dialog.
  void closeDialog() {
    Get.back();
  }
}
