// File: lib/features/address/address_repository.dart
// Purpose: Network calls for the address feature. User-only — providers
// never reach the address screens (see the login/register role-based
// navigation), so this repository has no provider counterpart.

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_services/core/constants/api_constants.dart';
import 'package:urban_services/core/network/api_call.dart';
import 'package:urban_services/core/network/api_result.dart';
import 'package:urban_services/core/network/network_providers.dart';
import 'package:urban_services/features/address/models/service_address_request.dart';
import 'package:urban_services/features/address/models/service_address_response.dart';

final addressRepositoryProvider = Provider<AddressRepository>(
  (ref) => AddressRepository(ref.watch(dioProvider)),
);

class AddressRepository {
  AddressRepository(this._dio);

  final Dio _dio;

  /// Calls POST /user/service-address to save/update the logged-in user's
  /// service address.
  Future<ApiResult<ServiceAddressResponse>> saveServiceAddress(
    ServiceAddressRequest request,
  ) => safeApiCall(
    () => _dio.post(ApiConstants.serviceAddress, data: request.toJson()),
    ServiceAddressResponse.fromJson,
  );

  /// Calls GET /user/get-service-address to fetch the logged-in user's
  /// previously saved service address. Returns an [ApiError] when the
  /// user has no saved address yet (as well as on a real network/server
  /// error) — callers should treat that as "no address set" rather than
  /// surfacing it as a hard error, since not having saved one yet is a
  /// normal, expected state (e.g. right after registering).
  Future<ApiResult<ServiceAddressResponse>> getServiceAddress() => safeApiCall(
    () => _dio.get(ApiConstants.getServiceAddress),
    ServiceAddressResponse.fromJson,
  );

  /// Whether the logged-in user already has a saved address. Used after
  /// login to skip the address screen for returning users.
  Future<bool> hasServiceAddress() async =>
      await getServiceAddress() is ApiSuccess;
}
