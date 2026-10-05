// File: lib/core/utils/document_number_reader.dart
// Purpose: Reads the Aadhaar / PAN number off a photo of the card with
// on-device OCR (Google ML Kit), so providers never type these numbers.
// The extraction logic is split into pure functions ([extractAadhaar],
// [extractPan]) so it can be unit-tested without a device.

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// The 12-digit Aadhaar number printed on [image], or null when none can
/// be read (blurry photo, wrong side, or a masked XXXX XXXX 1234 card).
Future<String?> readAadhaarNumber(File image) async {
  final text = await _recognizeText(image);
  return text == null ? null : extractAadhaar(text);
}

/// The PAN printed on [image], or null when none can be read.
Future<String?> readPanNumber(File image) async {
  final text = await _recognizeText(image);
  return text == null ? null : extractPan(text);
}

/// ML Kit only runs on Android and iOS; anywhere else (and on any error)
/// this returns null, which callers treat as "couldn't read".
Future<String?> _recognizeText(File image) async {
  if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) return null;
  final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
  try {
    final result = await recognizer.processImage(
      InputImage.fromFilePath(image.path),
    );
    return result.text;
  } catch (e) {
    debugPrint("Document OCR failed: $e");
    return null;
  } finally {
    await recognizer.close();
  }
}

// ---------------------------------------------------------------------------
// Aadhaar
// ---------------------------------------------------------------------------

/// Four-digit groups with optional single spaces, not part of a longer
/// digit run — so the 16-digit VID printed on newer cards is skipped.
final RegExp _aadhaarPattern = RegExp(
  r'(?<!\d ?)(\d{4}) ?(\d{4}) ?(\d{4})(?! ?\d)',
);

/// The first valid Aadhaar number in OCR [text]: 12 digits, not starting
/// with 0 or 1, passing the Verhoeff checksum (which rejects most OCR
/// misreads and unrelated 12-digit numbers).
@visibleForTesting
String? extractAadhaar(String text) {
  for (final match in _aadhaarPattern.allMatches(text)) {
    final number = '${match[1]}${match[2]}${match[3]}';
    if (number.startsWith('0') || number.startsWith('1')) continue;
    if (isValidVerhoeff(number)) return number;
  }
  return null;
}

const List<List<int>> _verhoeffD = [
  [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
  [1, 2, 3, 4, 0, 6, 7, 8, 9, 5],
  [2, 3, 4, 0, 1, 7, 8, 9, 5, 6],
  [3, 4, 0, 1, 2, 8, 9, 5, 6, 7],
  [4, 0, 1, 2, 3, 9, 5, 6, 7, 8],
  [5, 9, 8, 7, 6, 0, 4, 3, 2, 1],
  [6, 5, 9, 8, 7, 1, 0, 4, 3, 2],
  [7, 6, 5, 9, 8, 2, 1, 0, 4, 3],
  [8, 7, 6, 5, 9, 3, 2, 1, 0, 4],
  [9, 8, 7, 6, 5, 4, 3, 2, 1, 0],
];

const List<List<int>> _verhoeffP = [
  [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
  [1, 5, 7, 6, 2, 8, 3, 0, 9, 4],
  [5, 8, 0, 3, 7, 9, 6, 1, 4, 2],
  [8, 9, 1, 6, 0, 4, 3, 5, 2, 7],
  [9, 4, 5, 3, 1, 2, 6, 8, 7, 0],
  [4, 2, 8, 6, 5, 7, 3, 9, 0, 1],
  [2, 7, 9, 3, 8, 0, 6, 4, 1, 5],
  [7, 0, 4, 6, 9, 1, 3, 2, 5, 8],
];

/// Verhoeff checksum — the last digit of an Aadhaar number is its check
/// digit.
@visibleForTesting
bool isValidVerhoeff(String digits) {
  var c = 0;
  final reversed = digits.split('').reversed.toList();
  for (var i = 0; i < reversed.length; i++) {
    c = _verhoeffD[c][_verhoeffP[i % 8][int.parse(reversed[i])]];
  }
  return c == 0;
}

// ---------------------------------------------------------------------------
// PAN
// ---------------------------------------------------------------------------

/// Format: 3 letters, holder type (P = person, C = company, ...), 1
/// letter, 4 digits, 1 letter.
final RegExp _panPattern = RegExp(r'^[A-Z]{3}[PCHFATBLJG][A-Z][0-9]{4}[A-Z]$');

/// OCR confusions, fixed by position: a digit where a letter must be...
const Map<String, String> _asLetter = {
  '0': 'O',
  '1': 'I',
  '2': 'Z',
  '5': 'S',
  '6': 'G',
  '8': 'B',
};

/// ...and a letter where a digit must be.
const Map<String, String> _asDigit = {
  'O': '0',
  'D': '0',
  'Q': '0',
  'I': '1',
  'L': '1',
  'Z': '2',
  'S': '5',
  'G': '6',
  'B': '8',
};

/// The first valid PAN in OCR [text], after correcting common
/// letter/digit confusions for each position.
@visibleForTesting
String? extractPan(String text) {
  final tokens = text.toUpperCase().split(RegExp(r'[^A-Z0-9]+'));
  for (final token in tokens) {
    if (token.length != 10) continue;
    final fixed = StringBuffer();
    for (var i = 0; i < 10; i++) {
      final ch = token[i];
      final wantsDigit = i >= 5 && i <= 8;
      fixed.write(wantsDigit ? (_asDigit[ch] ?? ch) : (_asLetter[ch] ?? ch));
    }
    final pan = fixed.toString();
    if (_panPattern.hasMatch(pan)) return pan;
  }
  return null;
}
