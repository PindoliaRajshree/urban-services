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
  ///
  /// Double `provider` prefix matches [serviceTypes]/[subServiceTypes] above
  /// — the single-prefix path (`provider/provide-profile/update`) returned a
  /// Laravel "route not found" 404 in testing.
  static const String providerProfileUpdate = 'provider/provide-profile/update';

  // ---- Google Maps / Geocoding ----
  /// Google Maps Platform API key, injected at build time with
  /// `--dart-define-from-file=dart_defines.json` (gitignored; copy
  /// dart_defines.example.json). The map widget gets the same key from
  /// android/local.properties and ios/Flutter/Secrets.xcconfig — see
  /// README "Local secrets". This constant is used to call Google's
  /// Geocoding API directly for more accurate reverse geocoding than the
  /// on-device geocoder; when it's empty, GoogleGeocodingService falls back
  /// to the on-device geocoder. The "Geocoding API" must be enabled for
  /// this key in Google Cloud Console.
  static const String googleMapsApiKey = String.fromEnvironment('MAPS_API_KEY');

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
