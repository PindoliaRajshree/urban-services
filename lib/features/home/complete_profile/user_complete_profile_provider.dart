// File: lib/features/home/complete_profile/user_complete_profile_provider.dart
// Purpose: State management for the regular user's profile form (photo,
// name, mobile, email, gender, DOB, address): loading and prefilling the
// saved profile, mobile OTP verification, inline validation and
// submission. Used for both first-time completion and later edits.
// Text fields live in the screen; this holds everything else.

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:urban_services/core/location/region_data.dart';
import 'package:urban_services/core/network/api_result.dart';
import 'package:urban_services/core/session/session_provider.dart';
import 'package:urban_services/features/home/complete_profile/models/user_profile.dart';
import 'package:urban_services/features/home/complete_profile/models/user_profile_update_request.dart';
import 'package:urban_services/features/home/complete_profile/user_profile_repository.dart';
import 'package:urban_services/features/home_provider/complete_profile/complete_profile_repository.dart';
import 'package:urban_services/features/home_provider/complete_profile/models/provider_profile.dart';
import 'package:urban_services/features/profile_common/basic_info.dart';
import 'package:urban_services/routes/app_router.dart';
import 'package:urban_services/routes/route_names.dart';
import 'package:urban_services/widgets/custom_snackbar.dart';

/// Text values of the form — read from the screen's controllers on submit,
/// and written into them when the saved profile is loaded.
class UserProfileTextValues {
  const UserProfileTextValues({
    this.fullName = '',
    this.mobile = '',
    this.email = '',
    this.pincode = '',
    this.fullAddress = '',
  });

  final String fullName;
  final String mobile;
  final String email;
  final String pincode;
  final String fullAddress;
}

class UserCompleteProfileState {
  const UserCompleteProfileState({
    this.isLoading = true,
    this.loadError,
    this.isEditing = false,
    this.profileImage,
    this.profileImageUrl,
    this.gender,
    this.dob,
    this.verifiedMobile,
    this.isSendingOtp = false,
    this.canAddMobile = false,
    this.pendingMobile,
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
    this.isSubmitting = false,
  });

  // --- Initial load ---
  /// True while the saved profile is being fetched.
  final bool isLoading;

  /// Set when the saved profile couldn't be fetched (the screen offers a
  /// retry instead of showing an empty form over existing data).
  final String? loadError;

  /// The saved profile is already complete — the screen is editing it.
  final bool isEditing;

  // The photo is either a newly picked File or the URL of the one already
  // saved on the server (a new pick replaces it).
  final File? profileImage;
  final String? profileImageUrl;
  final String? gender;

  /// Displayed as dd/MM/yyyy (see formatDob); sent as yyyy-MM-dd.
  final String? dob;

  // --- Mobile verification ---
  /// The number whose OTP was verified (or that the backend reports as
  /// verified). The mobile field counts as verified only while its text
  /// equals this.
  final String? verifiedMobile;
  final bool isSendingOtp;

  /// The account had no mobile number when the form loaded and none has
  /// been added yet — the field offers "Add Mobile Number" instead of
  /// being typed.
  final bool canAddMobile;

  /// A number added (and sent an OTP) through add-mobile-number but not
  /// verified yet — the field offers "Verify" for it.
  final String? pendingMobile;

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

  // --- Submission state ---
  final bool isSubmitting;

  bool isMobileVerified(String mobile) =>
      verifiedMobile != null && verifiedMobile == mobile.trim();

  UserCompleteProfileState copyWith({
    bool? isLoading,
    String? Function()? loadError,
    bool? isEditing,
    File? Function()? profileImage,
    String? Function()? profileImageUrl,
    String? gender,
    String? dob,
    String? Function()? verifiedMobile,
    bool? isSendingOtp,
    bool? canAddMobile,
    String? Function()? pendingMobile,
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
    bool? isSubmitting,
  }) => UserCompleteProfileState(
    isLoading: isLoading ?? this.isLoading,
    loadError: loadError != null ? loadError() : this.loadError,
    isEditing: isEditing ?? this.isEditing,
    profileImage: profileImage != null ? profileImage() : this.profileImage,
    profileImageUrl: profileImageUrl != null
        ? profileImageUrl()
        : this.profileImageUrl,
    gender: gender ?? this.gender,
    dob: dob ?? this.dob,
    verifiedMobile: verifiedMobile != null
        ? verifiedMobile()
        : this.verifiedMobile,
    isSendingOtp: isSendingOtp ?? this.isSendingOtp,
    canAddMobile: canAddMobile ?? this.canAddMobile,
    pendingMobile: pendingMobile != null ? pendingMobile() : this.pendingMobile,
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
    isSubmitting: isSubmitting ?? this.isSubmitting,
  );
}

