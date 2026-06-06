// File: lib/features/address/address_controller.dart
// Purpose: Business logic for managing address selection, permissions, and dialog interactions.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class AddressController extends GetxController {
  /// Logic to request location permission from the system.
  /// Handles different states: Granted, Denied, and Permanently Denied.
  Future<void> requestLocationPermission() async {
    // Permission.location requests both FINE and COARSE location on Android
    final status = await Permission.location.request();

    if (status.isGranted) {
      debugPrint("Location permission granted");
      // TODO: Proceed with fetching real-time location data
      Get.back(); // Close the custom dialog
    } else if (status.isDenied) {
      debugPrint("Location permission denied");
      // The user denied the permission but can be asked again in the future
    } else if (status.isPermanentlyDenied) {
      debugPrint("Location permission permanently denied");
      // User opted to not be asked again, redirecting to system settings is standard UX
      await openAppSettings();
      Get.back(); // Close the custom dialog
    } else {
      Get.back(); // Default fallback to close dialog
    }
  }

  /// Closes the current active dialog (e.g., LocationAccuracyDialog).
  void closeDialog() {
    Get.back();
  }
}
