// File: lib/core/services/api_service.dart
// Purpose: Generic, reusable wrapper around DioClient. Every feature
// repository (auth, profile, bookings, ...) should call through here rather
// than using Dio directly, so error handling and response parsing stay
// consistent across the app.

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:urban_services/core/network/dio_client.dart';
import 'package:urban_services/core/services/api_failure.dart';
import 'package:urban_services/core/services/api_result.dart';

class ApiService {
  ApiService({Dio? dio}) : _dio = dio ?? DioClient.instance.dio;

  final Dio _dio;

  Future<ApiResult<T>> post<T>(
    String endpoint, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );
      return handleApiResponse<T>(response, fromJson);
    } on DioException catch (e) {
      return ApiFailure(_mapDioError(e));
    } catch (e) {
      debugPrint('ApiService.post - Unexpected error: $e');
      return const ApiFailure('Something went wrong. Please try again.');
    }
  }

  Future<ApiResult<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
      );
      return handleApiResponse<T>(response, fromJson);
    } on DioException catch (e) {
      return ApiFailure(_mapDioError(e));
    } catch (e) {
      debugPrint('ApiService.get - Unexpected error: $e');
      return const ApiFailure('Something went wrong. Please try again.');
    }
  }

  String _mapDioError(DioException e) {
    debugPrint('ApiService - DioException: ${e.type} - ${e.message}');

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timed out. Please try again.';
      case DioExceptionType.connectionError:
        return 'No internet connection. Please check your network.';
      case DioExceptionType.badResponse:
        final data = e.response?.data;
        if (data is Map<String, dynamic> && data['message'] != null) {
          return data['message'].toString();
        }
        return 'Server error (${e.response?.statusCode ?? 'unknown'}).';
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
