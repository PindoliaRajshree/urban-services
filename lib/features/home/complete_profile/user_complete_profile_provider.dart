// File: lib/features/home/complete_profile/user_complete_profile_provider.dart
// Purpose: State management for the regular user's basic profile completion
// form (photo, name, mobile, email, gender, DOB, address) with inline
// validation.
// Text fields live in the screen; this holds everything else.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:urban_services/core/location/region_data.dart';
import 'package:urban_services/features/profile_common/basic_info.dart';
import 'package:urban_services/routes/app_router.dart';
import 'package:urban_services/routes/route_names.dart';

class UserCompleteProfileState {
  const UserCompleteProfileState({
    this.profileImage,
    this.gender,
    this.dob,
    this.profileImageError,
    this.genderError,
    this.dobError,
    this.mobileError,
    this.countries = const [],
    this.states = const [],
    this.cities = const [],
    this.selectedCountry,
    this.selectedState,
    this.selectedCity,
    this.isLoadingCountries = true,
    this.isLoadingStates = false,
    this.isLoadingCities = false,
  });

  final File? profileImage;
  final String? gender;
  final String? dob;

  // --- Address pickers (Country -> State -> City) ---
  // Options of each list depend on the selection above it.
  final List<Region> countries;
  final List<Region> states;
  final List<String> cities;
  final Region? selectedCountry;
  final Region? selectedState;
  final String? selectedCity;
  final bool isLoadingCountries;
  final bool isLoadingStates;
  final bool isLoadingCities;

  // --- Inline Error States ---
  final String? profileImageError;
  final String? genderError;
  final String? dobError;
  final String? mobileError;

  UserCompleteProfileState copyWith({
    File? Function()? profileImage,
    String? gender,
    String? dob,
    String? Function()? profileImageError,
    String? Function()? genderError,
    String? Function()? dobError,
    String? Function()? mobileError,
    List<Region>? countries,
    List<Region>? states,
    List<String>? cities,
    Region? Function()? selectedCountry,
    Region? Function()? selectedState,
    String? Function()? selectedCity,
    bool? isLoadingCountries,
    bool? isLoadingStates,
    bool? isLoadingCities,
  }) => UserCompleteProfileState(
    profileImage: profileImage != null ? profileImage() : this.profileImage,
    gender: gender ?? this.gender,
    dob: dob ?? this.dob,
    profileImageError: profileImageError != null
        ? profileImageError()
        : this.profileImageError,
    genderError: genderError != null ? genderError() : this.genderError,
    dobError: dobError != null ? dobError() : this.dobError,
    mobileError: mobileError != null ? mobileError() : this.mobileError,
    countries: countries ?? this.countries,
    states: states ?? this.states,
    cities: cities ?? this.cities,
    selectedCountry: selectedCountry != null
        ? selectedCountry()
        : this.selectedCountry,
    selectedState: selectedState != null ? selectedState() : this.selectedState,
    selectedCity: selectedCity != null ? selectedCity() : this.selectedCity,
    isLoadingCountries: isLoadingCountries ?? this.isLoadingCountries,
    isLoadingStates: isLoadingStates ?? this.isLoadingStates,
    isLoadingCities: isLoadingCities ?? this.isLoadingCities,
  );
}

class UserCompleteProfileNotifier extends Notifier<UserCompleteProfileState> {
  final ImagePicker _picker = ImagePicker();

  /// Preselected until the user picks another country.
  static const String defaultCountryCode = 'IN';

  @override
  UserCompleteProfileState build() {
    _loadCountries();
    return const UserCompleteProfileState();
  }

  // --- Address pickers ---

  Future<void> _loadCountries() async {
    final countries = await loadCountries();
    if (!ref.mounted) return;
    state = state.copyWith(countries: countries, isLoadingCountries: false);
    final india = countries.where((c) => c.isoCode == defaultCountryCode);
    if (state.selectedCountry == null && india.isNotEmpty) {
      await setCountry(india.first.name);
    }
  }