class UserCompleteProfileNotifier extends Notifier<UserCompleteProfileState> {
  /// UI choices and the API values they map to.
  static const Map<String, String> genderOptions = {
    'Male': 'male',
    'Female': 'female',
    'Other': 'other',
  };

  /// Preselected until the user picks another country.
  static const String defaultCountryCode = 'IN';

  final ImagePicker _picker = ImagePicker();

  /// The OTP the backend returned for [_otpMobile]. Kept out of state —
  /// the UI never needs it.
  String? _otp;
  String? _otpMobile;

  @override
  UserCompleteProfileState build() => const UserCompleteProfileState();

  // --- Initial load ---

  /// Fetches the saved profile (and the country list) and prefills the
  /// form. Returns the text values for the screen's controllers, or null
  /// when the fetch failed (see [UserCompleteProfileState.loadError]).
  Future<UserProfileTextValues?> loadInitial() async {
    state = state.copyWith(isLoading: true, loadError: () => null);
    final (result, countries) = await (
      ref.read(userProfileRepositoryProvider).fetchProfile(),
      loadCountries(),
    ).wait;
    if (!ref.mounted) return null;
    state = state.copyWith(countries: countries, isLoadingCountries: false);

    final session = ref.read(sessionProvider);
    switch (result) {
      case ApiError(:final failure):
        state = state.copyWith(
          isLoading: false,
          loadError: () => failure.message,
        );
        return null;
      case ApiSuccess(data: final p):
        final mobile = (p.mobile ?? session.mobile)?.trim() ?? '';
        state = state.copyWith(
          isEditing: p.isProfileCompleted,
          profileImageUrl: () => ProviderProfile.fileUrl(p.profileImage),
          gender: labelFor(genderOptions, p.gender),
          dob: p.dateOfBirth == null ? null : formatDob(p.dateOfBirth!),
          verifiedMobile: () => p.isMobileVerified ? p.mobile : null,
          canAddMobile: mobile.isEmpty,
        );
        await _prefillRegion(p);
        if (!ref.mounted) return null;
        state = state.copyWith(isLoading: false);
        return UserProfileTextValues(
          fullName: p.name ?? session.name ?? '',
          email: p.email ?? session.email ?? '',
          mobile: mobile,
          pincode: p.pincode ?? '',
          fullAddress: p.fullAddress ?? '',
        );
    }
  }

  /// Selects the saved country, state and city by name, each once the list
  /// it belongs to has loaded. A saved name missing from its list is left
  /// unselected; no saved country falls back to [defaultCountryCode].
  Future<void> _prefillRegion(UserProfile p) async {
    final saved = p.country == null
        ? null
        : _byName(state.countries, p.country!);
    final country =
        saved ??
        state.countries
            .where((c) => c.isoCode == defaultCountryCode)
            .firstOrNull;
    if (country == null) return;
    await setCountry(country.name);
    if (saved == null || p.state == null || !ref.mounted) return;
    if (_byName(state.states, p.state!) == null) return;
    await setSelectedState(p.state!);
    if (p.city == null || !ref.mounted) return;
    if (state.cities.contains(p.city)) setCity(p.city!);
  }

  /// The UI label for an API value in [options] (e.g. 'male' -> 'Male'), or
  /// null when there's no match.
  static String? labelFor(Map<String, String> options, String? apiValue) {
    if (apiValue == null) return null;
    for (final MapEntry(:key, :value) in options.entries) {
      if (value == apiValue) return key;
    }
    return null;
  }

