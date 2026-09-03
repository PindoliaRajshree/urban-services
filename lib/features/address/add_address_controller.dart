// File: lib/features/address/add_address_controller.dart
// Purpose: State management and validation logic for the Add New Address
// form. Save() stages the validated address onto the shared
// AddressController (see AddressController.setManualEntry) and returns to
// "Select Your Service Address" — that screen's Next button is the single
// place that actually POSTs /user/service-address, whether the address
// came from current location or here. User-only — providers never reach
// this screen.

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:urban_services/core/constants/api_status.dart';
import 'package:urban_services/core/constants/storage_keys.dart';
import 'package:urban_services/features/address/address_controller.dart';
import 'package:urban_services/features/address/models/service_address_request.dart';
import 'package:urban_services/features/address/models/service_address_response.dart';
import 'package:urban_services/features/address/services/google_geocoding_service.dart';
import 'package:urban_services/shared_preferences/sharedpreference_helper.dart';
import 'package:urban_services/widgets/custom_snackbar.dart';

/// Default map center (India) used until the user picks a real location.
const LatLng _defaultMapCenter = LatLng(20.5937, 78.9629);

class AddAddressController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    // Prefill the form when editing an existing address (passed as the
    // route argument by AddressScreen's Change/Add Address button).
    final existing = Get.arguments;
    if (existing is ServiceAddressResponse) {
      _prefillFrom(existing);
    }
  }

  /// Populates every field from a previously saved address.
  void _prefillFrom(ServiceAddressResponse existing) {
    flatController.text = existing.flatApartment ?? '';
    floorController.text = existing.floorBuilding ?? '';
    buildingController.text = existing.buildingSocietyLandmark ?? '';
    fullAddressController.text = existing.fullAddress ?? '';
    landmarkController.text = existing.landmark ?? '';
    cityController.text = existing.city ?? '';
    stateController.text = existing.state ?? '';
    pincodeController.text = existing.pincode ?? '';
    isDefault.value = existing.isDefault ?? false;

    if (existing.latitude != null && existing.longitude != null) {
      selectedPosition.value = LatLng(existing.latitude!, existing.longitude!);
    }
  }

  // --- Map state ---
  GoogleMapController? _mapController;
  final selectedPosition = Rxn<LatLng>();
  final isLocatingOnMap = false.obs;

  LatLng get initialMapPosition => selectedPosition.value ?? _defaultMapCenter;

  void onMapCreated(GoogleMapController mapController) {
    _mapController = mapController;
  }

  /// Lets the user drop the pin manually by tapping the map — reverse
  /// geocodes the tapped point the same way "Use Current Location" does.
  Future<void> onMapTapped(LatLng position) async {
    await _applyLatLng(position);
  }

  /// Gets the device's current position and prefills the address fields
  /// (full address, city, state, pincode) from it via reverse geocoding.
  /// Flat/Floor/Building aren't part of standard reverse-geocoding data, so
  /// those are left for the user to fill in.
  Future<void> useCurrentLocationOnMap() async {
    if (isLocatingOnMap.value) return;
    isLocatingOnMap.value = true;

    try {
      var permissionStatus = await Permission.location.status;
      if (!permissionStatus.isGranted) {
        permissionStatus = await Permission.location.request();
      }
      if (!permissionStatus.isGranted) {
        CustomSnackBar.showError(
          title: "Permission Required",
          message: "Location permission is needed to use your current location.",
        );
        return;
      }

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
      await _applyLatLng(LatLng(position.latitude, position.longitude));
    } catch (e) {
      debugPrint("AddAddressController - current location error: $e");
      CustomSnackBar.showError(
        title: "Error",
        message: "Couldn't get your current location. Please try again.",
      );
    } finally {
      isLocatingOnMap.value = false;
    }
  }

  /// Moves the map/marker to [latLng] and reverse-geocodes it into the
  /// Full Address / City / State / Pincode fields.
  Future<void> _applyLatLng(LatLng latLng) async {
    selectedPosition.value = latLng;
    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 16));

    try {
      // Prefer Google's Geocoding API (server-side, much more accurate)
      // and only fall back to the on-device geocoder if it isn't
      // configured yet or the call fails for any reason.
      final googleResult = await GoogleGeocodingService.instance
          .reverseGeocode(latitude: latLng.latitude, longitude: latLng.longitude);

      if (googleResult != null && googleResult.formattedAddress.isNotEmpty) {
        fullAddressController.text = googleResult.formattedAddress;
        if (googleResult.city.isNotEmpty) cityController.text = googleResult.city;
        if (googleResult.state.isNotEmpty) {
          stateController.text = googleResult.state;
        }
        if (googleResult.pincode.isNotEmpty) {
          pincodeController.text = googleResult.pincode;
        }
        return;
      }

      final placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );
      if (placemarks.isEmpty) return;

      final place = placemarks.first;
      final fullAddress = [
        place.name,
        place.subLocality,
        place.thoroughfare,
        place.locality,
      ].where((part) => part != null && part.trim().isNotEmpty).join(', ');

      if (fullAddress.isNotEmpty) fullAddressController.text = fullAddress;
      cityController.text = place.locality ?? cityController.text;
      stateController.text = place.administrativeArea ?? stateController.text;
      pincodeController.text = place.postalCode ?? pincodeController.text;
    } catch (e) {
      debugPrint("AddAddressController - reverse geocode error: $e");
      CustomSnackBar.showError(
        title: "Error",
        message: "Couldn't determine the address for that location.",
      );
    }
  }

  /// Public entry point for the full-screen map picker: applies the
  /// chosen [latLng] the same way tapping the inline map or "Use Current
  /// Location" does.
  Future<void> applyPickedLocation(LatLng latLng) async {
    await _applyLatLng(latLng);
  }

  // Text editing controllers for capturing user input
  final flatController = TextEditingController();
  final floorController = TextEditingController();
  final buildingController = TextEditingController();
  final fullAddressController = TextEditingController();
  final landmarkController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final pincodeController = TextEditingController();

  // Focus nodes for managing keyboard focus flow
  final flatFocus = FocusNode();
  final floorFocus = FocusNode();
  final buildingFocus = FocusNode();
  final fullAddressFocus = FocusNode();
  final landmarkFocus = FocusNode();
  final cityFocus = FocusNode();
  final stateFocus = FocusNode();
  final pincodeFocus = FocusNode();

  // Reactive error strings for real-time validation feedback
  final flatError = RxnString();
  final floorError = RxnString();
  final buildingError = RxnString();
  final fullAddressError = RxnString();
  final cityError = RxnString();
  final stateError = RxnString();
  final pincodeError = RxnString();

  // Reactive boolean for "Save as default" checkbox state
  final isDefault = false.obs;

  /// Tracks the current POST /user/service-address call so the UI can
  /// disable the Save button and show a loading state.
  final status = ApiStatus.initial.obs;

  bool get isLoading => status.value == ApiStatus.loading;

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

    if (cityController.text.trim().isEmpty) {
      cityError.value = "City is required";
      isValid = false;
    } else {
      cityError.value = null;
    }

    if (stateController.text.trim().isEmpty) {
      stateError.value = "State is required";
      isValid = false;
    } else {
      stateError.value = null;
    }

    if (pincodeController.text.trim().isEmpty) {
      pincodeError.value = "Pincode is required";
      isValid = false;
    } else {
      pincodeError.value = null;
    }

    return isValid;
  }

  /// Validates the form and stages the address onto the shared
  /// AddressController, then returns to "Select Your Service Address"
  /// without saving anything yet — that screen's Next button is what
  /// actually POSTs /user/service-address (see
  /// AddressController.confirmAndProceed / setManualEntry).
  Future<void> saveAddress() async {
    if (isLoading) return;
    if (!validate()) return;

    status.value = ApiStatus.loading;

    final userId = await SharedPreferencesHelper.instance.getValue<int>(
      StorageKeys.userId,
    );
    if (userId == null) {
      status.value = ApiStatus.error;
      CustomSnackBar.showError(
        title: "Error",
        message: "You're not logged in. Please log in again.",
      );
      return;
    }

    final request = ServiceAddressRequest(
      fullAddress: fullAddressController.text.trim(),
      city: cityController.text.trim(),
      state: stateController.text.trim(),
      pincode: pincodeController.text.trim(),
      userId: userId,
      flatApartment: flatController.text.trim(),
      floorBuilding: floorController.text.trim(),
      buildingSocietyLandmark: buildingController.text.trim(),
      landmark: landmarkController.text.trim(),
    );

    status.value = ApiStatus.successful;

    if (Get.isRegistered<AddressController>()) {
      Get.find<AddressController>().setManualEntry(request);
    }
    Get.back();
  }

  @override
  void onClose() {
    // Standard cleanup of controllers and nodes to prevent memory leaks
    flatController.dispose();
    floorController.dispose();
    buildingController.dispose();
    fullAddressController.dispose();
    landmarkController.dispose();
    cityController.dispose();
    stateController.dispose();
    pincodeController.dispose();
    flatFocus.dispose();
    floorFocus.dispose();
    buildingFocus.dispose();
    fullAddressFocus.dispose();
    landmarkFocus.dispose();
    cityFocus.dispose();
    stateFocus.dispose();
    pincodeFocus.dispose();
    _mapController?.dispose();
    super.onClose();
  }
}