  /// Picking a country resets the state and city, then loads its states.
  Future<void> setCountry(String name) async {
    final country = _byName(state.countries, name);
    if (country == null || country.isoCode == state.selectedCountry?.isoCode) {
      return;
    }
    state = state.copyWith(
      selectedCountry: () => country,
      selectedState: () => null,
      selectedCity: () => null,
      states: const [],
      cities: const [],
      isLoadingStates: true,
    );
    final states = await loadStates(country.isoCode);
    // Ignore a stale result if the country changed meanwhile.
    if (!ref.mounted || state.selectedCountry?.isoCode != country.isoCode) {
      return;
    }
    state = state.copyWith(states: states, isLoadingStates: false);
  }

  /// Picking a state resets the city, then loads the state's cities.
  Future<void> setSelectedState(String name) async {
    final country = state.selectedCountry;
    final region = _byName(state.states, name);
    if (country == null || region == null) return;
    if (region.isoCode == state.selectedState?.isoCode) return;
    state = state.copyWith(
      selectedState: () => region,
      selectedCity: () => null,
      cities: const [],
      isLoadingCities: true,
    );
    final cities = await loadCities(country.isoCode, region.isoCode);
    if (!ref.mounted || state.selectedState?.isoCode != region.isoCode) return;
    state = state.copyWith(cities: cities, isLoadingCities: false);
  }

  void setCity(String name) => state = state.copyWith(selectedCity: () => name);

  static Region? _byName(List<Region> regions, String name) {
    for (final r in regions) {
      if (r.name == name) return r;
    }
    return null;
  }

  /// Picks an image from camera or gallery for profile
  Future<void> pickImage(ImageSource source) async {
    final file = await pickCompressedImage(_picker, source, maxSide: 1024);
    if (file != null && ref.mounted) {
      // Clear the inline error as soon as the user provides a value.
      state = state.copyWith(
        profileImage: () => file,
        profileImageError: () => null,
      );
    }
  }

  void removeProfileImage() {
    state = state.copyWith(profileImage: () => null);
  }

  void setGender(String? value) {
    if (value == null) return;
    state = state.copyWith(gender: value, genderError: () => null);
  }

  void setDob(DateTime picked) {
    state = state.copyWith(dob: formatDob(picked), dobError: () => null);
  }

  void clearMobileError() {
    if (state.mobileError != null) {
      state = state.copyWith(mobileError: () => null);
    }
  }

  /// Validates the mobile number before the OTP dialog is shown. Returns
  /// true when the dialog should open.
  bool sendOtp(String mobile) {
    final error = mobileNumberError(mobile);
    state = state.copyWith(mobileError: () => error);
    if (error != null) return false;
    debugPrint("Sending OTP to $mobile");
    return true;
  }

  String? validateEmail(String? value) => optionalEmailError(value);

  String? validateRequired(String? value) =>
      (value == null || value.trim().isEmpty) ? "Required" : null;

  String? validatePincode(String? value) {
    if (value == null || value.isEmpty) return "Required";
    return RegExp(r'^\d{6}$').hasMatch(value) ? null : "Enter 6 digits";
  }

  /// Validates the non-TextFormField parts of Basic Details: profile photo,
  /// gender and dob.
  bool validateBasicInfoFields() {
    state = state.copyWith(
      profileImageError: () => state.profileImage == null ? "Required" : null,
      genderError: () => state.gender == null ? "Required" : null,
      dobError: () => state.dob == null ? "Required" : null,
    );
    return state.profileImageError == null &&
        state.genderError == null &&
        state.dobError == null;
  }

  /// Validates all mandatory fields and submits the profile.
  /// [isFormValid] is the result of the screen's Form validation.
  void submitProfile({required bool isFormValid}) {
    final areCustomFieldsValid = validateBasicInfoFields();

    if (isFormValid && areCustomFieldsValid) {
      debugPrint("Submitting User Profile...");
      ref.read(routerProvider).go(RouteNames.homeMain);
    }
  }
}

final userCompleteProfileProvider =
    NotifierProvider.autoDispose<
      UserCompleteProfileNotifier,
      UserCompleteProfileState
    >(UserCompleteProfileNotifier.new);
