// File: lib/features/address/services/google_geocoding_service.dart
// Purpose: Reverse-geocodes a lat/lng into a real street address using
// Google's Geocoding API (server-side, HTTP), which is significantly more
// accurate than the on-device geocoder (Android's Geocoder / iOS's
// CLGeocoder, used via the `geocoding` package) — especially in areas
// with sparse offline map data. Falls back gracefully (returns null) if
// no API key is configured yet, or if the call fails for any reason, so
// callers can fall back to on-device geocoding.
//
// NOTE on API key restrictions: if `ApiConstants.googleMapsApiKey` is
// restricted in Google Cloud Console to "Android apps" / "iOS apps"
// (rather than left unrestricted or restricted only by API), Google
// validates that restriction using the `X-Android-Package` +
// `X-Android-Cert` headers (Android) or `X-Ios-Bundle-Identifier` header
// (iOS) — which this service sets on every request. For that to work,
// every signing certificate you actually run the app with (debug AND
// release keystores) must be added to the key's allowed list in Cloud
// Console. If you'd rather not manage that list, simplest is to restrict
// the key only by API ("Geocoding API" + "Maps SDK for Android/iOS")
// with no application restriction.
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:urban_services/core/constants/api_constants.dart';
import 'package:urban_services/features/address/models/geocode_result.dart';

class GoogleGeocodingService {
  GoogleGeocodingService._();

  static final GoogleGeocodingService instance = GoogleGeocodingService._();

  static const String _endpoint =
      'https://maps.googleapis.com/maps/api/geocode/json';

  // Deliberately a fresh Dio instance (not the app's shared ApiService) —
  // this call goes to Google's servers, not the Urban Service backend, so
  // it must not carry the backend's base URL, auth token, or interceptors.
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  bool get _isConfigured =>
      ApiConstants.googleMapsApiKey.isNotEmpty &&
      ApiConstants.googleMapsApiKey != 'YOUR_GOOGLE_MAPS_API_KEY_HERE';

  /// Returns the most precise address Google can find for [latitude]/
  /// [longitude], or null if the key isn't configured yet, the API
  /// returned no usable result, or the request failed.
  Future<GeocodeResult?> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    if (!_isConfigured) return null;

    try {
      final response = await _dio.get(
        _endpoint,
        queryParameters: {
          'latlng': '$latitude,$longitude',
          'key': ApiConstants.googleMapsApiKey,
          // Nudges Google to prefer a rooftop/street-level match over a
          // broad locality-only match when both are available.
          'result_type':
              'street_address|premise|subpremise|route|neighborhood',
        },
        options: Options(headers: _restrictionHeaders()),
      );

      final data = response.data;
      if (data is! Map || data['status'] != 'OK') {
        debugPrint(
          'GoogleGeocodingService: no OK result (status=${data is Map ? data['status'] : data}) '
          '- falling back to on-device geocoding.',
        );
        return null;
      }

      final results = (data['results'] as List?) ?? const [];
      if (results.isEmpty) return null;

      // Google already orders `results` from most to least precise; the
      // first entry is what we want.
      final best = (results.first as Map).cast<String, dynamic>();
      return GeocodeResult.fromGoogleResult(best);
    } catch (e) {
      debugPrint('GoogleGeocodingService: reverse geocode failed: $e');
      return null;
    }
  }

  /// Headers Google uses to validate an "Android apps" / "iOS apps"
  /// restricted key. Harmless no-ops if the key has no such restriction.
  Map<String, String> _restrictionHeaders() {
    if (kIsWeb) return const {};
    if (Platform.isAndroid) {
      return {
        'X-Android-Package': 'com.service.urban_service',
        'X-Android-Cert': ApiConstants.androidSigningCertSha1,
      };
    }
    if (Platform.isIOS) {
      return {'X-Ios-Bundle-Identifier': 'com.service.urbanService'};
    }
    return const {};
  }
}
