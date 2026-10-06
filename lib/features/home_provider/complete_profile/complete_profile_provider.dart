// File: lib/features/home_provider/complete_profile/complete_profile_provider.dart
// Purpose: State management for the 3-step provider profile form
// (Basic Information -> Service Details -> Bank Details): loading and
// prefilling the saved profile, mobile OTP verification, per-step
// validation and submission. Used for both first-time completion and later
// edits. Text fields, form keys and the PageController live in the screen
// (see CompleteProfileScreen); this holds everything else.

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:urban_services/core/location/location_helper.dart';
import 'package:urban_services/core/utils/document_number_reader.dart';
import 'package:urban_services/core/network/api_result.dart';
import 'package:urban_services/core/session/session_provider.dart';
import 'package:urban_services/features/address/services/google_geocoding_service.dart';
import 'package:urban_services/features/home_provider/complete_profile/complete_profile_repository.dart';
import 'package:urban_services/features/home_provider/complete_profile/models/profile_update_request.dart';
import 'package:urban_services/features/home_provider/complete_profile/models/provider_profile.dart';
import 'package:urban_services/features/profile_common/basic_info.dart';
import 'package:urban_services/routes/app_router.dart';
import 'package:urban_services/routes/route_names.dart';
import 'package:urban_services/widgets/custom_snackbar.dart';

/// Text values of the whole form — read from the screen's controllers on
/// submit, and written into them when a saved profile is loaded.
class ProviderProfileTextValues {
  const ProviderProfileTextValues({
    this.fullName = '',
    this.mobile = '',
    this.email = '',
    this.bio = '',
    this.startingPrice = '',
    this.teamSize = '',
    this.address = '',
    this.city = '',
    this.state = '',
    this.pincode = '',
    this.accountHolder = '',
    this.bankName = '',
    this.accountNumber = '',
    this.ifsc = '',
    this.upiId = '',
  });

  final String fullName;
  final String mobile;
  final String email;
  final String bio;
  final String startingPrice;
  final String teamSize;
  final String address;
  final String city;
  final String state;
  final String pincode;
  final String accountHolder;
  final String bankName;
  final String accountNumber;
  final String ifsc;
  final String upiId;
}

/// Address fields worked out from the device location. A null field means
/// "leave what's there".
class LocationFill {
  const LocationFill({this.address, this.city, this.state, this.pincode});

  final String? address;
  final String? city;
  final String? state;
  final String? pincode;
}

class ProviderProfileState {
  const ProviderProfileState({
    this.isLoading = true,
    this.loadError,
    this.isEditing = false,
    this.currentStep = 0,
    this.profileImage,
    this.profileImageUrl,
    this.gender,
    this.dob,
    this.adhaarFront,
    this.adhaarFrontUrl,
    this.adhaarBack,
    this.adhaarBackUrl,
    this.panCard,
    this.panCardUrl,
    this.aadhaarNumber,
    this.panNumber,
    this.isReadingAadhaar = false,
    this.isReadingPan = false,
    this.serviceCategory,
    this.subServices,
    this.experience,
    this.pricingType = 'Per Hour',
    this.selectedRadius = '5km',
    this.workType = 'Full Time',
    this.latitude,
    this.longitude,
    this.isLocating = false,
    this.verifiedMobile,
    this.isSendingOtp = false,
    this.canAddMobile = false,
    this.pendingMobile,
    this.profileImageError,
    this.genderError,
    this.dobError,
    this.adhaarFrontError,
    this.adhaarBackError,
    this.panCardError,
    this.categoryError,
    this.subServiceError,
    this.experienceError,
    this.locationError,
    this.ifscError,
    this.mobileError,
    this.isSubmitting = false,
  });

  // --- Initial load ---
  /// True while the saved profile is being fetched.
  final bool isLoading;

  /// Set when the saved profile couldn't be fetched (the screen offers a
  /// retry instead of showing an empty form over existing data).
  final String? loadError;

  /// A profile was already saved — the screen is editing it.
  final bool isEditing;

  // --- Step Tracking ---
  // Step 0 = Basic Information, Step 1 = Service Details, Step 2 = Bank Details
  final int currentStep;

  // --- Basic Information (Step 0) ---
  // Each photo/document is either a newly picked File or the URL of the one
  // already saved on the server (a new pick replaces it).
  final File? profileImage;
  final String? profileImageUrl;
  final String? gender;

