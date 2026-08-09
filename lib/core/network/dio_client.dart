// File: lib/core/network/dio_client.dart
// Purpose: Single configured Dio instance shared across the app. Handles
// base URL/timeouts, auth-token injection and debug logging.

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:urban_services/core/constants/api_constants.dart';
import 'package:urban_services/core/constants/storage_keys.dart';
import 'package:urban_services/shared_preferences/sharedpreference_helper.dart';

class DioClient {
  DioClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        sendTimeout: ApiConstants.sendTimeout,
        headers: const {'Accept': 'application/json'},
      ),
    );

    // Attach the auth token (if any) to every outgoing request.
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SharedPreferencesHelper.instance
              .getValue<String>(StorageKeys.authToken);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true, error: true),
      );
    }
  }

  static final DioClient instance = DioClient._internal();

  late final Dio _dio;

  Dio get dio => _dio;
}
