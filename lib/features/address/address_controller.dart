// File: lib/features/address/address_controller.dart
// Purpose: Business logic for the "Select Your Service Address" screen —
// fetching the user's saved address, permission-aware "use current
// location" (skips the system dialog when permission is already granted),
// and saving the detected location via the service-address API.
//
// Selection model: the saved address, "use current location", and a
// manually-entered address (staged by AddAddressController.saveAddress via
// [setManualEntry]) are three mutually-exclusive, radio-style choices (see
// [AddressSource]). Choosing one only records the choice — nothing is
// fetched or saved to the server until the user explicitly confirms with
// Next ([AddressController.confirmAndProceed]).

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

/// The mutually-exclusive ways a service address can be chosen on this
/// screen.
enum AddressSource { savedAddress, currentLocation, manualEntry }

class AddressController extends GetxController with WidgetsBindingObserver {
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

  /// Whether location permission is currently granted. Drives whether the
  /// "Use my Current Location" row shows an "Enable" pill or a plain
  /// selectable radio button.
  final hasLocationPermission = false.obs;

  /// Which address source is currently selected (radio-button style) —
  /// null means nothing has been chosen yet. Selecting a source never
  /// saves anything by itself; see [confirmAndProceed].
  final selectedSource = Rxn<AddressSource>();

  /// A manually-entered address staged by the Add Address form
  /// ([setManualEntry]) but not yet POSTed to the server — that only
  /// happens when the user confirms with Next.
  final pendingManualAddress = Rxn<ServiceAddressRequest>();

  /// Tracks the POST triggered by confirming a staged manual entry,
  /// separately from [isFetchingLocation].
  final isSavingManualEntry = false.obs;

  /// Whether the "CHOOSE YOUR ADDRESS" card has anything to select — either
  /// an already-saved address or a staged manual entry.
  bool get hasCardAddress => hasAddress || pendingManualAddress.value != null;

  /// Whether the card's content (staged manual entry takes priority over
  /// the saved address, matching what's actually displayed) is the
  /// currently-selected source.
  bool get isCardAddressSelected => pendingManualAddress.value != null
      ? selectedSource.value == AddressSource.manualEntry
      : selectedSource.value == AddressSource.savedAddress;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    fetchAddress();
    _refreshLocationPermissionStatus();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  /// Re-checks location permission when the app resumes (e.g. the user
  /// granted it from system Settings after being sent there for a
  /// permanently-denied prompt) so the row switches from "Enable" to the
  /// radio button without needing a manual retry.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshLocationPermissionStatus();
    }
  }

  Future<void> _refreshLocationPermissionStatus() async {
    hasLocationPermission.value =
        (await Permission.location.status).isGranted;
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
        selectedSource.value = AddressSource.savedAddress;
      case ApiFailure():
        address.value = null;
        selectedSource.value = null;
    }

    status.value = ApiStatus.successful;
  }

  /// Selects whatever is showing in the "CHOOSE YOUR ADDRESS" card — the
  /// staged manual entry if there is one, otherwise the already-saved
  /// address. No-op if neither exists yet.
  void selectCardAddress() {
    if (pendingManualAddress.value != null) {
      selectedSource.value = AddressSource.manualEntry;
    } else if (hasAddress) {
      selectedSource.value = AddressSource.savedAddress;
    }
  }

  /// Stages a manually-entered address (from the Add Address form) as the
  /// selected source, without saving it yet — the actual POST happens when
  /// the user confirms with Next (see [confirmAndProceed]).
  void setManualEntry(ServiceAddressRequest request) {
    pendingManualAddress.value = request;
    selectedSource.value = AddressSource.manualEntry;
  }

  /// Handles a tap on "Use my Current Location" (the Enable pill, or the
  /// radio once permission is already granted): if permission is already
  /// granted, this just *selects* current location as the chosen source —
  /// it does not fetch or save anything. If permission isn't granted yet,
  /// it shows the Location Accuracy dialog first; selection happens once
  /// that's granted (see [requestLocationPermission]). The actual fetch +
  /// save only happens when the user confirms with Next.
  Future<void> onCurrentLocationTap() async {
    if (isFetchingLocation.value) return;

    final permissionStatus = await Permission.location.status;
    hasLocationPermission.value = permissionStatus.isGranted;
    if (permissionStatus.isGranted) {
      selectedSource.value = AddressSource.currentLocation;
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
      hasLocationPermission.value = true;
      selectedSource.value = AddressSource.currentLocation;
      Get.back(); // Close the custom dialog
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
  /// address, and saves it via POST /user/service-address. Returns true on
  /// success, false otherwise (an error toast is already shown by then).
  Future<bool> _fetchAndSaveCurrentLocation() async {
    if (isFetchingLocation.value) return false;
    isFetchingLocation.value = true;

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        CustomSnackBar.showError(
          title: "Location Off",
          message: "Please turn on location services and try again.",
        );
        return false;
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
          return false;
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
        return false;
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
          return true;
        case ApiFailure(message: final message):
          CustomSnackBar.showError(title: "Error", message: message);
          return false;
      }
    } catch (e) {
      debugPrint("AddressController - current location error: $e");
      CustomSnackBar.showError(
        title: "Error",
        message: "Couldn't get your current location. Please try again.",
      );
      return false;
    } finally {
      isFetchingLocation.value = false;
    }
  }

  /// Called when the user taps Next. Commits whichever source is selected
  /// — for the saved address that's already done, for current location
  /// this is the one point where a GPS fetch + save actually happens.
  /// Returns true when it's safe to navigate to Home.
  Future<bool> confirmAndProceed() async {
    switch (selectedSource.value) {
      case AddressSource.savedAddress:
        return hasAddress;
      case AddressSource.currentLocation:
        return _fetchAndSaveCurrentLocation();
      case AddressSource.manualEntry:
        return _saveManualEntry();
      case null:
        return false;
    }
  }

  /// POSTs the staged manual entry via /user/service-address. Returns true
  /// on success, false otherwise (an error toast is already shown by
  /// then).
  Future<bool> _saveManualEntry() async {
    final request = pendingManualAddress.value;
    if (request == null || isSavingManualEntry.value) return false;

    isSavingManualEntry.value = true;
    try {
      final result = await _addressRepository.saveServiceAddress(request);
      switch (result) {
        case ApiSuccess(data: final data):
          CustomSnackBar.showSuccess(
            title: "Success",
            message: data.message ?? "Service address saved successfully.",
          );
          pendingManualAddress.value = null;
          await fetchAddress();
          return true;
        case ApiFailure(message: final message):
          CustomSnackBar.showError(title: "Error", message: message);
          return false;
      }
    } finally {
      isSavingManualEntry.value = false;
    }
  }

  /// Closes the current active dialog (e.g., LocationAccuracyDialog).
  void closeDialog() {
    Get.back();
  }
}
