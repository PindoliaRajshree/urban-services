/// Broad category of an API failure, independent of the exact status code.
/// Branch UI behavior on [ApiFailure.type] / [ApiFailure.isRetryable] /
/// [ApiFailure.requiresLogin] instead of re-deriving it from a status code
/// (or from parsing [ApiFailure.message]) at every call site.
enum ApiFailureType {
  network, // no connection / DNS / connection refused
  timeout, // connect / send / receive timeout
  cancelled, // request was cancelled (e.g. the screen was left)
  unauthorized, // 401 — session invalid, caller should force logout
  forbidden, // 403
  notFound, // 404
  conflict, // 409
  validation, // 422 — fieldErrors is usually populated
  rateLimited, // 429
  server, // 5xx
  unknown, // anything else, including non-Dio errors
}

class ApiFailure implements Exception {
  final ApiFailureType type;
  final String message;
  final int? statusCode;

  /// Per-field validation messages, when the server returned them — a
  /// common 422 shape is `{"errors": {"email": ["is required"]}}`. Render
  /// these on the form fields instead of dumping [message] into a snackbar.
  final Map<String, List<String>>? fieldErrors;

  /// The original DioException/Object, kept for logging/Crashlytics only —
  /// never shown to the user.
  final Object? cause;

  const ApiFailure({
    required this.type,
    required this.message,
    this.statusCode,
    this.fieldErrors,
    this.cause,
  });

  /// Network/timeout/5xx/429 are generally worth a "Retry" button;
  /// validation, auth, and other 4xx errors are not — retrying just sends
  /// the same bad request again.
  bool get isRetryable => switch (type) {
        ApiFailureType.network ||
        ApiFailureType.timeout ||
        ApiFailureType.server ||
        ApiFailureType.rateLimited =>
          true,
        _ => false,
      };

  bool get requiresLogin => type == ApiFailureType.unauthorized;

  factory ApiFailure.network() => const ApiFailure(
        type: ApiFailureType.network,
        message: 'No internet connection. Please check your network and try again.',
      );

  factory ApiFailure.timeout() => const ApiFailure(
        type: ApiFailureType.timeout,
        message: 'The request timed out. Please try again.',
      );

  factory ApiFailure.cancelled() =>
      const ApiFailure(type: ApiFailureType.cancelled, message: 'Request was cancelled.');

  factory ApiFailure.unauthorized({String? message}) => ApiFailure(
        type: ApiFailureType.unauthorized,
        statusCode: 401,
        message: message ?? 'Your session has expired. Please log in again.',
      );

  /// Classifies an HTTP status code into an [ApiFailureType] with a
  /// sensible default message. Pass [message]/[fieldErrors] when the server
  /// gave you something more specific — see [mapDioException], which is
  /// the one place that should normally call this.
  factory ApiFailure.fromStatusCode(
    int statusCode, {
    String? message,
    Map<String, List<String>>? fieldErrors,
  }) {
    final type = switch (statusCode) {
      401 => ApiFailureType.unauthorized,
      403 => ApiFailureType.forbidden,
      404 => ApiFailureType.notFound,
      409 => ApiFailureType.conflict,
      422 => ApiFailureType.validation,
      429 => ApiFailureType.rateLimited,
      _ when statusCode >= 500 => ApiFailureType.server,
      _ => ApiFailureType.unknown,
    };
    return ApiFailure(
      type: type,
      statusCode: statusCode,
      fieldErrors: fieldErrors,
      message: message ?? _defaultMessageFor(type, statusCode),
    );
  }

  factory ApiFailure.unknown(Object error) => ApiFailure(
        type: ApiFailureType.unknown,
        message: 'Something went wrong.',
        cause: error,
      );

  static String _defaultMessageFor(ApiFailureType type, int statusCode) => switch (type) {
        ApiFailureType.unauthorized => 'Your session has expired. Please log in again.',
        ApiFailureType.forbidden => "You don't have permission to do that.",
        ApiFailureType.notFound => 'That could not be found.',
        ApiFailureType.conflict => 'This was already changed by someone else.',
        ApiFailureType.validation => 'Please check the highlighted fields.',
        ApiFailureType.rateLimited => 'Too many requests. Please try again shortly.',
        ApiFailureType.server => 'Something went wrong on our end. Please try again shortly.',
        _ => 'Unexpected response from the server ($statusCode).',
      };

  @override
  String toString() => 'ApiFailure(type: $type, statusCode: $statusCode, message: $message)';
}