  /// Displayed as dd/MM/yyyy (see formatDob); sent as yyyy-MM-dd.
  final String? dob;

  // Documents Verification (part of Basic Information)
  final File? adhaarFront;
  final String? adhaarFrontUrl;
  final File? adhaarBack;
  final String? adhaarBackUrl;
  final File? panCard;
  final String? panCardUrl;

  /// Read from the card images by OCR (or loaded with a saved profile) —
  /// never typed. Null until a readable image is provided.
  final String? aadhaarNumber;
  final String? panNumber;

  /// True while OCR runs on a just-picked Aadhaar front / PAN image.
  final bool isReadingAadhaar;
  final bool isReadingPan;

  // --- Service Details (Step 1) ---
  // Hold the selected service-type / sub-service-type id (not a display
  // string) so they map directly to what the backend expects.
  final int? serviceCategory;
  final int? subServices;
  final String? experience;
  final String pricingType;
  final String selectedRadius;
  final String workType;
  final double? latitude;
  final double? longitude;
  final bool isLocating;

  // --- Mobile verification ---
  /// The number whose OTP was verified (or that was already saved on the
  /// profile). The mobile field counts as verified only while its text
  /// equals this.
  final String? verifiedMobile;
  final bool isSendingOtp;

  /// The account had no mobile number when the form loaded and none has
  /// been added yet — the field offers "Add Mobile Number" (see
  /// ProviderProfileNotifier.requestAddMobileOtp) instead of being typed.
  final bool canAddMobile;

  /// A number added (and sent an OTP) through add-mobile-number but not
  /// verified yet — the field offers "Verify" for it.
  final String? pendingMobile;

  // --- Inline Error States ---
  final String? profileImageError;
  final String? genderError;
  final String? dobError;
  final String? adhaarFrontError;
  final String? adhaarBackError;
  final String? panCardError;
  final String? categoryError;
  final String? subServiceError;
  final String? experienceError;
  final String? locationError;
  final String? ifscError;
  final String? mobileError;

  // --- Submission state ---
  final bool isSubmitting;

  bool get isFirstStep => currentStep == 0;
  bool get isLastStep => currentStep == ProviderProfileNotifier.totalSteps - 1;

  bool get hasLocation => latitude != null && longitude != null;

  bool isMobileVerified(String mobile) =>
      verifiedMobile != null && verifiedMobile == mobile.trim();

