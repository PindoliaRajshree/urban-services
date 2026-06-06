import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urban_services/routes/route_names.dart';

class AddAddressController extends GetxController {
  final flatController = TextEditingController();
  final floorController = TextEditingController();
  final buildingController = TextEditingController();
  final fullAddressController = TextEditingController();
  final landmarkController = TextEditingController();

  final flatFocus = FocusNode();
  final floorFocus = FocusNode();
  final buildingFocus = FocusNode();
  final fullAddressFocus = FocusNode();
  final landmarkFocus = FocusNode();

  final flatError = RxnString();
  final floorError = RxnString();
  final buildingError = RxnString();
  final fullAddressError = RxnString();

  final isDefault = false.obs;

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

  void saveAddress() {
    if (validate()) {
      // Logic to save address
      Get.offAllNamed(RouteNames.homeMain);
    }
  }

  @override
  void onClose() {
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
