// File: lib/features/address/address_screen.dart
// Purpose: Screen for displaying the user's selected address and providing options to change it or use current location.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/api_status.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_images.dart';
import 'package:urban_services/core/constants/app_text_sizes.dart';
import 'package:urban_services/features/address/address_provider.dart';
import 'package:urban_services/routes/route_names.dart';
import 'package:urban_services/widgets/address_choice_dialog.dart';
import 'package:urban_services/widgets/custom_text_style.dart';
import 'package:urban_services/widgets/location_accuracy_dialog.dart';
import 'package:urban_services/widgets/primary_button.dart';

class AddressScreen extends ConsumerStatefulWidget {
  const AddressScreen({super.key, this.manage = false});

  /// Opened to change the address (from Profile or Home) rather than
  /// during onboarding: shows a back button, and pops after saving
  /// instead of going to Home.
  final bool manage;

  @override
  ConsumerState<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends ConsumerState<AddressScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Re-checks location permission when the app resumes (e.g. the user
  /// granted it from system Settings after being sent there for a
  /// permanently-denied prompt) so the row switches from "Enable" to the
  /// radio button without needing a manual retry.
  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    if (lifecycleState == AppLifecycleState.resumed) {
      ref.read(addressProvider.notifier).refreshLocationPermissionStatus();
    }
  }

  void _showAddressChoice() => showDialog<void>(
    context: context,
    builder: (_) =>
        AddressChoiceDialog(onUseCurrentLocation: _onCurrentLocationTap),
  );

