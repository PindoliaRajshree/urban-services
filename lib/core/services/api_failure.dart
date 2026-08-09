import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:urban_services/core/services/api_result.dart';

ApiResult<T> handleApiResponse<T>(
  Response response,
  T Function(Map<String, dynamic>) fromJson,
) {
  debugPrint("handleApiResponse - Status Code: ${response.statusCode}");
  debugPrint("handleApiResponse - Response Data: ${response.data}");

  if ((response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 202) &&
      response.data != null) {
    if (response.data is! Map<String, dynamic>) {
      return ApiFailure("Invalid response format");
    }
    final map = response.data as Map<String, dynamic>;
    final isSuccess = map['status'] == true || map['status'] == 'success';
    if (isSuccess) {
      try {
        final result = fromJson(map);
        debugPrint("handleApiResponse - Successfully parsed response");
        return ApiSuccess(result);
      } catch (e, stackTrace) {
        debugPrint("handleApiResponse - JSON parsing error: $e");
        debugPrint("handleApiResponse - Stack trace: $stackTrace");
        return ApiFailure("Failed to parse server response: $e");
      }
    } else {
      debugPrint("handleApiResponse - API returned error status");
      return ApiFailure(map['message'] ?? "Unknown error from server");
    }
  } else {
    debugPrint("handleApiResponse - Unexpected response code or null data");
    return ApiFailure(
      "Unexpected response from server (${response.statusCode})",
    );
  }
}
