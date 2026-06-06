// File: lib/features/address/add_address_controller.dart
// Purpose: State management and validation logic for the Add New Address form.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urban_services/routes/route_names.dart';

class AddAddressController extends GetxController {
  // Text editing controllers for capturing user input
  final flatController = TextEditingController();
  final floorController = TextEditingController();
  final buildingController = TextEditingController();
  final fullAddressController = TextEditingController();
  final landmarkController = TextEditingController();

  // Focus nodes for managing keyboard focus flow
  final flatFocus = FocusNode();
  final floorFocus = FocusNode();
  final buildingFocus = FocusNode();
  final fullAddressFocus = FocusNode();
  final landmarkFocus = FocusNode();

  // Reactive error strings for real-time validation feedback
  final flatError = RxnString();
  final floorError = RxnString();
  final buildingError = RxnString();
  final fullAddressError = RxnString();

  // Reactive boolean for "Save as default" checkbox state
  final isDefault = false.obs;

  /// Validates all required form fields.
  /// Returns [true] if all fields are valid, [false] otherwise.
  bool validate() {
    bool isValid = true;

    if (flatController.text.trim().isEmpty) {
      flatError.value = "Flat/Apartment is required";
      isValid = false;
    } else {
      flatError.value = null;
    }

    if (floorController.text.trim().isEmpty) {
      floorError.value = "Floor/Building is required";
      isValid = false;
    } else {
      floorError.value = null;
    }

    if (buildingController.text.trim().isEmpty) {
      buildingError.value = "Building/Society is required";
      isValid = false;
    } else {
      buildingError.value = null;
    }

    if (fullAddressController.text.trim().isEmpty) {
      fullAddressError.value = "Full Address is required";
      isValid = false;
    } else {
      fullAddressError.value = null;
    }

    return isValid;
  }

  /// Validates and saves the address, then redirects to the Home screen.
  void saveAddress() {
    if (validate()) {
      // TODO: Implement persistent storage logic here (e.g., API call or Local DB)
      debugPrint("Saving address: ${fullAddressController.text}");
      Get.offAllNamed(RouteNames.homeMain);
    }
  }

  @override
  void onClose() {
    // Standard cleanup of controllers and nodes to prevent memory leaks
    flatController.dispose();
    floorController.dispose();
    buildingController.dispose();
    fullAddressController.dispose();
    landmarkController.dispose();
    flatFocus.dispose();
    floorFocus.dispose();
    buildingFocus.dispose();
    fullAddressFocus.dispose();
    landmarkFocus.dispose();
    super.onClose();
  }
}
