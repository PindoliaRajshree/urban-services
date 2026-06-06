import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class AddressController extends GetxController {
  Future<void> requestLocationPermission() async {
    // Permission.location requests both FINE and COARSE location on Android
    final status = await Permission.location.request();

    if (status.isGranted) {
      debugPrint("Location permission granted");
      Get.back(); // Close dialog
    } else if (status.isDenied) {
      debugPrint("Location permission denied");
      // The user denied the permission but can be asked again
    } else if (status.isPermanentlyDenied) {
      debugPrint("Location permission permanently denied");
      // User opted to not be asked again, redirect to settings
      await openAppSettings();
      Get.back(); // Close dialog
    } else {
      Get.back(); // Close dialog for other states
    }
  }

  void closeDialog() {
    Get.back();
  }
}
