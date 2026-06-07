// File: lib/features/profile/profile_controller.dart
// Purpose: State management and logic for the Profile screen, including logout functionality.

import 'package:get/get.dart';
import 'package:urban_services/routes/route_names.dart';

class ProfileController extends GetxController {
  /// Performs the logout action by clearing the navigation stack and returning to the Welcome screen.
  void logout() {
    Get.offAllNamed(RouteNames.welcomeScreen);
  }

  /// Closes the current active dialog.
  void closeDialog() {
    Get.back();
  }
}
