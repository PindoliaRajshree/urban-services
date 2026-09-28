// File: lib/features/address/address_provider.dart
// Purpose: Business logic for the "Select Your Service Address" screen —
// fetching the user's saved address, permission-aware "use current
// location" (skips the system dialog when permission is already granted),
// and saving the detected location via the service-address API.
//
// Selection model: the saved address, "use current location", and a
// manually-entered address (staged by AddAddressNotifier.saveAddress via
// [AddressNotifier.setManualEntry]) are three mutually-exclusive,
// radio-style choices (see [AddressSource]). Choosing one only records the
// choice — nothing is fetched or saved to the server until the user
// explicitly confirms with Next ([AddressNotifier.confirmAndProceed]).

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:urban_services/core/constants/api_status.dart';
import 'package:urban_services/core/location/location_helper.dart';
import 'package:urban_services/core/network/api_failure.dart';
import 'package:urban_services/core/network/api_result.dart';
import 'package:urban_services/core/session/session_provider.dart';
import 'package:urban_services/features/address/address_repository.dart';
import 'package:urban_services/features/address/models/service_address_request.dart';
import 'package:urban_services/features/address/models/service_address_response.dart';
import 'package:urban_services/features/address/services/google_geocoding_service.dart';
import 'package:urban_services/widgets/custom_snackbar.dart';

/// The mutually-exclusive ways a service address can be chosen on this
/// screen.
enum AddressSource { savedAddress, currentLocation, manualEntry }

class AddressState {
  const AddressState({
    this.status = ApiStatus.initial,
    this.address,
    this.isFetchingLocation = false,
    this.hasLocationPermission = false,
    this.selectedSource,
    this.pendingManualAddress,
    this.isSavingManualEntry = false,
  });

  /// Tracks the initial GET /user/get-service-address call.
  final ApiStatus status;

  /// The user's previously saved service address, or null if they haven't
  /// saved one yet.
  final ServiceAddressResponse? address;

  /// Tracks the "Use my Current Location" flow (get position -> reverse
  /// geocode -> save) separately from the initial page load.
  final bool isFetchingLocation;

  /// Whether location permission is currently granted. Drives whether the
  /// "Use my Current Location" row shows an "Enable" pill or a plain
  /// selectable radio button.
  final bool hasLocationPermission;

  /// Which address source is currently selected (radio-button style) —
  /// null means nothing has been chosen yet. Selecting a source never
  /// saves anything by itself; see [AddressNotifier.confirmAndProceed].
  final AddressSource? selectedSource;

  /// A manually-entered address staged by the Add Address form
  /// ([AddressNotifier.setManualEntry]) but not yet POSTed to the server —
  /// that only happens when the user confirms with Next.
  final ServiceAddressRequest? pendingManualAddress;

  /// Tracks the POST triggered by confirming a staged manual entry,
  /// separately from [isFetchingLocation].
  final bool isSavingManualEntry;

  bool get isLoadingAddress => status == ApiStatus.loading;

  bool get hasAddress => address != null;

  /// Whether the "CHOOSE YOUR ADDRESS" card has anything to select — either
  /// an already-saved address or a staged manual entry.
  bool get hasCardAddress => hasAddress || pendingManualAddress != null;

  /// Whether the card's content (staged manual entry takes priority over
  /// the saved address, matching what's actually displayed) is the
  /// currently-selected source.
  bool get isCardAddressSelected => pendingManualAddress != null
      ? selectedSource == AddressSource.manualEntry
      : selectedSource == AddressSource.savedAddress;

  AddressState copyWith({
    ApiStatus? status,
    ServiceAddressResponse? Function()? address,
    bool? isFetchingLocation,
    bool? hasLocationPermission,
    AddressSource? Function()? selectedSource,
    ServiceAddressRequest? Function()? pendingManualAddress,
    bool? isSavingManualEntry,
  }) => AddressState(
    status: status ?? this.status,
    address: address != null ? address() : this.address,
    isFetchingLocation: isFetchingLocation ?? this.isFetchingLocation,
    hasLocationPermission: hasLocationPermission ?? this.hasLocationPermission,
    selectedSource: selectedSource != null
        ? selectedSource()
        : this.selectedSource,
    pendingManualAddress: pendingManualAddress != null
        ? pendingManualAddress()
        : this.pendingManualAddress,
    isSavingManualEntry: isSavingManualEntry ?? this.isSavingManualEntry,
  );
}

