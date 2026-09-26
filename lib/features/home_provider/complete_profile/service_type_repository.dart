// File: lib/features/home_provider/complete_profile/service_type_repository.dart
// Purpose: Network calls for provider service categories and sub-services
// used in the profile-completion "Service Details" step.

import 'package:urban_services/core/constants/api_constants.dart';
import 'package:urban_services/core/services/api_result.dart';
import 'package:urban_services/core/services/api_service.dart';
import 'package:urban_services/features/home_provider/complete_profile/models/service_type.dart';
import 'package:urban_services/features/home_provider/complete_profile/models/sub_service_type.dart';

class ServiceTypeRepository {
  ServiceTypeRepository({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  /// Calls GET provider/provider/service-types.
  Future<ApiResult<ServiceTypeListResponse>> getServiceTypes() {
    return _apiService.get<ServiceTypeListResponse>(
      ApiConstants.serviceTypes,
      fromJson: ServiceTypeListResponse.fromJson,
    );
  }

  /// Calls GET provider/provider/sub-service-types?service_type_id=[serviceTypeId].
  Future<ApiResult<SubServiceTypeListResponse>> getSubServiceTypes(
    int serviceTypeId,
  ) {
    return _apiService.get<SubServiceTypeListResponse>(
      ApiConstants.subServiceTypes,
      queryParameters: {'service_type_id': serviceTypeId},
      fromJson: SubServiceTypeListResponse.fromJson,
    );
  }
}
