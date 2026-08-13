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
}