  ProviderProfileState copyWith({
    bool? isLoading,
    String? Function()? loadError,
    bool? isEditing,
    int? currentStep,
    File? Function()? profileImage,
    String? Function()? profileImageUrl,
    String? gender,
    String? dob,
    File? Function()? adhaarFront,
    String? Function()? adhaarFrontUrl,
    File? Function()? adhaarBack,
    String? Function()? adhaarBackUrl,
    File? Function()? panCard,
    String? Function()? panCardUrl,
    String? Function()? aadhaarNumber,
    String? Function()? panNumber,
    bool? isReadingAadhaar,
    bool? isReadingPan,
    int? serviceCategory,
    int? Function()? subServices,
    String? experience,
    String? pricingType,
    String? selectedRadius,
    String? workType,
    double? latitude,
    double? longitude,
    bool? isLocating,
    String? Function()? verifiedMobile,
    bool? isSendingOtp,
    bool? canAddMobile,
    String? Function()? pendingMobile,
    String? Function()? profileImageError,
    String? Function()? genderError,
    String? Function()? dobError,
    String? Function()? adhaarFrontError,
    String? Function()? adhaarBackError,
    String? Function()? panCardError,
    String? Function()? categoryError,
    String? Function()? subServiceError,
    String? Function()? experienceError,
    String? Function()? locationError,
    String? Function()? ifscError,
    String? Function()? mobileError,
    bool? isSubmitting,
  }) => ProviderProfileState(
    isLoading: isLoading ?? this.isLoading,
    loadError: loadError != null ? loadError() : this.loadError,
    isEditing: isEditing ?? this.isEditing,
    currentStep: currentStep ?? this.currentStep,
    profileImage: profileImage != null ? profileImage() : this.profileImage,
    profileImageUrl: profileImageUrl != null
        ? profileImageUrl()
        : this.profileImageUrl,
    gender: gender ?? this.gender,
    dob: dob ?? this.dob,
    adhaarFront: adhaarFront != null ? adhaarFront() : this.adhaarFront,
    adhaarFrontUrl: adhaarFrontUrl != null
        ? adhaarFrontUrl()
        : this.adhaarFrontUrl,
    adhaarBack: adhaarBack != null ? adhaarBack() : this.adhaarBack,
    adhaarBackUrl: adhaarBackUrl != null ? adhaarBackUrl() : this.adhaarBackUrl,
    panCard: panCard != null ? panCard() : this.panCard,
    panCardUrl: panCardUrl != null ? panCardUrl() : this.panCardUrl,
    aadhaarNumber: aadhaarNumber != null ? aadhaarNumber() : this.aadhaarNumber,
    panNumber: panNumber != null ? panNumber() : this.panNumber,
    isReadingAadhaar: isReadingAadhaar ?? this.isReadingAadhaar,
    isReadingPan: isReadingPan ?? this.isReadingPan,
    serviceCategory: serviceCategory ?? this.serviceCategory,
    subServices: subServices != null ? subServices() : this.subServices,
    experience: experience ?? this.experience,
    pricingType: pricingType ?? this.pricingType,
    selectedRadius: selectedRadius ?? this.selectedRadius,
    workType: workType ?? this.workType,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    isLocating: isLocating ?? this.isLocating,
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
    adhaarFrontError: adhaarFrontError != null
        ? adhaarFrontError()
        : this.adhaarFrontError,
    adhaarBackError: adhaarBackError != null
        ? adhaarBackError()
        : this.adhaarBackError,
    panCardError: panCardError != null ? panCardError() : this.panCardError,
    categoryError: categoryError != null ? categoryError() : this.categoryError,
    subServiceError: subServiceError != null
        ? subServiceError()
        : this.subServiceError,
    experienceError: experienceError != null
        ? experienceError()
        : this.experienceError,
    locationError: locationError != null ? locationError() : this.locationError,
    ifscError: ifscError != null ? ifscError() : this.ifscError,
    mobileError: mobileError != null ? mobileError() : this.mobileError,
    isSubmitting: isSubmitting ?? this.isSubmitting,
  );
}

class ProviderProfileNotifier extends Notifier<ProviderProfileState> {
  static const int totalSteps = 3;

  // --- UI choices and the API values they map to ---
  static const Map<String, String> genderOptions = {
    'Male': 'male',
    'Female': 'female',
    'Other': 'other',
  };
  static const Map<String, String> pricingOptions = {
    'Per Hour': 'per_hour',
    'Per Visit': 'per_visit',
  };
  static const Map<String, String> workTypeOptions = {
    'Full Time': 'full_time',
    'Part Time': 'part_time',
  };
  static const Map<String, int> radiusOptions = {
    '5km': 5,
    '10km': 10,
    '15km': 15,
    '20km': 20,
  };

  /// "5+" is sent as 5.
  static const List<String> experienceOptions = ['1', '2', '3', '4', '5+'];

  final ImagePicker _picker = ImagePicker();

  /// The OTP the backend returned for [_otpMobile]. Kept out of state —
  /// the UI never needs it.
  String? _otp;
  String? _otpMobile;

  @override
  ProviderProfileState build() => const ProviderProfileState();

  // --- Initial load ---

  /// Fetches the saved profile and prefills the form: every field when a
  /// profile exists (edit mode), otherwise name/email/mobile from the
  /// registration session. Returns the text values for the screen's
  /// controllers, or null when the fetch failed (see
  /// [ProviderProfileState.loadError]).
  Future<ProviderProfileTextValues?> loadInitial() async {
    state = state.copyWith(isLoading: true, loadError: () => null);
    final result = await ref
        .read(completeProfileRepositoryProvider)
        .fetchProfile();
    if (!ref.mounted) return null;

    final session = ref.read(sessionProvider);
    switch (result) {
      case ApiError(:final failure):
        state = state.copyWith(
          isLoading: false,
          loadError: () => failure.message,
        );
        return null;
      case ApiSuccess(data: null):
        final mobile = session.mobile?.trim() ?? '';
        state = state.copyWith(isLoading: false, canAddMobile: mobile.isEmpty);
        return ProviderProfileTextValues(
          fullName: session.name ?? '',
          email: session.email ?? '',
          mobile: mobile,
        );
      case ApiSuccess(data: final ProviderProfile p):
        _applySaved(p);
        final mobile = (p.preferredMobile ?? session.mobile)?.trim() ?? '';
        state = state.copyWith(canAddMobile: mobile.isEmpty);
        return ProviderProfileTextValues(
          fullName: p.name ?? session.name ?? '',
          email: p.email ?? session.email ?? '',
          mobile: mobile,
          bio: p.bio ?? '',
          startingPrice: p.startingPrice ?? '',
          teamSize: p.teamSize?.toString() ?? '',
          address: p.address ?? '',
          city: p.city ?? '',
          state: p.state ?? '',
          pincode: p.pincode ?? '',
          accountHolder: p.accountHolderName ?? '',
          bankName: p.bankName ?? '',
          accountNumber: p.accountNumber ?? '',
          ifsc: p.ifscCode?.toUpperCase() ?? '',
          upiId: p.upiId ?? '',
        );
    }
  }