  // --- Address pickers ---

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
    final wanted = name.trim().toLowerCase();
    for (final r in regions) {
      if (r.name.toLowerCase() == wanted) return r;
    }
    return null;
  }

  // --- Photo ---

  /// Picks a profile photo (camera or gallery), downscaled and recompressed
  /// on pick, then capped at 4MB and limited to jpg/jpeg/png.
  Future<void> pickImage(ImageSource source) async {
    final file = await pickCompressedImage(_picker, source, maxSide: 1024);
    if (file == null) return;

    final sizeInMb = await file.length() / (1024 * 1024);
    if (!ref.mounted) return;
    final ext = file.path.split('.').last.toLowerCase();
    final error = !const {'jpg', 'jpeg', 'png'}.contains(ext)
        ? "Only jpg, jpeg or png images are allowed"
        : sizeInMb > 4
        ? "File size must be less than 4MB"
        : null;
    state = error != null
        ? state.copyWith(profileImageError: () => error)
        : state.copyWith(
            profileImage: () => file,
            profileImageError: () => null,
          );
  }

  /// Removing the photo also drops the saved one, so a replacement is
  /// required again.
  void removeProfileImage() {
    state = state.copyWith(
      profileImage: () => null,
      profileImageUrl: () => null,
    );
  }

  // --- Field setters (each clears its inline error) ---

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

  // --- Mobile OTP ---

  /// Validates [rawMobile] and asks the backend to send it an OTP. Returns
  /// true when the OTP dialog should open.
  Future<bool> sendOtp(String rawMobile) async {
    if (state.isSendingOtp) return false;
    final mobile = rawMobile.trim();
    final error = mobileNumberError(mobile);
    state = state.copyWith(mobileError: () => error);
    if (error != null) return false;

    state = state.copyWith(isSendingOtp: true);
    final result = await ref
        .read(completeProfileRepositoryProvider)
        .sendOtp(mobile, role: 'user');
    if (!ref.mounted) return false;
    state = state.copyWith(isSendingOtp: false);

    switch (result) {
      case ApiSuccess(:final data):
        _otp = data;
        _otpMobile = mobile;
        CustomSnackBar.showSuccess(message: "OTP sent to $mobile");
        return true;
      case ApiError(:final failure):
        CustomSnackBar.showError(message: failure.message);
        return false;
    }
  }

  /// Checks [code] against the OTP sent to [rawMobile]. Returns an error
  /// message, or null once the number is marked verified.
  ///
  /// NOTE: the backend has no verify endpoint yet, so the comparison uses
  /// the OTP it echoed back from send-otp (as on the provider form).
  String? verifyOtp(String rawMobile, String code) {
    final mobile = rawMobile.trim();
    if (code.trim().isEmpty) return "Please enter OTP";
    if (_otp == null || _otpMobile != mobile) {
      return "OTP expired. Tap Resend to get a new one";
    }
    if (code.trim() != _otp) return "Incorrect OTP";

    _otp = null;
    _otpMobile = null;
    state = state.copyWith(
      verifiedMobile: () => mobile,
      mobileError: () => null,
    );
    return null;
  }

  // --- Adding a mobile number (accounts without one) ---

  /// Adds [rawMobile] to the account (add-mobile-number, which sends it an
  /// OTP); it then waits as [UserCompleteProfileState.pendingMobile] until
  /// verified with [confirmAddMobile]. Also used to resend the OTP.
  Future<bool> requestAddMobileOtp(String rawMobile) async {
    if (state.isSendingOtp) return false;
    final mobile = rawMobile.trim();
    if (mobileNumberError(mobile) != null) return false;

    state = state.copyWith(isSendingOtp: true);
    final result = await ref
        .read(completeProfileRepositoryProvider)
        .addMobileNumber(mobile);
    if (!ref.mounted) return false;
    state = state.copyWith(isSendingOtp: false);

    switch (result) {
      case ApiSuccess():
        state = state.copyWith(
          canAddMobile: false,
          pendingMobile: () => mobile,
          mobileError: () => null,
        );
        return true;
      case ApiError(:final failure):
        CustomSnackBar.showError(message: failure.message);
        return false;
    }
  }

  /// Sends [code] to the backend, which verifies it and saves [rawMobile]
  /// on the account. Returns an error message, or null once verified.
  Future<String?> confirmAddMobile(String rawMobile, String code) async {
    final mobile = rawMobile.trim();
    final result = await ref
        .read(completeProfileRepositoryProvider)
        .addMobileNumber(mobile, otp: code.trim());
    if (!ref.mounted) return null;

    switch (result) {
      case ApiError(:final failure):
        return failure.message;
      case ApiSuccess():
        state = state.copyWith(
          verifiedMobile: () => mobile,
          pendingMobile: () => null,
          mobileError: () => null,
        );
        await ref.read(sessionProvider.notifier).updateMobile(mobile);
        return null;
    }
  }

  // --- Validation ---

  String? validateEmail(String? value) => optionalEmailError(value);

  String? validateRequired(String? value) =>
      (value == null || value.trim().isEmpty) ? "Required" : null;

  String? validatePincode(String? value) {
    if (value == null || value.isEmpty) return "Required";
    return RegExp(r'^\d{6}$').hasMatch(value) ? null : "Enter 6 digits";
  }

  /// Validates the non-TextFormField parts of the form: mobile
  /// verification, profile photo (a saved one counts), gender and dob.
  bool validateBasicInfoFields(String mobile) {
    String? mobileError = state.mobileError;
    if (state.canAddMobile) {
      mobileError = "Please add your mobile number";
    } else if (mobileNumberError(mobile.trim()) == null &&
        !state.isMobileVerified(mobile)) {
      mobileError = "Please verify your mobile number";
    }
    state = state.copyWith(
      mobileError: () => mobileError,
      profileImageError: () =>
          state.profileImage == null && state.profileImageUrl == null
          ? "Required"
          : null,
      genderError: () => state.gender == null ? "Required" : null,
      dobError: () => state.dob == null ? "Required" : null,
    );
    return state.mobileError == null &&
        state.profileImageError == null &&
        state.genderError == null &&
        state.dobError == null;
  }

  // --- Submit ---

  /// Validates and submits the profile to user/update-user-profile.
  /// [isFormValid] is the result of the screen's Form validation.
  Future<void> submitProfile(
    UserProfileTextValues values, {
    required bool isFormValid,
  }) async {
    if (state.isSubmitting) return;
    final areCustomFieldsValid = validateBasicInfoFields(values.mobile);
    if (!isFormValid || !areCustomFieldsValid) return;

    final request = UserProfileUpdateRequest(
      name: values.fullName.trim(),
      email: values.email.trim(),
      mobile: values.mobile.trim(),
      gender: genderOptions[state.gender]!,
      dateOfBirth: DateFormat(
        'yyyy-MM-dd',
      ).format(DateFormat('dd/MM/yyyy').parseStrict(state.dob!)),
      country: state.selectedCountry!.name,
      state: state.selectedState!.name,
      city: state.selectedCity!,
      pincode: values.pincode.trim(),
      fullAddress: values.fullAddress.trim(),
      profileImage: state.profileImage,
    );

    state = state.copyWith(isSubmitting: true);
    final result = await ref
        .read(userProfileRepositoryProvider)
        .updateProfile(request);
    if (!ref.mounted) return;
    state = state.copyWith(isSubmitting: false);

    switch (result) {
      case ApiSuccess(:final data):
        CustomSnackBar.showSuccess(
          message: data.message ?? "Profile updated successfully",
        );
        // Home/Profile re-fetch (avatar, completion prompt, view screen).
        ref.invalidate(userProfileStatusProvider);
        final router = ref.read(routerProvider);
        if (router.canPop()) {
          router.pop();
        } else {
          router.go(RouteNames.homeMain);
        }
      case ApiError(:final failure):
        CustomSnackBar.showError(message: failure.message);
    }
  }
}

final userCompleteProfileProvider =
    NotifierProvider.autoDispose<
      UserCompleteProfileNotifier,
      UserCompleteProfileState
    >(UserCompleteProfileNotifier.new);
