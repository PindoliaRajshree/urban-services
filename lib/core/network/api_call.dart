import 'package:dio/dio.dart';

import 'api_failure.dart';
import 'api_result.dart';
import 'dio_exception_mapper.dart';

/// Wraps one Dio call + JSON parse with the standard try/catch/map
/// sequence (from orbit_core), so a repository method is one line:
///
/// ```dart
/// Future<ApiResult<LoginResponse>> login(LoginRequest request) => safeApiCall(
///       () => _dio.post(ApiConstants.login, data: request.toJson()),
///       LoginResponse.fromJson,
///     );
/// ```
///
/// This backend wraps every body as `{status, message, data}` and can
/// answer 200 with `status: false`, so a 2xx is only a success when
/// `status` is `true` / `'success'` — anything else becomes an [ApiFailure]
/// carrying the server's `message`.
Future<ApiResult<T>> safeApiCall<T>(
  Future<Response<dynamic>> Function() request,
  T Function(Map<String, dynamic> json) parse,
) async {
  try {
    final response = await request();
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      return ApiResult.failure(
        ApiFailure(
          type: ApiFailureType.unknown,
          message: 'Unexpected response format from the server.',
          statusCode: response.statusCode,
        ),
      );
    }

    final isSuccess = data['status'] == true || data['status'] == 'success';
    if (!isSuccess) {
      return ApiResult.failure(
        ApiFailure(
          type: ApiFailureType.unknown,
          message: extractServerMessage(data) ?? 'Unknown error from server.',
          statusCode: response.statusCode,
        ),
      );
    }

    try {
      return ApiResult.success(parse(data));
    } catch (e) {
      return ApiResult.failure(
        ApiFailure(
          type: ApiFailureType.unknown,
          message: "Could not read the server's response.",
          statusCode: response.statusCode,
          cause: e,
        ),
      );
    }
  } on DioException catch (e) {
    return ApiResult.failure(mapDioException(e));
  } catch (e) {
    return ApiResult.failure(ApiFailure.unknown(e));
  }
}
