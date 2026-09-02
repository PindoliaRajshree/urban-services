// File: lib/features/address/full_screen_map_picker.dart
// Purpose: A full-screen version of the location picker used from the Add
// New Address screen's "enlarge" button. Lets the user pan/zoom/tap on a
// large map or jump to their current location, then confirms a single
// LatLng back to the caller via Get.back(result: ...).
//
// Pushed directly with Get.to() (no named route needed) so it stays a
// self-contained picker rather than a first-class app screen.

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_text_sizes.dart';
import 'package:urban_services/widgets/custom_snackbar.dart';
import 'package:urban_services/widgets/custom_text_style.dart';

class FullScreenMapPicker extends StatefulWidget {
  const FullScreenMapPicker({super.key, this.initialPosition});

  /// Where to center the map on open — the address's existing pin if
  /// there is one, otherwise the caller falls back to the default center.
  final LatLng? initialPosition;

  @override
  State<FullScreenMapPicker> createState() => _FullScreenMapPickerState();
}

class _FullScreenMapPickerState extends State<FullScreenMapPicker> {
  GoogleMapController? _mapController;
  LatLng? _selected;
  bool _isLocating = false;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialPosition;
  }

  Future<void> _useCurrentLocation() async {
    if (_isLocating) return;
    setState(() => _isLocating = true);

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
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      final latLng = LatLng(position.latitude, position.longitude);
      setState(() => _selected = latLng);
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 17));
    } catch (e) {
      debugPrint("FullScreenMapPicker - current location error: $e");
      CustomSnackBar.showError(
        title: "Error",
        message: "Couldn't get your current location. Please try again.",
      );
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const defaultCenter = LatLng(20.5937, 78.9629);
    final startPosition = _selected ?? widget.initialPosition ?? defaultCenter;

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: Stack(
        fit: StackFit.expand,
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: startPosition,
              zoom: _selected == null ? 4 : 16,
            ),
            onMapCreated: (controller) => _mapController = controller,
            onTap: (position) => setState(() => _selected = position),
            markers: _selected == null
                ? const {}
                : {
                    Marker(
                      markerId: const MarkerId('picked-location'),
                      position: _selected!,
                    ),
                  },
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),

          // Back button
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(AppDimensions.padding12w),
              child: CircleAvatar(
                backgroundColor: AppColors.white,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: AppColors.black),
                  onPressed: () => Get.back(),
                ),
              ),
            ),
          ),

          // On-map "get current location" control.
          Positioned(
            right: AppDimensions.padding16w,
            bottom: AppDimensions.padding100h,
            child: FloatingActionButton(
              heroTag: 'fullScreenMapCurrentLocation',
              backgroundColor: AppColors.white,
              onPressed: _isLocating ? null : _useCurrentLocation,
              child: _isLocating
                  ? SizedBox(
                      height: AppDimensions.containerHeight20h,
                      width: AppDimensions.containerWidth20w,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(Icons.my_location, color: AppColors.primary),
            ),
          ),

          // Confirm bar
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(AppDimensions.padding16w),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(
                        vertical: AppDimensions.padding15h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radius12r,
                        ),
                      ),
                    ),
                    onPressed: _selected == null
                        ? null
                        : () => Get.back(result: _selected),
                    child: Text(
                      'Confirm Location',
                      style: customTextStyle(
                        AppTextSizes.stableTextSize,
                        AppColors.white,
                        FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
