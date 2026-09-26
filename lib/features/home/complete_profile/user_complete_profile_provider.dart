// File: lib/features/home/complete_profile/user_complete_profile_provider.dart
// Purpose: State management for the regular user's basic profile completion
// form (photo, name, mobile, email, gender, DOB) with inline validation.
// Text fields live in the screen; this holds everything else.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:urban_services/core/utils/validators.dart';
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
  });

  final File? profileImage;
  final String? gender;
  final String? dob;

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
  );
}

class UserCompleteProfileNotifier extends Notifier<UserCompleteProfileState> {
  final ImagePicker _picker = ImagePicker();

  @override
  UserCompleteProfileState build() => const UserCompleteProfileState();

  /// Picks an image from camera or gallery for profile
  Future<void> pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null && ref.mounted) {
      // Clear the inline error as soon as the user provides a value.
      state = state.copyWith(
        profileImage: () => File(pickedFile.path),
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
    state = state.copyWith(
      dob: DateFormat('dd/MM/yyyy').format(picked),
      dobError: () => null,
    );
  }

  void clearMobileError() {
    if (state.mobileError != null) {
      state = state.copyWith(mobileError: () => null);
    }
  }

  /// Validates the mobile number before the OTP dialog is shown. Returns
  /// true when the dialog should open.
  bool sendOtp(String mobile) {
    if (mobile.length != 10) {
      state = state.copyWith(
        mobileError: () => "Enter a valid 10-digit mobile number",
      );
      return false;
    }
    state = state.copyWith(mobileError: () => null);
    debugPrint("Sending OTP to $mobile");
    return true;
  }

  String? validateEmail(String? value) {
    if (value != null && value.isNotEmpty) {
      if (!AppValidators.isValidEmail(value)) {
        return "Enter a valid email address";
      }
    }
    return null;
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

/// Opens the system date picker for DOB (shared by the user and provider
/// profile forms). Returns null if cancelled.
Future<DateTime?> pickDateOfBirth(BuildContext context) => showDatePicker(
  context: context,
  initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
  firstDate: DateTime(1950),
  lastDate: DateTime.now(),
);
