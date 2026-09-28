// File: lib/core/location/location_helper.dart
// Purpose: One place for "get my current position": asks for permission,
// checks that location services are on, and gives up after
// [locationTimeLimit] instead of spinning forever. Failures are shown as a
// snackbar, so callers only handle the null result.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:urban_services/widgets/custom_snackbar.dart';

/// How long to wait for a GPS fix before giving up.
const Duration locationTimeLimit = Duration(seconds: 15);

/// Settings for every current-position request in the app.
const LocationSettings currentLocationSettings = LocationSettings(
  accuracy: LocationAccuracy.high,
  timeLimit: locationTimeLimit,
);

/// Requests permission if needed, then returns the current position, or
/// null (after telling the user why) when it can't be determined.
Future<Position?> currentPositionOrNotify() async {
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
      return null;
    }

    if (!await Geolocator.isLocationServiceEnabled()) {
      CustomSnackBar.showError(
        title: "Location Off",
        message: "Please turn on location services and try again.",
      );
      return null;
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: currentLocationSettings,
    );
  } on TimeoutException {
    showLocationTimeout();
    return null;
  } catch (e) {
    debugPrint("currentPositionOrNotify error: $e");
    CustomSnackBar.showError(
      title: "Error",
      message: "Couldn't get your current location. Please try again.",
    );
    return null;
  }
}

/// Shown when a GPS fix takes longer than [locationTimeLimit].
void showLocationTimeout() => CustomSnackBar.showError(
  title: "Taking too long",
  message:
      "Couldn't get a location fix. Move somewhere with a clearer view of "
      "the sky, or enter the address manually.",
);