  /// The UI label for an API value in one of the option maps above (e.g.
  /// 'per_hour' -> 'Per Hour'), or null when there's no match.
  static String? labelFor<T>(Map<String, T> options, T? apiValue) {
    if (apiValue == null) return null;
    for (final MapEntry(:key, :value) in options.entries) {
      if (value == apiValue) return key;
    }
    return null;
  }

  /// Copies a saved profile's non-text values into state.
  void _applySaved(ProviderProfile p) {
    final years = p.experienceYears;
    state = state.copyWith(
      isLoading: false,
      isEditing: true,
      profileImageUrl: () => ProviderProfile.fileUrl(p.profileImage),
      adhaarFrontUrl: () => ProviderProfile.fileUrl(p.aadhaarFrontImage),
      adhaarBackUrl: () => ProviderProfile.fileUrl(p.aadhaarBackImage),
      panCardUrl: () => ProviderProfile.fileUrl(p.panImage),
      aadhaarNumber: () => p.aadhaarNumber,
      panNumber: () => p.panNumber?.toUpperCase(),
      gender: labelFor(genderOptions, p.gender?.toLowerCase()),
      dob: p.dateOfBirth == null ? null : formatDob(p.dateOfBirth!),
      serviceCategory: p.serviceTypeId,
      subServices: () => p.subServiceTypeId,
      experience: years == null || years < 1
          ? null
          : years >= 5
          ? '5+'
          : '$years',
      pricingType: labelFor(pricingOptions, p.pricingType),
      selectedRadius: labelFor(radiusOptions, p.serviceAreaKm),
      workType: labelFor(workTypeOptions, p.availabilityType),
      latitude: p.latitude,
      longitude: p.longitude,
      // A number already saved on the profile was verified when saved.
      verifiedMobile: () => p.mobileNumber,
    );
  }

  // --- Step Navigation ---

  void goToStep(int step) => state = state.copyWith(currentStep: step);

  // --- Field setters (each clears its inline error) ---

  void setGender(String? value) {
    if (value == null) return;
    state = state.copyWith(gender: value, genderError: () => null);
  }

  void setDob(DateTime picked) {
    state = state.copyWith(dob: formatDob(picked), dobError: () => null);
  }

  /// Sub-services belong to a category — reset the previous selection. The
  /// screen watches subServiceTypesProvider(category), which fetches (or
  /// serves from cache) the new list.
  void setServiceCategory(int? value) {
    if (value == null || value == state.serviceCategory) return;
    state = state.copyWith(
      serviceCategory: value,
      categoryError: () => null,
      subServices: () => null,
    );
  }

  void setSubService(int? value) {
    if (value == null) return;
    state = state.copyWith(
      subServices: () => value,
      subServiceError: () => null,
    );
  }

  void setExperience(String? value) {
    if (value == null) return;
    state = state.copyWith(experience: value, experienceError: () => null);
  }

  void setPricingType(String type) => state = state.copyWith(pricingType: type);

  /// Sets the service radius selection
  void setRadius(String radius) =>
      state = state.copyWith(selectedRadius: radius);

  /// Sets the work type selection
  void setWorkType(String type) => state = state.copyWith(workType: type);

  void clearMobileError() {
    if (state.mobileError != null) {
      state = state.copyWith(mobileError: () => null);
    }
  }

  void clearIfscError() {
    if (state.ifscError != null) state = state.copyWith(ifscError: () => null);
  }

  /// Removing a photo/document also drops the saved one, so a replacement
  /// is required again.
  void removeProfileImage() {
    state = state.copyWith(
      profileImage: () => null,
      profileImageUrl: () => null,
    );
  }

