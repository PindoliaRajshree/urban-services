// File: lib/features/address/address_repository.dart
// Purpose: Network calls for the address feature. User-only — providers
// never reach the address screens (see LoginController/RegisterController
// role-based navigation), so this repository has no provider counterpart.

import 'package:urban_services/core/constants/api_constants.dart';
import 'package:urban_services/core/services/api_result.dart';
import 'package:urban_services/core/services/api_service.dart';
import 'package:urban_services/features/address/models/service_address_request.dart';
import 'package:urban_services/features/address/models/service_address_response.dart';

class AddressRepository {
  AddressRepository({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  /// Calls POST /user/service-address to save/update the logged-in user's
  /// service address.
  Future<ApiResult<ServiceAddressResponse>> saveServiceAddress(
    ServiceAddressRequest request,
  ) {
    return _apiService.post<ServiceAddressResponse>(
      ApiConstants.serviceAddress,
      data: request.toJson(),
      fromJson: ServiceAddressResponse.fromJson,
    );
  }

  /// Calls GET /user/get-service-address to fetch the logged-in user's
  /// previously saved service address. Returns an [ApiFailure] when the
  /// user has no saved address yet (as well as on a real network/server
  /// error) — callers should treat that as "no address set" rather than
  /// surfacing it as a hard error, since not having saved one yet is a
  /// normal, expected state (e.g. right after registering).
  Future<ApiResult<ServiceAddressResponse>> getServiceAddress() {
    return _apiService.get<ServiceAddressResponse>(
      ApiConstants.getServiceAddress,
      fromJson: ServiceAddressResponse.fromJson,
    );
  }
}
