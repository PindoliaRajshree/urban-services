// File: lib/core/network/dio_client.dart
// Purpose: Builds the single Dio instance used for every Urban Service
// backend call (pattern from orbit_core's OrbitDioClient). Base URL and
// timeouts come from ApiConstants.

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:urban_services/core/constants/api_constants.dart';

import 'api_logger_interceptor.dart';
import 'auth_interceptor.dart';

class AppDio {
  AppDio._();

  static Dio create({
    required TokenReader readToken,
    required OnAuthExpired onAuthExpired,
    TokenRefresher? refreshToken,
    List<Interceptor> extraInterceptors = const [],
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        sendTimeout: ApiConstants.sendTimeout,
        headers: const {'Accept': 'application/json'},
      ),
    );

    dio.interceptors.add(
      AuthInterceptor(
        dio,
        readToken: readToken,
        // No refresh endpoint on this backend: a 401 ends the session.
        refreshToken: refreshToken ?? () async => null,
        onAuthExpired: onAuthExpired,
      ),
    );
    dio.interceptors.addAll(extraInterceptors);

    // Last, so it logs the final request (with the auth header attached)
    // and sees errors after the auth interceptor has handled them.
    if (kDebugMode) dio.interceptors.add(ApiLoggerInterceptor());

    return dio;
  }
}
