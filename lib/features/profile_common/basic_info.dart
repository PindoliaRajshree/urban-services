// File: lib/features/profile_common/basic_info.dart
// Purpose: The "basic information" logic both profile forms share — the
// user's single-page form and step 0 of the provider wizard: mobile and
// email checks, date-of-birth picking/formatting and photo picking.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/utils/validators.dart';
import 'package:urban_services/widgets/custom_snackbar.dart';

/// Error for a mobile number that isn't exactly 10 digits, else null.
String? mobileNumberError(String mobile) => RegExp(r'^\d{10}$').hasMatch(mobile)
    ? null
    : "Enter a valid 10-digit mobile number";

/// Validator for an optional email field: empty is fine, anything else must
/// look like an email.
String? optionalEmailError(String? value) {
  if (value == null || value.isEmpty) return null;
  return AppValidators.isValidEmail(value)
      ? null
      : "Enter a valid email address";
}

/// Validator for a required email field.
String? requiredEmailError(String? value) {
  if (value == null || value.trim().isEmpty) return "Required";
  return optionalEmailError(value.trim());
}

/// The DOB format the profile forms display and submit.
String formatDob(DateTime date) => DateFormat('dd/MM/yyyy').format(date);

/// Opens the system date picker for DOB, limited to people aged 18 or over.
/// Returns null if cancelled.
Future<DateTime?> pickDateOfBirth(BuildContext context) {
  final now = DateTime.now();
  // The latest allowed birthday: exactly 18 years ago today.
  final eighteenYearsAgo = DateTime(now.year - 18, now.month, now.day);
  return showDatePicker(
    context: context,
    initialDate: eighteenYearsAgo,
    firstDate: DateTime(1950),
    lastDate: eighteenYearsAgo,
    // The app's own colours instead of the seed-generated Material ones.
    builder: (context, child) {
      final base = Theme.of(context);
      return Theme(
        data: base.copyWith(
          colorScheme: base.colorScheme.copyWith(
            primary: AppColors.primaryDark,
            onPrimary: AppColors.white,
            surface: AppColors.white,
            onSurface: AppColors.darkBlueText,
          ),
          datePickerTheme: DatePickerThemeData(
            backgroundColor: AppColors.white,
            surfaceTintColor: Colors.transparent,
            headerBackgroundColor: AppColors.primaryDark,
            headerForegroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radius16r),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: AppColors.primaryDark),
          ),
        ),
        child: child!,
      );
    },
  );
}

/// Picks a photo from [source], downscaled to [maxSide] pixels and
/// recompressed (a full-resolution camera photo is several MB and slow to
/// upload). Returns null when cancelled, or when the camera/gallery can't
/// be opened (e.g. permission denied), after telling the user.
Future<File?> pickCompressedImage(
  ImagePicker picker,
  ImageSource source, {
  required double maxSide,
}) async {
  try {
    final picked = await picker.pickImage(
      source: source,
      maxWidth: maxSide,
      maxHeight: maxSide,
      imageQuality: 80,
    );
    return picked == null ? null : File(picked.path);
  } catch (e) {
    debugPrint("pickCompressedImage error: $e");
    CustomSnackBar.showError(
      title:
          "Couldn't open ${source == ImageSource.camera ? 'camera' : 'gallery'}",
      message: "Check that Urban Service is allowed to use it in Settings.",
    );
    return null;
  }
}
