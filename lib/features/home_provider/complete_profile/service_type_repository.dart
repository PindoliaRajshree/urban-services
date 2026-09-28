// File: lib/features/home_provider/complete_profile/service_type_repository.dart
// Purpose: Network calls for provider service categories and sub-services
// used in the profile-completion "Service Details" step.

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_services/core/constants/api_constants.dart';
import 'package:urban_services/core/network/api_call.dart';
import 'package:urban_services/core/network/api_result.dart';
import 'package:urban_services/core/network/network_providers.dart';
import 'package:urban_services/features/home_provider/complete_profile/models/service_type.dart';
import 'package:urban_services/features/home_provider/complete_profile/models/sub_service_type.dart';

final serviceTypeRepositoryProvider = Provider<ServiceTypeRepository>(
  (ref) => ServiceTypeRepository(ref.watch(dioProvider)),
);

class ServiceTypeRepository {
  ServiceTypeRepository(this._dio);

  final Dio _dio;

  /// Calls GET provider/provider/service-types.
  Future<ApiResult<ServiceTypeListResponse>> getServiceTypes() => safeApiCall(
    () => _dio.get(ApiConstants.serviceTypes),
    ServiceTypeListResponse.fromJson,
  );

  /// Calls GET provider/provider/sub-service-types?service_type_id=[serviceTypeId].
  Future<ApiResult<SubServiceTypeListResponse>> getSubServiceTypes(
    int serviceTypeId,
  ) => safeApiCall(
    () => _dio.get(
      ApiConstants.subServiceTypes,
      queryParameters: {'service_type_id': serviceTypeId},
    ),
    SubServiceTypeListResponse.fromJson,
  );
}
