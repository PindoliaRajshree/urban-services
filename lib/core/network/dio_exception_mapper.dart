import 'package:dio/dio.dart';

import 'api_failure.dart';

/// The one place a DioException becomes an [ApiFailure]. Adapted from
/// orbit_core — feed it to [safeApiCall] rather than calling it by hand.
ApiFailure mapDioException(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
      return ApiFailure.timeout();

    case DioExceptionType.connectionError:
      return ApiFailure.network();

    case DioExceptionType.cancel:
      return ApiFailure.cancelled();

    case DioExceptionType.badResponse:
      final statusCode = e.response?.statusCode;
      if (statusCode == null) return ApiFailure.network();
      final data = e.response?.data;
      return ApiFailure.fromStatusCode(
        statusCode,
        message: extractServerMessage(data),
        fieldErrors: _extractFieldErrors(data),
      );

    case DioExceptionType.badCertificate:
    case DioExceptionType.unknown:
      return ApiFailure(
        type: ApiFailureType.unknown,
        message: 'Something went wrong. Please try again.',
        cause: e,
      );
  }
}

/// Pulls a user-facing message out of a response body. Laravel sometimes
/// returns a validation map/list under `message`, so this never casts —
/// it prefers a plain string, then the first field error.
String? extractServerMessage(dynamic data) {
  if (data is! Map) return null;
  final message = data['message'];
  if (message is String && message.trim().isNotEmpty) return message;

  final fieldErrors = _extractFieldErrors(data);
  final first = fieldErrors?.values.expand((e) => e).firstOrNull;
  if (first != null) return first;

  return message?.toString();
}

/// Best-effort parse of common validation-error shapes:
///   {"errors": {"email": ["is required"]}}
///   {"message": {"email": ["is required"]}}
///   {"errors": {"email": "is required"}}
Map<String, List<String>>? _extractFieldErrors(dynamic data) {
  if (data is! Map) return null;
  final raw = data['errors'] is Map ? data['errors'] : data['message'];
  if (raw is! Map) return null;

  final result = <String, List<String>>{};
  raw.forEach((key, value) {
    result[key.toString()] = value is List
        ? value.map((e) => e.toString()).toList()
        : [value.toString()];
  });
  return result.isEmpty ? null : result;
}
