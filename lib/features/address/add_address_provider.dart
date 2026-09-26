// File: lib/features/address/add_address_provider.dart
// Purpose: State management and validation logic for the Add New Address
// form. saveAddress() stages the validated address onto the shared
// AddressNotifier (see AddressNotifier.setManualEntry) and returns to
// "Select Your Service Address" — that screen's Next button is the single
// place that actually POSTs /user/service-address, whether the address
// came from current location or here. User-only — providers never reach
// this screen.

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:urban_services/core/constants/api_status.dart';
import 'package:urban_services/core/session/session_provider.dart';
import 'package:urban_services/features/address/address_provider.dart';
import 'package:urban_services/features/address/models/service_address_request.dart';
import 'package:urban_services/features/address/models/service_address_response.dart';
import 'package:urban_services/features/address/services/google_geocoding_service.dart';
import 'package:urban_services/widgets/custom_snackbar.dart';

/// Default map center (India) used until the user picks a real location.
const LatLng defaultMapCenter = LatLng(20.5937, 78.9629);

/// Raw form values, read from the screen's TextEditingControllers.
class AddAddressForm {
  const AddAddressForm({
    required this.flat,
    required this.floor,
    required this.building,
    required this.fullAddress,
    required this.landmark,
    required this.city,
    required this.state,
    required this.pincode,
  });

  final String flat;
  final String floor;
  final String building;
  final String fullAddress;
  final String landmark;
  final String city;
  final String state;
  final String pincode;
}

/// Reverse-geocoded values to write into the form. A null field means
/// "leave what the user already has".
class AddressFill {
  const AddressFill({this.fullAddress, this.city, this.state, this.pincode});

  final String? fullAddress;
  final String? city;
  final String? state;
  final String? pincode;
}

class AddAddressState {
  const AddAddressState({
    this.selectedPosition,
    this.isLocatingOnMap = false,
    this.flatError,
    this.floorError,
    this.buildingError,
    this.fullAddressError,
    this.cityError,
    this.stateError,
    this.pincodeError,
    this.isDefault = false,
    this.status = ApiStatus.initial,
  });

  final LatLng? selectedPosition;
  final bool isLocatingOnMap;

  // Validation errors for real-time feedback
  final String? flatError;
  final String? floorError;
  final String? buildingError;
  final String? fullAddressError;
  final String? cityError;
  final String? stateError;
  final String? pincodeError;

  /// "Save as default" checkbox state
  final bool isDefault;

  /// Tracks the save action so the UI can disable the Save button and show
  /// a loading state.
  final ApiStatus status;

  bool get isLoading => status == ApiStatus.loading;

  LatLng get initialMapPosition => selectedPosition ?? defaultMapCenter;

  AddAddressState copyWith({
    LatLng? selectedPosition,
    bool? isLocatingOnMap,
    bool? isDefault,
    ApiStatus? status,
  }) => AddAddressState(
    selectedPosition: selectedPosition ?? this.selectedPosition,
    isLocatingOnMap: isLocatingOnMap ?? this.isLocatingOnMap,
    flatError: flatError,
    floorError: floorError,
    buildingError: buildingError,
    fullAddressError: fullAddressError,
    cityError: cityError,
    stateError: stateError,
    pincodeError: pincodeError,
    isDefault: isDefault ?? this.isDefault,
    status: status ?? this.status,
  );
}

class AddAddressNotifier extends Notifier<AddAddressState> {
  AddAddressNotifier(this.existing);

  /// Address being edited (passed by AddressChoiceDialog), used to prefill
  /// the map pin and "default" flag. The text fields are prefilled by the
  /// screen.
  final ServiceAddressResponse? existing;

  @override
  AddAddressState build() {
    final existing = this.existing;
    return AddAddressState(
      isDefault: existing?.isDefault ?? false,
      selectedPosition:
          existing?.latitude != null && existing?.longitude != null
          ? LatLng(existing!.latitude!, existing.longitude!)
          : null,
    );
  }

  void setDefault(bool value) => state = state.copyWith(isDefault: value);

