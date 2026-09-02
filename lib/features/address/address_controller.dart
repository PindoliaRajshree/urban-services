// File: lib/features/address/address_controller.dart
// Purpose: Business logic for the "Select Your Service Address" screen —
// fetching the user's saved address, permission-aware "use current
// location" (skips the system dialog when permission is already granted),
// and saving the detected location via the service-address API.

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:urban_services/core/constants/api_status.dart';
import 'package:urban_services/core/constants/storage_keys.dart';
import 'package:urban_services/core/services/api_result.dart';
import 'package:urban_services/features/address/address_repository.dart';
import 'package:urban_services/features/address/models/service_address_request.dart';
import 'package:urban_services/features/address/models/service_address_response.dart';
import 'package:urban_services/features/address/services/google_geocoding_service.dart';
import 'package:urban_services/shared_preferences/sharedpreference_helper.dart';
import 'package:urban_services/widgets/custom_snackbar.dart';
import 'package:urban_services/widgets/location_accuracy_dialog.dart';

class AddressController extends GetxController {
  AddressController({AddressRepository? addressRepository})
    : _addressRepository = addressRepository ?? AddressRepository();

  final AddressRepository _addressRepository;

  /// Tracks the initial GET /user/get-service-address call.
  final status = ApiStatus.initial.obs;

  bool get isLoadingAddress => status.value == ApiStatus.loading;

  /// The user's previously saved service address, or null if they haven't
  /// saved one yet.
  final address = Rxn<ServiceAddressResponse>();

  bool get hasAddress => address.value != null;

  /// Tracks the "Use my Current Location" flow (get position -> reverse
  /// geocode -> save) separately from the initial page load.
  final isFetchingLocation = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAddress();
  }

  /// Calls GET /user/get-service-address. A failure (including "no address
  /// saved yet") just leaves [address] null — that's an expected state on
  /// a fresh account, not something to show as an error.
  Future<void> fetchAddress() async {
    status.value = ApiStatus.loading;
    final result = await _addressRepository.getServiceAddress();

    switch (result) {
      case ApiSuccess(data: final data):
        address.value = data;
      case ApiFailure():
        address.value = null;
    }

    status.value = ApiStatus.successful;
  }

  /// Handles the "Use my Current Location" tap: if location permission is
  /// already granted, skip straight to fetching + saving the location. If
  /// not, show the Location Accuracy dialog (which triggers the actual
  /// system permission prompt).
  Future<void> onUseCurrentLocationTap() async {
    if (isFetchingLocation.value) return;

    final permissionStatus = await Permission.location.status;
    if (permissionStatus.isGranted) {
      await _fetchAndSaveCurrentLocation();
    } else {
      Get.dialog(const LocationAccuracyDialog(), barrierDismissible: false);
    }
  }

  /// Logic to request location permission from the system.
  /// Handles different states: Granted, Denied, and Permanently Denied.
  Future<void> requestLocationPermission() async {
    // Permission.location requests both FINE and COARSE location on Android
    final permissionStatus = await Permission.location.request();

    if (permissionStatus.isGranted) {
      debugPrint("Location permission granted");
      Get.back(); // Close the custom dialog
      await _fetchAndSaveCurrentLocation();
    } else if (permissionStatus.isDenied) {
      debugPrint("Location permission denied");
      // The user denied the permission but can be asked again in the future
    } else if (permissionStatus.isPermanentlyDenied) {
      debugPrint("Location permission permanently denied");
      // User opted to not be asked again, redirecting to system settings is standard UX
      await openAppSettings();
      Get.back(); // Close the custom dialog
    } else {
      Get.back(); // Default fallback to close dialog
    }
  }

  /// Gets the device's current position, reverse-geocodes it into an
  /// address, and saves it via POST /user/service-address.
  Future<void> _fetchAndSaveCurrentLocation() async {
    if (isFetchingLocation.value) return;
    isFetchingLocation.value = true;

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        CustomSnackBar.showError(
          title: "Location Off",
          message: "Please turn on location services and try again.",
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      // Prefer Google's Geocoding API (server-side, much more accurate)
      // and only fall back to the on-device geocoder if it isn't
      // configured yet or the call fails for any reason.
      final googleResult = await GoogleGeocodingService.instance
          .reverseGeocode(
            latitude: position.latitude,
            longitude: position.longitude,
          );

      String fullAddress;
      String city;
      String state;
      String pincode;

      if (googleResult != null && googleResult.formattedAddress.isNotEmpty) {
        fullAddress = googleResult.formattedAddress;
        city = googleResult.city;
        state = googleResult.state;
        pincode = googleResult.pincode;
      } else {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isEmpty) {
          CustomSnackBar.showError(
            title: "Error",
            message: "Couldn't determine your address from your location.",
          );
          return;
        }

        final place = placemarks.first;
        fullAddress = [
          place.name,
          place.subLocality,
          place.thoroughfare,
          place.locality,
        ].where((part) => part != null && part.trim().isNotEmpty).join(', ');

        city = place.locality ?? '';
        state = place.administrativeArea ?? '';
        pincode = place.postalCode ?? '';
      }

      final userId = await SharedPreferencesHelper.instance.getValue<int>(
        StorageKeys.userId,
      );
      if (userId == null) {
        CustomSnackBar.showError(
          title: "Error",
          message: "You're not logged in. Please log in again.",
        );
        return;
      }

      final request = ServiceAddressRequest(
        fullAddress: fullAddress.isNotEmpty ? fullAddress : '$city, $state',
        city: city,
        state: state,
        pincode: pincode,
        userId: userId,
      );

      final result = await _addressRepository.saveServiceAddress(request);
      switch (result) {
        case ApiSuccess(data: final data):
          CustomSnackBar.showSuccess(
            title: "Success",
            message: data.message ?? "Current location saved as your address.",
          );
          await fetchAddress();
        case ApiFailure(message: final message):
          CustomSnackBar.showError(title: "Error", message: message);
      }
    } catch (e) {
      debugPrint("AddressController - current location error: $e");
      CustomSnackBar.showError(
        title: "Error",
        message: "Couldn't get your current location. Please try again.",
      );
    } finally {
      isFetchingLocation.value = false;
    }
  }

  /// Closes the current active dialog (e.g., LocationAccuracyDialog).
  void closeDialog() {
    Get.back();
  }
}
