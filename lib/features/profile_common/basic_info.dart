// File: lib/features/profile_common/basic_info.dart
// Purpose: The "basic information" logic both profile forms share — the
// user's single-page form and step 0 of the provider wizard: mobile and
// email checks, date-of-birth picking/formatting and photo picking.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
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

/// The DOB format the profile forms display and submit.
String formatDob(DateTime date) => DateFormat('dd/MM/yyyy').format(date);

/// Opens the system date picker for DOB. Returns null if cancelled.
Future<DateTime?> pickDateOfBirth(BuildContext context) => showDatePicker(
  context: context,
  initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
  firstDate: DateTime(1950),
  lastDate: DateTime.now(),
);

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
