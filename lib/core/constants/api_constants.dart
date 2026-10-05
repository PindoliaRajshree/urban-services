// File: lib/core/constants/api_constants.dart
// Purpose: Centralized API configuration — base URL, endpoint paths and
// network timeouts used by DioClient / ApiService.

class ApiConstants {
  ApiConstants._();

  /// Base URL for the Urban Service backend. Override per build with
  /// `API_BASE_URL` in dart_defines.json (see README "Local config").
  ///
  /// The default is the shared `testing` environment path (the space in its
  /// folder name is written as %20).
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue:
        'https://bhavishyodayinstitute.com/bhavishyodayinstitute2/UrbanService%20Project/public/api/',
  );

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

  // ---- Provider: Service Types ----
  /// Fetches the master list of service categories (Cleaning, Painting,
  /// Electrician, ...) a provider can offer.
  static const String serviceTypes = 'provider/provider/service-types';

  /// Fetches the sub-services belonging to one service category. Requires a
  /// `service_type_id` query parameter.
  static const String subServiceTypes = 'provider/provider/sub-service-types';

  /// Submits the 3-step provider profile-completion form (basic info,
  /// service details, bank details) as multipart/form-data — the request
  /// includes file uploads (profile photo, Aadhaar front/back, PAN card).
  /// Used both for first-time completion and later edits.
  static const String providerProfileUpdate =
      'provider/provider-profile/update';

  /// Fetches the logged-in provider's saved profile. Answers 404
  /// ("Provider profile not found") until the profile has been submitted
  /// once — see CompleteProfileRepository.fetchProfile.
  static const String providerProfile = 'provider/provider-profile';

  /// Sends an OTP to a mobile number (POST). Query parameters: `mobile_number`,
  /// `role`. The response currently echoes the OTP back (`data.otp`) and
  /// there is no verify endpoint yet, so the app compares against it.
  static const String providerSendOtp = 'provider/provider/send-otp';

  /// Adds a mobile number to an account that has none (POST, form-data).
  /// Called twice: with `mobile` only to send an OTP, then with `mobile` +
  /// `otp` to verify it and save the number.
  static const String addMobileNumber = 'add-mobile-number';

  /// Public URL root for files the backend stores (Laravel `public` disk),
  /// e.g. `provider/documents/x.jpg` -> `<storageBaseUrl>provider/documents/x.jpg`.
  /// Override with `STORAGE_BASE_URL` in dart_defines.json.
  static const String storageBaseUrl = String.fromEnvironment(
    'STORAGE_BASE_URL',
    defaultValue:
        'https://bhavishyodayinstitute.com/bhavishyodayinstitute2/UrbanService%20Project/public/storage/',
  );

  // ---- Google Maps / Geocoding ----
  /// Google Maps Platform API key, injected at build time with
  /// `--dart-define-from-file=dart_defines.json` (gitignored; copy
  /// dart_defines.example.json). The map widget gets the same key from
  /// android/local.properties and ios/Flutter/Secrets.xcconfig — see
  /// README "Local config". This constant is used to call Google's
  /// Geocoding API directly for more accurate reverse geocoding than the
  /// on-device geocoder; when it's empty, GoogleGeocodingService falls back
  /// to the on-device geocoder. The "Geocoding API" must be enabled for
  /// this key in Google Cloud Console.
  static const String googleMapsApiKey = String.fromEnvironment('MAPS_API_KEY');

  /// SHA-1 fingerprint (no colons) of the certificate this app is signed
  /// with, sent as the `X-Android-Cert` header on Geocoding API calls.
  /// Only matters if googleMapsApiKey is restricted to "Android apps" in
  /// Google Cloud Console — see GoogleGeocodingService's doc comment.
  /// Defaults to the release keystore's SHA-1
  /// (android/app/upload-keystore.jks). Debug builds are signed with the
  /// debug keystore, so set `ANDROID_CERT_SHA1` in dart_defines.json to its
  /// SHA-1 (and allow it on the key in Cloud Console) to use the Geocoding
  /// API from `flutter run` — see README "Local config".
  static const String androidSigningCertSha1 = String.fromEnvironment(
    'ANDROID_CERT_SHA1',
    defaultValue: '001269F1D9AB6BE2B6CCFEBB09AC228CDE80F52A',
  );
}