  /// Selects current location when permission is already granted,
  /// otherwise asks for it via the Location Accuracy dialog first.
  Future<void> _onCurrentLocationTap() async {
    final selected = await ref
        .read(addressProvider.notifier)
        .onCurrentLocationTap();
    if (!selected && mounted) {
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const LocationAccuracyDialog(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addressProvider);

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Top Image Section: Vector background with Address Image overlay
              SizedBox(
                width: double.infinity,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    // Base vector image
                    Image.asset(
                      AppImages.vector,
                      width: double.infinity,
                      fit: BoxFit.fitWidth,
                    ),

                    // Overlaid address image with specific top padding
                    Padding(
                      padding: EdgeInsets.only(top: AppDimensions.padding70h),
                      child: Image.asset(
                        AppImages.addressImage,
                        height: AppDimensions.containerHeight200h,
                        fit: BoxFit.contain,
                      ),
                    ),

                    if (widget.manage)
                      Positioned(
                        top: AppDimensions.padding15h,
                        left: AppDimensions.padding20w,
                        child: GestureDetector(
                          onTap: () => context.pop(),
                          child: Image.asset(
                            AppImages.back,
                            height: AppDimensions.containerHeight24h,
                            width: AppDimensions.containerWidth24w,
                            color: AppColors.text,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.padding20w,
                ),
                child: Column(
                  children: [
                    SizedBox(height: AppDimensions.padding20h),

                    // 1. Title Section
                    Text(
                      'Select Your Service Address',
                      textAlign: TextAlign.center,
                      style: customTextStyle(
                        AppTextSizes.headingTextSize,
                        AppColors.black,
                        FontWeight.w600,
                      ),
                    ),

                    SizedBox(height: AppDimensions.padding10h),

                    // 2. Gradient Divider
                    Container(
                      width: AppDimensions.containerWidth75w,
                      height: AppDimensions.containerHeight5h,
                      decoration: BoxDecoration(
                        gradient: AppColors.gradient,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radius10r,
                        ),
                      ),
                    ),

                    SizedBox(height: AppDimensions.padding15h),

                    // 3. Description Section
                    Text(
                      'Choose the address where you want the service to be provided.',
                      textAlign: TextAlign.center,
                      style: customTextStyle(
                        AppTextSizes.largeTextSize,
                        AppColors.black,
                        FontWeight.w400,
                      ),
                    ),

                    SizedBox(height: AppDimensions.padding20h),

                    // 4. Current Location Action Container
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radius5r,
                        ),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.padding15w,
                        vertical: AppDimensions.padding10h,
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            AppImages.placeMarker,
                            height: AppDimensions.containerHeight18h,
                            width: AppDimensions.containerWidth18w,
                          ),
                          SizedBox(width: AppDimensions.padding10w),
                          Text(
                            'Use my Current Location',
                            style: customTextStyle(
                              AppTextSizes.smallTextSize,
                              AppColors.black,
                              FontWeight.w400,
                            ),
                          ),
                          const Spacer(),

                          // Selection control: shows the "Enable" pill only
                          // while location permission hasn't been granted
                          // yet (tapping opens the Location Accuracy
                          // dialog). Once granted, it becomes a plain radio
                          // button — tapping it goes straight to
                          // fetch + save, no separate "Enable" step needed.
                          Builder(
                            builder: (context) {
                              if (state.isFetchingLocation) {
                                return SizedBox(
                                  height: AppDimensions.containerHeight18h,
                                  width: AppDimensions.containerWidth18w,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                );
                              }

                              if (state.hasLocationPermission) {
                                final isSelected =
                                    state.selectedSource ==
                                    AddressSource.currentLocation;
                                return GestureDetector(
                                  onTap: _onCurrentLocationTap,
                                  child: Container(
                                    height: AppDimensions.containerHeight18h,
                                    width: AppDimensions.containerWidth18w,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.primary,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: isSelected
                                        ? Container(
                                            height:
                                                AppDimensions
                                                    .containerHeight18h *
                                                0.5,
                                            width:
                                                AppDimensions
                                                    .containerWidth18w *
                                                0.5,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: AppColors.primary,
                                            ),
                                          )
                                        : null,
                                  ),
                                );
                              }

                              return GestureDetector(
                                onTap: _onCurrentLocationTap,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: AppDimensions.padding12w,
                                    vertical: AppDimensions.padding4h,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: AppColors.gradient,
                                    borderRadius: BorderRadius.circular(
                                      AppDimensions.radius3r,
                                    ),
                                  ),
                                  child: Text(
                                    'Enable',
                                    style: customTextStyle(
                                      AppTextSizes.smallTextSize,
                                      AppColors.white,
                                      FontWeight.w600,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: AppDimensions.padding20h),

                    // 5. Selected Address Detail Card
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radius12r,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withValues(alpha: 0.25),
                            blurRadius: 9.66,
                            spreadRadius: 0,
                            offset: Offset(
                              0,
                              AppDimensions.containerHeight9_66h,
                            ),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header: Card label and radio-style indicator
                          Container(
                            padding: EdgeInsets.all(AppDimensions.padding15h),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(
                                  AppDimensions.radius12r,
                                ),
                                topRight: Radius.circular(
                                  AppDimensions.radius12r,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'CHOOSE YOUR ADDRESS',
                                  style: customTextStyle(
                                    AppTextSizes.smallTextSize,
                                    AppColors.text,
                                    FontWeight.w500,
                                  ),
                                ),
                                const Spacer(),
                                Builder(
                                  builder: (context) {
                                    final enabled = state.hasCardAddress;
                                    final isSelected =
                                        state.isCardAddressSelected;
                                    return GestureDetector(
                                      onTap: enabled
                                          ? ref
                                                .read(addressProvider.notifier)
                                                .selectCardAddress
                                          : null,
                                      child: Container(
                                        height:
                                            AppDimensions.containerHeight15h,
                                        width: AppDimensions.containerWidth15w,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: !enabled
                                                ? AppColors.lightGrey2
                                                : (isSelected
                                                      ? AppColors.primary
                                                      : AppColors.text),
                                            width: 1,
                                          ),
                                        ),
                                        child: (enabled && isSelected)
                                            ? Container(
                                                height:
                                                    AppDimensions
                                                        .containerHeight15h *
                                                    0.5,
                                                width:
                                                    AppDimensions
                                                        .containerWidth15w *
                                                    0.5,
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: AppColors.primary,
                                                ),
                                              )
                                            : null,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),

                          // Content: City and Detailed Address text
                          Padding(
                            padding: EdgeInsets.all(AppDimensions.padding15h),
                            child: Builder(
                              builder: (context) {
                                if (state.isLoadingAddress) {
                                  return SizedBox(
                                    height: AppDimensions.containerHeight18h,
                                    width: AppDimensions.containerWidth18w,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  );
                                }

                                final pending = state.pendingManualAddress;
                                final address = state.address;

                                if (state.status == ApiStatus.error &&
                                    pending == null &&
                                    address == null) {
                                  return Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "Couldn't load your address.",
                                          style: customTextStyle(
                                            AppTextSizes.stableTextSize,
                                            AppColors.darkGrey2,
                                            FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: ref
                                            .read(addressProvider.notifier)
                                            .fetchAddress,
                                        child: const Text('Retry'),
                                      ),
                                    ],
                                  );
                                }

                                if (pending == null && address == null) {
                                  return Text(
                                    'No address saved yet. Add one below.',
                                    style: customTextStyle(
                                      AppTextSizes.stableTextSize,
                                      AppColors.darkGrey2,
                                      FontWeight.w400,
                                    ),
                                  );
                                }

                                // A staged manual entry always wins the
                                // display — it's the most recent thing the
                                // user did, even if an older saved address
                                // still exists underneath it.
                                final city = pending?.city ?? address?.city;
                                final region = pending?.state ?? address?.state;
                                final pincode =
                                    pending?.pincode ?? address?.pincode;
                                final fullAddress =
                                    pending?.fullAddress ??
                                    address?.fullAddress ??
                                    '';
                                final flatApartment =
                                    pending?.flatApartment ??
                                    address?.flatApartment;
                                final floorBuilding =
                                    pending?.floorBuilding ??
                                    address?.floorBuilding;
                                final buildingSocietyLandmark =
                                    pending?.buildingSocietyLandmark ??
                                    address?.buildingSocietyLandmark;
                                final landmark =
                                    pending?.landmark ?? address?.landmark;

                                // Manual entries (staged, or an already-saved
                                // address that has these detail fields filled
                                // in) show the full address — flat/apartment,
                                // floor/building, society/landmark, the
                                // written-out address, landmark, and pincode.
                                // A current-location address never has these
                                // fields, so it keeps showing just the
                                // geocoded full address, unchanged.
                                final isManualEntry =
                                    pending != null ||
                                    [
                                      flatApartment,
                                      floorBuilding,
                                      buildingSocietyLandmark,
                                    ].any(
                                      (part) =>
                                          part != null &&
                                          part.trim().isNotEmpty,
                                    );

                                final cityLine = [city, region]
                                    .where(
                                      (part) =>
                                          part != null &&
                                          part.trim().isNotEmpty,
                                    )
                                    .join(', ');

                                final detailLine = isManualEntry
                                    ? [
                                            flatApartment,
                                            floorBuilding,
                                            buildingSocietyLandmark,
                                            fullAddress,
                                            landmark,
                                            pincode,
                                          ]
                                          .where(
                                            (part) =>
                                                part != null &&
                                                part.trim().isNotEmpty,
                                          )
                                          .join(', ')
                                    : fullAddress;

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Flags an unconfirmed manual entry so
                                    // it's clear Next still has to be tapped.
                                    if (pending != null) ...[
                                      Text(
                                        'Not saved yet — tap Next to confirm',
                                        style: customTextStyle(
                                          AppTextSizes.smallTextSize,
                                          AppColors.warning,
                                          FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(height: AppDimensions.padding8h),
                                    ],

                                    // City/Area Row
                                    if (cityLine.isNotEmpty) ...[
                                      Text(
                                        cityLine,
                                        style: customTextStyle(
                                          AppTextSizes.smallTextSize,
                                          AppColors.primary,
                                          FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(height: AppDimensions.padding8h),
                                    ],

                                    // Full Address String — every
                                    // detail field for a manual entry, just
                                    // the geocoded address for current
                                    // location (see isManualEntry above).
                                    Text(
                                      detailLine,
                                      style: customTextStyle(
                                        AppTextSizes.stableTextSize,
                                        AppColors.darkGrey2,
                                        FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),

                          // Action: Change/Add Address Button (Flush to
                          // bottom-right edge). Passes the saved address (if
                          // any) so Add Address can prefill its fields.
                          Align(
                            alignment: Alignment.bottomRight,
                            child: GestureDetector(
                              onTap: () => _showAddressChoice(),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppDimensions.padding15w,
                                  vertical: AppDimensions.padding8h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(
                                      AppDimensions.radius12r,
                                    ),
                                    bottomRight: Radius.circular(
                                      AppDimensions.radius12r,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  state.hasAddress
                                      ? 'Change Address'
                                      : 'Add Address',
                                  style: customTextStyle(
                                    AppTextSizes.stableTextSize,
                                    AppColors.white,
                                    FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppDimensions.padding30h),

                    // Primary Action: commits whichever source is selected
                    // (see AddressNotifier.confirmAndProceed) and only
                    // then navigates to Home (or back, in manage mode).
                    // Blocked with the choice dialog when nothing has been
                    // selected yet.
                    PrimaryButton(
                      text: widget.manage ? 'Save' : 'Next',
                      isLoading:
                          state.isFetchingLocation || state.isSavingManualEntry,
                      onPressed: () async {
                        if (state.selectedSource == null) {
                          _showAddressChoice();
                          return;
                        }
                        final success = await ref
                            .read(addressProvider.notifier)
                            .confirmAndProceed();
                        if (!success || !context.mounted) return;
                        if (widget.manage) {
                          context.pop();
                        } else {
                          context.go(RouteNames.homeMain);
                        }
                      },
                    ),

                    SizedBox(height: AppDimensions.padding30h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
