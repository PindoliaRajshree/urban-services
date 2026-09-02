// File: lib/core/constants/api_constants.dart
// Purpose: Centralized API configuration — base URL, endpoint paths and
// network timeouts used by DioClient / ApiService.

class ApiConstants {
  ApiConstants._();

  /// Base URL for the Urban Service backend.
  ///
  /// NOTE: This currently points at the `testing` environment path that was
  /// shared for initial setup. Update this single constant when the
  /// production API path is available — nothing else needs to change.
  static const String baseUrl =
      'https://bhavishyodayinstitute.com/bhavishyodayinstitute2/UrbanService Project/public/api/';

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // ---- Auth ----
  static const String register = 'register';
  static const String login = 'login';
  static const String logout = 'logout';

  /// Single endpoint that handles all three forgot-password steps (send
  /// OTP, verify OTP, reset password) — differentiated by which fields are
  /// present in the request body. Common to both user and provider roles.
  static const String forgotPassword = 'forgot-password';

  /// Resends the OTP for the email captured in step 1 of the
  /// forgot-password flow. Separate from [forgotPassword] itself.
  static const String resendOtp = 'resend-otp';

  // ---- Address (user only) ----
  /// Saves/updates the logged-in user's service address. User-only — the
  /// provider flow never sends a user to the address screens.
  static const String serviceAddress = 'user/service-address';

  /// Fetches the logged-in user's saved service address, if any. The
  /// backend identifies the user from the auth token (sent automatically
  /// by DioClient), so no query parameters are needed.
  static const String getServiceAddress = 'user/get-service-address';

  // ---- Google Maps / Geocoding ----
  /// Your Google Maps Platform API key — currently the same key already set
  /// in android/app/src/main/AndroidManifest.xml
  /// (com.google.android.geo.API_KEY meta-data, which enables the map
  /// widget) and now mirrored in ios/Runner/AppDelegate.swift
  /// (GMSServices.provideAPIKey). This constant lets the app additionally
  /// call Google's Geocoding API directly over HTTP for more accurate
  /// reverse geocoding than the on-device geocoder. Make sure the
  /// "Geocoding API" is enabled for this key in Google Cloud Console
  /// (APIs & Services > Library) — it's a separate toggle from "Maps SDK
  /// for Android/iOS".
  static const String googleMapsApiKey = 'AIzaSyCqhp43e2-dckwF04XtGyFMeTQKxkjpfD4';

  /// SHA-1 fingerprint (no colons) of the certificate this app is signed
  /// with, sent as the `X-Android-Cert` header on Geocoding API calls.
  /// Only matters if googleMapsApiKey is restricted to "Android apps" in
  /// Google Cloud Console — see GoogleGeocodingService's doc comment.
  /// Currently set to the release keystore's SHA-1
  /// (android/app/upload-keystore.jks). If you test reverse geocoding on a
  /// debug build (flutter run) with an app-restricted key, add the debug
  /// keystore's SHA-1 to the key's allowed list in Cloud Console too, or
  /// switch this constant per build flavor.
  static const String androidSigningCertSha1 =
      '001269F1D9AB6BE2B6CCFEBB09AC228CDE80F52A';
}