  /// Gets the device's current position and returns the address fields
  /// (full address, city, state, pincode) for it via reverse geocoding.
  /// Flat/Floor/Building aren't part of standard reverse-geocoding data, so
  /// those are left for the user to fill in. Returns null when nothing
  /// should change (an error toast has been shown).
  ///
  /// [onLocated] runs as soon as the position is known (before geocoding),
  /// so the screen can move the map camera straight away.
  Future<AddressFill?> useCurrentLocationOnMap({
    void Function(LatLng latLng)? onLocated,
  }) async {
    if (state.isLocatingOnMap) return null;
    state = state.copyWith(isLocatingOnMap: true);

    try {
      var permissionStatus = await Permission.location.status;
      if (!permissionStatus.isGranted) {
        permissionStatus = await Permission.location.request();
      }
      if (!permissionStatus.isGranted) {
        CustomSnackBar.showError(
          title: "Permission Required",
          message:
              "Location permission is needed to use your current location.",
        );
        return null;
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        CustomSnackBar.showError(
          title: "Location Off",
          message: "Please turn on location services and try again.",
        );
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      if (!ref.mounted) return null;
      final latLng = LatLng(position.latitude, position.longitude);
      onLocated?.call(latLng);
      return await applyLatLng(latLng);
    } catch (e) {
      debugPrint("AddAddressNotifier - current location error: $e");
      CustomSnackBar.showError(
        title: "Error",
        message: "Couldn't get your current location. Please try again.",
      );
      return null;
    } finally {
      if (ref.mounted) state = state.copyWith(isLocatingOnMap: false);
    }
  }

  /// Moves the marker to [latLng] and reverse-geocodes it into Full
  /// Address / City / State / Pincode values. Used for map taps, the
  /// full-screen picker and "Use Current Location". The screen animates the
  /// camera and writes the returned values into its text fields.
  Future<AddressFill?> applyLatLng(LatLng latLng) async {
    state = state.copyWith(selectedPosition: latLng);

    try {
      // Prefer Google's Geocoding API (server-side, much more accurate)
      // and only fall back to the on-device geocoder if it isn't
      // configured yet or the call fails for any reason.
      final googleResult = await GoogleGeocodingService.instance.reverseGeocode(
        latitude: latLng.latitude,
        longitude: latLng.longitude,
      );

      if (googleResult != null && googleResult.formattedAddress.isNotEmpty) {
        return AddressFill(
          fullAddress: googleResult.formattedAddress,
          city: googleResult.city.isNotEmpty ? googleResult.city : null,
          state: googleResult.state.isNotEmpty ? googleResult.state : null,
          pincode: googleResult.pincode.isNotEmpty
              ? googleResult.pincode
              : null,
        );
      }

      final placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );
      if (placemarks.isEmpty) return null;

      final place = placemarks.first;
      final fullAddress = [
        place.name,
        place.subLocality,
        place.thoroughfare,
        place.locality,
      ].where((part) => part != null && part.trim().isNotEmpty).join(', ');

      return AddressFill(
        fullAddress: fullAddress.isNotEmpty ? fullAddress : null,
        city: place.locality,
        state: place.administrativeArea,
        pincode: place.postalCode,
      );
    } catch (e) {
      debugPrint("AddAddressNotifier - reverse geocode error: $e");
      CustomSnackBar.showError(
        title: "Error",
        message: "Couldn't determine the address for that location.",
      );
      return null;
    }
  }

  /// Validates all required form fields.
  /// Returns [true] if all fields are valid, [false] otherwise.
  bool validate(AddAddressForm form) {
    String? required(String value, String message) =>
        value.trim().isEmpty ? message : null;

    final next = AddAddressState(
      selectedPosition: state.selectedPosition,
      isLocatingOnMap: state.isLocatingOnMap,
      isDefault: state.isDefault,
      status: state.status,
      flatError: required(form.flat, "Flat/Apartment is required"),
      floorError: required(form.floor, "Floor/Building is required"),
      buildingError: required(form.building, "Building/Society is required"),
      fullAddressError: required(form.fullAddress, "Full Address is required"),
      cityError: required(form.city, "City is required"),
      stateError: required(form.state, "State is required"),
      pincodeError: required(form.pincode, "Pincode is required"),
    );
    state = next;

    return [
      next.flatError,
      next.floorError,
      next.buildingError,
      next.fullAddressError,
      next.cityError,
      next.stateError,
      next.pincodeError,
    ].every((e) => e == null);
  }

  /// Validates the form and stages the address onto the shared
  /// AddressNotifier, without saving anything yet — the "Select Your
  /// Service Address" screen's Next button is what actually POSTs
  /// /user/service-address (see AddressNotifier.confirmAndProceed /
  /// setManualEntry). Returns true when the screen should close.
  bool saveAddress(AddAddressForm form) {
    if (state.isLoading) return false;
    if (!validate(form)) return false;

    final userId = ref.read(sessionProvider).userId;
    if (userId == null) {
      state = state.copyWith(status: ApiStatus.error);
      CustomSnackBar.showError(
        title: "Error",
        message: "You're not logged in. Please log in again.",
      );
      return false;
    }

    final request = ServiceAddressRequest(
      fullAddress: form.fullAddress.trim(),
      city: form.city.trim(),
      state: form.state.trim(),
      pincode: form.pincode.trim(),
      userId: userId,
      flatApartment: form.flat.trim(),
      floorBuilding: form.floor.trim(),
      buildingSocietyLandmark: form.building.trim(),
      landmark: form.landmark.trim(),
    );

    state = state.copyWith(status: ApiStatus.successful);
    ref.read(addressProvider.notifier).setManualEntry(request);
    return true;
  }
}

final addAddressProvider = NotifierProvider.autoDispose
    .family<AddAddressNotifier, AddAddressState, ServiceAddressResponse?>(
      AddAddressNotifier.new,
    );
