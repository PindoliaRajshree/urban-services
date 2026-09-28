// File: lib/features/address/add_address_screen.dart
// Purpose: Form screen for users to input and save a new service address.

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_text_sizes.dart';
import 'package:urban_services/features/address/add_address_provider.dart';
import 'package:urban_services/features/address/models/service_address_response.dart';
import 'package:urban_services/routes/route_names.dart';
import 'package:urban_services/widgets/address_form_field.dart';
import 'package:urban_services/widgets/common_app_bar.dart';
import 'package:urban_services/widgets/custom_text_style.dart';
import 'package:urban_services/widgets/primary_button.dart';

class AddAddressScreen extends ConsumerStatefulWidget {
  const AddAddressScreen({super.key, this.initialAddress});

  /// Saved address to prefill the form with when changing it (passed as
  /// the route's `extra` by AddressChoiceDialog).
  final ServiceAddressResponse? initialAddress;

  @override
  ConsumerState<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends ConsumerState<AddAddressScreen> {
  // Text editing controllers for capturing user input
  final _flatController = TextEditingController();
  final _floorController = TextEditingController();
  final _buildingController = TextEditingController();
  final _fullAddressController = TextEditingController();
  final _landmarkController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();

  // Focus nodes for managing keyboard focus flow
  final _flatFocus = FocusNode();
  final _floorFocus = FocusNode();
  final _buildingFocus = FocusNode();
  final _fullAddressFocus = FocusNode();
  final _landmarkFocus = FocusNode();
  final _cityFocus = FocusNode();
  final _stateFocus = FocusNode();
  final _pincodeFocus = FocusNode();

  GoogleMapController? _mapController;

  AddAddressNotifier get _notifier =>
      ref.read(addAddressProvider(widget.initialAddress).notifier);

  @override
  void initState() {
    super.initState();
    // Prefill the form when editing an existing address.
    final existing = widget.initialAddress;
    if (existing != null) {
      _flatController.text = existing.flatApartment ?? '';
      _floorController.text = existing.floorBuilding ?? '';
      _buildingController.text = existing.buildingSocietyLandmark ?? '';
      _fullAddressController.text = existing.fullAddress ?? '';
      _landmarkController.text = existing.landmark ?? '';
      _cityController.text = existing.city ?? '';
      _stateController.text = existing.state ?? '';
      _pincodeController.text = existing.pincode ?? '';
    }
  }

  @override
  void dispose() {
    // Standard cleanup of controllers and nodes to prevent memory leaks
    for (final c in [
      _flatController,
      _floorController,
      _buildingController,
      _fullAddressController,
      _landmarkController,
      _cityController,
      _stateController,
      _pincodeController,
    ]) {
      c.dispose();
    }
    for (final f in [
      _flatFocus,
      _floorFocus,
      _buildingFocus,
      _fullAddressFocus,
      _landmarkFocus,
      _cityFocus,
      _stateFocus,
      _pincodeFocus,
    ]) {
      f.dispose();
    }
    _mapController?.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController mapController) {
    _mapController = mapController;
  }

  /// Writes reverse-geocoded values into the fields (null = keep).
  void _applyFill(AddressFill? fill) {
    if (fill == null || !mounted) return;
    final AddressFill(:fullAddress, :city, :state, :pincode) = fill;
    if (fullAddress != null) _fullAddressController.text = fullAddress;
    if (city != null) _cityController.text = city;
    if (state != null) _stateController.text = state;
    if (pincode != null) _pincodeController.text = pincode;
  }

  /// Moves the map/marker to [latLng] and reverse-geocodes it into the
  /// Full Address / City / State / Pincode fields. Used for map taps and
  /// the full-screen picker.
  Future<void> _applyLatLng(LatLng latLng) async {
    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 16));
    _applyFill(await _notifier.applyLatLng(latLng));
  }

  Future<void> _useCurrentLocationOnMap() async {
    final fill = await _notifier.useCurrentLocationOnMap(
      onLocated: (latLng) =>
          _mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 16)),
    );
    _applyFill(fill);
  }

  void _saveAddress() {
    final saved = _notifier.saveAddress(
      AddAddressForm(
        flat: _flatController.text,
        floor: _floorController.text,
        building: _buildingController.text,
        fullAddress: _fullAddressController.text,
        landmark: _landmarkController.text,
        city: _cityController.text,
        state: _stateController.text,
        pincode: _pincodeController.text,
      ),
    );
    if (saved) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addAddressProvider(widget.initialAddress));

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppDimensions.padding20w),
          child: Column(
            children: [
              // Standard AppBar with "Add New Address" title
              const CommonAppBar(title: 'Add New Address', showMoreIcon: false),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Quick Action: Use Current Location — reverse
                      // geocodes the device's position onto the map and
                      // prefills Full Address / City / State / Pincode.
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDimensions.padding12w,
                        ),
                        child: GestureDetector(
                          onTap: state.isLocatingOnMap
                              ? null
                              : _useCurrentLocationOnMap,
                          child: Row(
                            children: [
                              state.isLocatingOnMap
                                  ? SizedBox(
                                      height: AppDimensions.containerHeight15h,
                                      width: AppDimensions.containerWidth15w,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Icon(
                                      Icons.my_location,
                                      color: AppColors.primary,
                                      size: AppDimensions.containerHeight15h,
                                    ),
                              SizedBox(width: AppDimensions.padding8w),
                              Text(
                                'Use Current Location',
                                style: customTextStyle(
                                  AppTextSizes.stableTextSize,
                                  AppColors.black,
                                  FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: AppDimensions.padding15h),

                      // Live Google Map — tap anywhere to drop the pin
                      // there, or use "Use Current Location" above/on the
                      // map, or tap the expand icon for a full-screen,
                      // easier-to-use picker. All three reverse-geocode
                      // the picked point into the fields below.
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDimensions.padding12w,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radius18r,
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            height: AppDimensions.containerHeight280h,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                GoogleMap(
                                  initialCameraPosition: CameraPosition(
                                    target: state.initialMapPosition,
                                    zoom: state.selectedPosition == null
                                        ? 4
                                        : 16,
                                  ),
                                  onMapCreated: _onMapCreated,
                                  onTap: _applyLatLng,
                                  markers: state.selectedPosition == null
                                      ? const {}
                                      : {
                                          Marker(
                                            markerId: const MarkerId(
                                              'selected-address',
                                            ),
                                            position: state.selectedPosition!,
                                          ),
                                        },
                                  myLocationButtonEnabled: false,
                                  zoomControlsEnabled: false,
                                  gestureRecognizers: {
                                    Factory<EagerGestureRecognizer>(
                                      () => EagerGestureRecognizer(),
                                    ),
                                  },
                                ),

                                // Shown while a tapped position is being
                                // turned into address fields.
                                if (state.isGeocoding)
                                  Positioned(
                                    top: AppDimensions.padding10h,
                                    left: AppDimensions.padding10w,
                                    child: Container(
                                      padding: EdgeInsets.all(
                                        AppDimensions.padding8h,
                                      ),
                                      decoration: const BoxDecoration(
                                        color: AppColors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: SizedBox(
                                        height:
                                            AppDimensions.containerHeight18h,
                                        width: AppDimensions.containerWidth18w,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    ),
                                  ),

                                // Expand / fullscreen button.
                                Positioned(
                                  top: AppDimensions.padding10h,
                                  right: AppDimensions.padding10w,
                                  child: _MapIconButton(
                                    icon: Icons.open_in_full,
                                    onTap: () async {
                                      final result = await context.push<LatLng>(
                                        RouteNames.mapPicker,
                                        extra: state.selectedPosition,
                                      );
                                      if (result != null) {
                                        await _applyLatLng(result);
                                      }
                                    },
                                  ),
                                ),

                                // On-map "get current location" button.
                                Positioned(
                                  bottom: AppDimensions.padding10h,
                                  right: AppDimensions.padding10w,
                                  child: _MapIconButton(
                                    icon: Icons.my_location,
                                    isLoading: state.isLocatingOnMap,
                                    onTap: state.isLocatingOnMap
                                        ? null
                                        : _useCurrentLocationOnMap,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: AppDimensions.padding20h),

                      // --- ADDRESS FORM SECTION ---

                      // Flat / Apartment Input
                      AddressFormField(
                        label: 'Flat/Apartment/Suite',
                        hintText: 'eg 101, A Wing Green Readency',
                        controller: _flatController,
                        focusNode: _flatFocus,
                        textInputAction: TextInputAction.next,
                        errorText: state.flatError,
                      ),
                      SizedBox(height: AppDimensions.padding15h),

                      // Floor / Building Input
                      AddressFormField(
                        label: 'Floor/Building',
                        hintText: 'eg. 2nd Floor',
                        controller: _floorController,
                        focusNode: _floorFocus,
                        textInputAction: TextInputAction.next,
                        errorText: state.floorError,
                      ),
                      SizedBox(height: AppDimensions.padding15h),

                      // Building / Society / Landmark Input
                      AddressFormField(
                        label: 'Building/Society/Landmark',
                        hintText: 'eg. Indus Business School',
                        controller: _buildingController,
                        focusNode: _buildingFocus,
                        textInputAction: TextInputAction.next,
                        errorText: state.buildingError,
                      ),
                      SizedBox(height: AppDimensions.padding15h),

                      // Full Address Input (Multi-line)
                      AddressFormField(
                        label: 'Full Address',
                        hintText:
                            'REBM, Indus Business School, Tonk Phatak Jaipur, Rajasthan-302015',
                        controller: _fullAddressController,
                        focusNode: _fullAddressFocus,
                        maxLines: 3,
                        textInputAction: TextInputAction.next,
                        errorText: state.fullAddressError,
                      ),
                      SizedBox(height: AppDimensions.padding15h),

                      // Optional Landmark Input
                      AddressFormField(
                        label: 'Landmark (Optional)',
                        hintText: 'eg. Near Tonk Phatak',
                        controller: _landmarkController,
                        focusNode: _landmarkFocus,
                        textInputAction: TextInputAction.next,
                      ),
                      SizedBox(height: AppDimensions.padding15h),

                      // City Input
                      AddressFormField(
                        label: 'City',
                        hintText: 'eg. Jaipur',
                        controller: _cityController,
                        focusNode: _cityFocus,
                        textInputAction: TextInputAction.next,
                        errorText: state.cityError,
                      ),
                      SizedBox(height: AppDimensions.padding15h),

                      // State Input
                      AddressFormField(
                        label: 'State',
                        hintText: 'eg. Rajasthan',
                        controller: _stateController,
                        focusNode: _stateFocus,
                        textInputAction: TextInputAction.next,
                        errorText: state.stateError,
                      ),
                      SizedBox(height: AppDimensions.padding15h),

                      // Pincode Input
                      AddressFormField(
                        label: 'Pincode',
                        hintText: 'eg. 302015',
                        controller: _pincodeController,
                        focusNode: _pincodeFocus,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        errorText: state.pincodeError,
                      ),

                      SizedBox(height: AppDimensions.padding15h),

                      // Settings: Save as Default Address
                      Row(
                        children: [
                          Checkbox(
                            value: state.isDefault,
                            onChanged: (val) =>
                                _notifier.setDefault(val ?? false),
                            activeColor: AppColors.primary,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: const VisualDensity(
                              horizontal: -4,
                              vertical: -4,
                            ),
                          ),
                          SizedBox(width: AppDimensions.padding8w),
                          Text(
                            'Save as default address',
                            style: customTextStyle(
                              AppTextSizes.smallTextSize,
                              AppColors.text,
                              FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: AppDimensions.padding30h),

                      // Primary Action: Save address and navigate
                      PrimaryButton(
                        text: 'Save',
                        isLoading: state.isLoading,
                        onPressed: _saveAddress,
                      ),

                      SizedBox(height: AppDimensions.padding30h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small round icon button used for the overlay controls on top of the
/// map (expand / current-location) — kept local to this screen since it
/// isn't reused elsewhere.
class _MapIconButton extends StatelessWidget {
  const _MapIconButton({
    required this.icon,
    required this.onTap,
    this.isLoading = false,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      shape: const CircleBorder(),
      elevation: 3,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.padding8w),
          child: isLoading
              ? SizedBox(
                  height: AppDimensions.containerHeight18h,
                  width: AppDimensions.containerWidth18w,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  icon,
                  color: AppColors.primary,
                  size: AppDimensions.containerHeight20h,
                ),
        ),
      ),
    );
  }
}