class AddressNotifier extends Notifier<AddressState> {
  AddressRepository get _addressRepository =>
      ref.read(addressRepositoryProvider);

  @override
  AddressState build() {
    Future.microtask(() {
      fetchAddress();
      refreshLocationPermissionStatus();
    });
    return const AddressState();
  }

  /// Re-checks location permission. Also called by AddressScreen when the
  /// app resumes (e.g. the user granted it from system Settings after being
  /// sent there for a permanently-denied prompt) so the row switches from
  /// "Enable" to the radio button without needing a manual retry.
  Future<void> refreshLocationPermissionStatus() async {
    final granted = (await Permission.location.status).isGranted;
    if (!ref.mounted) return;
    state = state.copyWith(hasLocationPermission: granted);

    // Back from Settings after a permanently-denied prompt: finish what the
    // user started and select current location.
    if (_returningFromSettings) {
      _returningFromSettings = false;
      if (granted) {
        state = state.copyWith(
          selectedSource: () => AddressSource.currentLocation,
        );
      }
    }
  }

  /// Set when the user is sent to system Settings to grant location; read
  /// on resume by [refreshLocationPermissionStatus].
  bool _returningFromSettings = false;

  /// Calls GET /user/get-service-address. A connection, timeout or server
  /// failure sets [ApiStatus.error] (the screen offers Retry) and keeps any
  /// address already loaded. Any other failure means "no address saved
  /// yet", which is an expected state on a fresh account.
  Future<void> fetchAddress() async {
    state = state.copyWith(status: ApiStatus.loading);
    final result = await _addressRepository.getServiceAddress();
    if (!ref.mounted) return;

    switch (result) {
      case ApiSuccess(data: final data):
        state = state.copyWith(
          address: () => data,
          selectedSource: () => AddressSource.savedAddress,
          status: ApiStatus.successful,
        );
      case ApiError(failure: final failure) when _isTransient(failure):
        state = state.copyWith(status: ApiStatus.error);
      case ApiError():
        state = state.copyWith(
          address: () => null,
          selectedSource: () => null,
          status: ApiStatus.successful,
        );
    }
  }

  /// Failures worth retrying, as opposed to "there's nothing saved".
  static bool _isTransient(ApiFailure failure) => switch (failure.type) {
    ApiFailureType.network ||
    ApiFailureType.timeout ||
    ApiFailureType.server => true,
    _ => false,
  };

  /// Selects whatever is showing in the "CHOOSE YOUR ADDRESS" card — the
  /// staged manual entry if there is one, otherwise the already-saved
  /// address. No-op if neither exists yet.
  void selectCardAddress() {
    if (state.pendingManualAddress != null) {
      state = state.copyWith(selectedSource: () => AddressSource.manualEntry);
    } else if (state.hasAddress) {
      state = state.copyWith(selectedSource: () => AddressSource.savedAddress);
    }
  }

  /// Stages a manually-entered address (from the Add Address form) as the
  /// selected source, without saving it yet — the actual POST happens when
  /// the user confirms with Next (see [confirmAndProceed]).
  void setManualEntry(ServiceAddressRequest request) {
    state = state.copyWith(
      pendingManualAddress: () => request,
      selectedSource: () => AddressSource.manualEntry,
    );
  }

  /// Handles a tap on "Use my Current Location" (the Enable pill, or the
  /// radio once permission is already granted): if permission is already
  /// granted, this just *selects* current location as the chosen source —
  /// it does not fetch or save anything — and returns true. If permission
  /// isn't granted yet it returns false, and the screen shows the Location
  /// Accuracy dialog; selection happens once that's granted (see
  /// [requestLocationPermission]). The actual fetch + save only happens
  /// when the user confirms with Next.
  Future<bool> onCurrentLocationTap() async {
    if (state.isFetchingLocation) return true;

    final permissionStatus = await Permission.location.status;
    if (!ref.mounted) return true;
    state = state.copyWith(hasLocationPermission: permissionStatus.isGranted);
    if (permissionStatus.isGranted) {
      state = state.copyWith(
        selectedSource: () => AddressSource.currentLocation,
      );
      return true;
    }
    return false;
  }