  /// The Aadhaar/PAN number is read from its image, so removing the image
  /// clears the number too.
  void removeDocument(String type) {
    if (type == 'aadhaarFront') {
      state = state.copyWith(
        adhaarFront: () => null,
        adhaarFrontUrl: () => null,
        aadhaarNumber: () => null,
      );
    }
    if (type == 'aadhaarBack') {
      state = state.copyWith(adhaarBack: () => null, adhaarBackUrl: () => null);
    }
    if (type == 'pan') {
      state = state.copyWith(
        panCard: () => null,
        panCardUrl: () => null,
        panNumber: () => null,
      );
    }
  }

  /// Reads the Aadhaar number off a just-picked front image. The image is
  /// kept only if a valid number was read; otherwise the provider is asked
  /// for a clearer photo (numbers are never typed in).
  Future<void> _acceptAadhaarFront(File file) async {
    state = state.copyWith(
      isReadingAadhaar: true,
      adhaarFrontError: () => null,
    );
    final number = await readAadhaarNumber(file);
    if (!ref.mounted) return;
    state = number == null
        ? state.copyWith(
            isReadingAadhaar: false,
            adhaarFrontError: () =>
                "Couldn't read the Aadhaar number. Upload a clear photo of "
                "the front of the card.",
          )
        : state.copyWith(
            isReadingAadhaar: false,
            adhaarFront: () => file,
            aadhaarNumber: () => number,
          );
  }

  /// Same as [_acceptAadhaarFront], for the PAN card.
  Future<void> _acceptPanCard(File file) async {
    state = state.copyWith(isReadingPan: true, panCardError: () => null);
    final number = await readPanNumber(file);
    if (!ref.mounted) return;
    state = number == null
        ? state.copyWith(
            isReadingPan: false,
            panCardError: () =>
                "Couldn't read the PAN number. Upload a clear photo of your "
                "PAN card.",
          )
        : state.copyWith(
            isReadingPan: false,
            panCard: () => file,
            panNumber: () => number,
          );
  }