  /// Logic to request location permission from the system.
  /// Handles different states: Granted, Denied, and Permanently Denied.
  /// Returns true when the Location Accuracy dialog should close.
  Future<bool> requestLocationPermission() async {
    // Permission.location requests both FINE and COARSE location on Android
    final permissionStatus = await Permission.location.request();

    if (permissionStatus.isGranted) {
      debugPrint("Location permission granted");
      if (ref.mounted) {
        state = state.copyWith(
          hasLocationPermission: true,
          selectedSource: () => AddressSource.currentLocation,
        );
      }
      return true;
    } else if (permissionStatus.isPermanentlyDenied) {
      // The system won't ask again, so send the user to Settings. When the
      // app resumes, refreshLocationPermissionStatus selects current
      // location if they granted it.
      _returningFromSettings = true;
      CustomSnackBar.showInfo(
        title: "Location permission",
        message:
            "Allow location for Urban Service in Settings, then come back.",
      );
      await openAppSettings();
      return true;
    } else if (permissionStatus.isDenied) {
      // Close the dialog and say why nothing happened; the user can tap
      // "Use my Current Location" again to be asked again.
      CustomSnackBar.showError(
        title: "Permission Required",
        message: "Location permission is needed to use your current location.",
      );
      return true;
    }
    return true; // Default fallback to close dialog
  }

  /// Gets the device's current position, reverse-geocodes it into an
  /// address, and saves it via POST /user/service-address. Returns true on
  /// success, false otherwise (an error toast is already shown by then).
  Future<bool> _fetchAndSaveCurrentLocation() async {
    if (state.isFetchingLocation) return false;
    state = state.copyWith(isFetchingLocation: true);

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
        locationSettings: currentLocationSettings,
      );

      // Prefer Google's Geocoding API (server-side, much more accurate)
      // and only fall back to the on-device geocoder if it isn't
      // configured yet or the call fails for any reason.
      final googleResult = await GoogleGeocodingService.instance.reverseGeocode(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      String fullAddress;
      String city;
      String addressState;
      String pincode;

      if (googleResult != null && googleResult.formattedAddress.isNotEmpty) {
        fullAddress = googleResult.formattedAddress;
        city = googleResult.city;
        addressState = googleResult.state;
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
        addressState = place.administrativeArea ?? '';
        pincode = place.postalCode ?? '';
      }

      if (!ref.mounted) return false;
      final userId = ref.read(sessionProvider).userId;
      if (userId == null) {
        CustomSnackBar.showError(
          title: "Error",
          message: "You're not logged in. Please log in again.",
        );
        return false;
      }

      final request = ServiceAddressRequest(
        fullAddress: fullAddress.isNotEmpty
            ? fullAddress
            : '$city, $addressState',
        city: city,
        state: addressState,
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
          if (ref.mounted) await fetchAddress();
          return true;
        case ApiError(failure: final failure):
          CustomSnackBar.showError(title: "Error", message: failure.message);
          return false;
      }
    } on TimeoutException {
      showLocationTimeout();
      return false;
    } catch (e) {
      debugPrint("AddressNotifier - current location error: $e");
      CustomSnackBar.showError(
        title: "Error",
        message: "Couldn't get your current location. Please try again.",
      );
      return false;
    } finally {
      if (ref.mounted) state = state.copyWith(isFetchingLocation: false);
    }
  }

  /// Called when the user taps Next. Commits whichever source is selected
  /// — for the saved address that's already done, for current location
  /// this is the one point where a GPS fetch + save actually happens.
  /// Returns true when it's safe to navigate to Home.
  Future<bool> confirmAndProceed() async {
    switch (state.selectedSource) {
      case AddressSource.savedAddress:
        return state.hasAddress;
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
    final request = state.pendingManualAddress;
    if (request == null || state.isSavingManualEntry) return false;

    state = state.copyWith(isSavingManualEntry: true);
    try {
      final result = await _addressRepository.saveServiceAddress(request);
      switch (result) {
        case ApiSuccess(data: final data):
          CustomSnackBar.showSuccess(
            title: "Success",
            message: data.message ?? "Service address saved successfully.",
          );
          if (ref.mounted) {
            state = state.copyWith(pendingManualAddress: () => null);
            await fetchAddress();
          }
          return true;
        case ApiError(failure: final failure):
          CustomSnackBar.showError(title: "Error", message: failure.message);
          return false;
      }
    } finally {
      if (ref.mounted) state = state.copyWith(isSavingManualEntry: false);
    }
  }
}

final addressProvider =
    NotifierProvider.autoDispose<AddressNotifier, AddressState>(
      AddressNotifier.new,
    );