  /// Picks an image (camera or gallery) for one of the four photo/document
  /// fields on this form — profile photo, Aadhaar front/back, or PAN card —
  /// identified by [field]. Images are downscaled and recompressed on pick
  /// (documents keep a higher resolution so they stay legible), then
  /// capped at 4MB and limited to jpg/jpeg/png.
  Future<void> pickPhotoFor(String field, ImageSource source) async {
    if (state.isReadingAadhaar || state.isReadingPan) return;
    final file = await pickCompressedImage(
      _picker,
      source,
      maxSide: field == 'profile' ? 1024 : 2000,
    );
    if (file == null) return;

    final sizeInMb = await file.length() / (1024 * 1024);
    if (!ref.mounted) return;
    final ext = file.path.split('.').last.toLowerCase();
    final error = !const {'jpg', 'jpeg', 'png'}.contains(ext)
        ? "Only jpg, jpeg or png images are allowed"
        : sizeInMb > 4
        ? "File size must be less than 4MB"
        : null;
    if (error != null) {
      switch (field) {
        case 'profile':
          state = state.copyWith(profileImageError: () => error);
        case 'aadhaarFront':
          state = state.copyWith(adhaarFrontError: () => error);
        case 'aadhaarBack':
          state = state.copyWith(adhaarBackError: () => error);
        case 'pan':
          state = state.copyWith(panCardError: () => error);
      }
      return;
    }

    switch (field) {
      case 'profile':
        state = state.copyWith(
          profileImage: () => file,
          profileImageError: () => null,
        );
      case 'aadhaarFront':
        await _acceptAadhaarFront(file);
      case 'aadhaarBack':
        state = state.copyWith(
          adhaarBack: () => file,
          adhaarBackError: () => null,
        );
      case 'pan':
        await _acceptPanCard(file);
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
        .sendOtp(mobile);
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
  /// the OTP it echoed back from send-otp. Replace with a server-side check
  /// once one exists.
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
  /// OTP); it then waits as [ProviderProfileState.pendingMobile] until
  /// verified with [confirmAddMobile]. Also used to resend the OTP.
  /// Returns whether it succeeded.
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
  /// on the account. Returns an error message, or null once the number is
  /// verified.
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

  // --- Location ---

  /// Captures the device location for `latitude`/`longitude` and, where
  /// Google can resolve it, returns address fields for the screen to fill.
  Future<LocationFill?> useCurrentLocation() async {
    if (state.isLocating) return null;
    state = state.copyWith(isLocating: true);
    final position = await currentPositionOrNotify();
    if (!ref.mounted) return null;
    if (position == null) {
      state = state.copyWith(isLocating: false);
      return null;
    }
    state = state.copyWith(
      latitude: position.latitude,
      longitude: position.longitude,
      locationError: () => null,
    );

    final geo = await GoogleGeocodingService.instance.reverseGeocode(
      latitude: position.latitude,
      longitude: position.longitude,
    );
    if (!ref.mounted) return null;
    state = state.copyWith(isLocating: false);
    if (geo == null) return null;

    String? nonEmpty(String v) => v.trim().isEmpty ? null : v.trim();
    return LocationFill(
      address: nonEmpty(geo.formattedAddress),
      city: nonEmpty(geo.city),
      state: nonEmpty(geo.state),
      pincode: nonEmpty(geo.pincode),
    );
  }

  /// IFSC format: 4 letters, a 0, then 6 letters or digits.
  static final RegExp ifscPattern = RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$');

  /// Logic to verify IFSC code
  void verifyIfsc(String rawIfsc) {
    final error = validateIfsc(rawIfsc.trim());
    state = state.copyWith(ifscError: () => error);
    if (error != null) return;
    debugPrint("Verifying IFSC: ${rawIfsc.trim()}");
    CustomSnackBar.showSuccess(title: "Success", message: "IFSC Code Verified");
  }

  /// --- Specific Field Validators ---

  String? validateEmail(String? value) => requiredEmailError(value);

  String? validateRequired(String? value) =>
      (value == null || value.trim().isEmpty) ? "Required" : null;

  /// Also runs on Submit, not only on "Verify".
  String? validateIfsc(String? value) {
    if (value == null || value.isEmpty) return "Required";
    return ifscPattern.hasMatch(value) ? null : "Invalid IFSC code format";
  }

  String? validatePincode(String? value) {
    if (value == null || value.isEmpty) return "Required";
    return RegExp(r'^\d{6}$').hasMatch(value) ? null : "Enter 6 digits";
  }

  String? validateTeamSize(String? value) {
    if (value == null || value.isEmpty) return "Required";
    final size = int.tryParse(value);
    return size == null || size < 1 ? "Enter 1 or more" : null;
  }

  /// For price fields (digits only via the field's formatter). Optional
  /// fields accept empty; any entered amount must be above zero.
  String? validatePrice(String? value, {bool required = false}) {
    if (value == null || value.isEmpty) return required ? "Required" : null;
    final amount = int.tryParse(value);
    return amount == null || amount <= 0 ? "Enter an amount above 0" : null;
  }

  String? validateAccountNumber(String? value) {
    if (value == null || value.isEmpty) return "Required";
    if (value.length < 9 || value.length > 18) {
      return "Enter valid account number";
    }
    return null;
  }

  /// The "Confirm account number" field must match [accountNumber].
  String? validateAccountNumberConfirmation(
    String? value,
    String accountNumber,
  ) {
    if (value == null || value.isEmpty) return "Required";
    return value == accountNumber ? null : "Account numbers don't match";
  }

  String? validateUpi(String? value) {
    if (value == null || value.trim().isEmpty) return "Required";
    return RegExp(r'^[\w.-]+@[\w.-]+$').hasMatch(value.trim())
        ? null
        : "Enter a valid UPI ID (e.g., name@upi)";
  }

  /// Validates the non-TextFormField parts of Step 0 (Basic Information):
  /// mobile verification, profile photo, gender, dob, and required
  /// documents. A saved photo/document counts as provided.
  bool validateBasicInfoFields(String mobile) {
    String? required(Object? file, String? url) =>
        file == null && url == null ? "Required" : null;
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
          required(state.profileImage, state.profileImageUrl),
      genderError: () => state.gender == null ? "Required" : null,
      dobError: () => state.dob == null ? "Required" : null,
      // A saved image without a saved number (older profiles) must be
      // re-uploaded so the number can be read from it.
      adhaarFrontError: () =>
          required(state.adhaarFront, state.adhaarFrontUrl) ??
          (state.aadhaarNumber == null
              ? "Upload the front again so we can read your Aadhaar number"
              : null),
      adhaarBackError: () => required(state.adhaarBack, state.adhaarBackUrl),
      panCardError: () =>
          (state.panCard != null || state.panCardUrl != null) &&
              state.panNumber == null
          ? "Upload the PAN card again so we can read the number"
          : null,
    );
    return state.mobileError == null &&
        state.profileImageError == null &&
        state.genderError == null &&
        state.dobError == null &&
        state.adhaarFrontError == null &&
        state.adhaarBackError == null &&
        state.panCardError == null;
  }

  /// Validates the non-TextFormField parts of Step 1 (Service Details):
  /// service category, sub services and experience dropdowns, and the
  /// captured location.
  bool validateServiceDetailsFields() {
    String? required(Object? value) => value == null ? "Required" : null;
    state = state.copyWith(
      categoryError: () => required(state.serviceCategory),
      subServiceError: () => required(state.subServices),
      experienceError: () => required(state.experience),
      locationError: () => state.hasLocation
          ? null
          : "Tap \"Use current location\" to set your service location",
    );
    return state.categoryError == null &&
        state.subServiceError == null &&
        state.experienceError == null &&
        state.locationError == null;
  }

  /// Submits the whole profile (all 3 steps) to
  /// provider/provider-profile/update. The screen validates the Bank
  /// Details form first. Returns the step to jump back to when an earlier
  /// step is incomplete, otherwise null.
  Future<int?> submitProfile(ProviderProfileTextValues values) async {
    if (state.isSubmitting) return null;

    // Earlier steps are validated on Next, but re-check here since the
    // required files/dropdowns aren't part of a Form's own validate().
    if (!validateBasicInfoFields(values.mobile)) {
      goToStep(0);
      return 0;
    }
    if (!validateServiceDetailsFields()) {
      goToStep(1);
      return 1;
    }

    final experience = state.experience!;
    final request = ProfileUpdateRequest(
      mobileNumber: values.mobile.trim(),
      email: values.email.trim(),
      gender: genderOptions[state.gender]!,
      dateOfBirth: DateFormat(
        'yyyy-MM-dd',
      ).format(DateFormat('dd/MM/yyyy').parseStrict(state.dob!)),
      serviceTypeId: state.serviceCategory!,
      subServiceTypeId: state.subServices!,
      experienceYears: int.parse(experience.replaceAll('+', '')),
      bio: values.bio.trim(),
      pricingType: pricingOptions[state.pricingType]!,
      startingPrice: values.startingPrice.trim(),
      address: values.address.trim(),
      city: values.city.trim(),
      state: values.state.trim(),
      pincode: values.pincode.trim(),
      latitude: state.latitude!,
      longitude: state.longitude!,
      serviceAreaKm: radiusOptions[state.selectedRadius]!,
      availabilityType: workTypeOptions[state.workType]!,
      teamSize: int.parse(values.teamSize.trim()),
      aadhaarNumber: state.aadhaarNumber!,
      panNumber: state.panNumber,
      accountHolderName: values.accountHolder.trim(),
      bankName: values.bankName.trim(),
      accountNumber: values.accountNumber.trim(),
      ifscCode: values.ifsc.trim(),
      upiId: values.upiId.trim(),
      profileImage: state.profileImage,
      aadhaarFrontImage: state.adhaarFront,
      aadhaarBackImage: state.adhaarBack,
      panImage: state.panCard,
    );

    state = state.copyWith(isSubmitting: true);
    final result = await ref
        .read(completeProfileRepositoryProvider)
        .updateProfile(request);
    if (!ref.mounted) return null;
    state = state.copyWith(isSubmitting: false);

    switch (result) {
      case ApiSuccess(data: final data):
        CustomSnackBar.showSuccess(
          message: data.message ?? "Profile submitted successfully",
        );
        // Home re-checks completion (hides its "complete profile" prompt).
        ref.invalidate(providerProfileStatusProvider);
        final router = ref.read(routerProvider);
        if (router.canPop()) {
          router.pop();
        } else {
          router.go(RouteNames.homeMain);
        }
      case ApiError(failure: final failure):
        CustomSnackBar.showError(message: failure.message);
    }
    return null;
  }
}

final providerProfileProvider =
    NotifierProvider.autoDispose<ProviderProfileNotifier, ProviderProfileState>(
      ProviderProfileNotifier.new,
    );
