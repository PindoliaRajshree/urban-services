// File: lib/features/home_provider/complete_profile/service_type_controller.dart
// Purpose: Preloads provider service categories on the Home screen and
// caches sub-services per category so switching between categories in the
// profile-completion "Service Details" step feels instant after the first
// fetch. Shared between ProviderHomeScreen (which triggers the preload) and
// CompleteProfileController (which reads/drives it) via Get.find.

import 'package:get/get.dart';
import 'package:urban_services/core/constants/api_status.dart';
import 'package:urban_services/core/services/api_result.dart';
import 'package:urban_services/features/home_provider/complete_profile/models/service_type.dart';
import 'package:urban_services/features/home_provider/complete_profile/models/sub_service_type.dart';
import 'package:urban_services/features/home_provider/complete_profile/service_type_repository.dart';

class ServiceTypeController extends GetxController {
  ServiceTypeController({ServiceTypeRepository? repository})
    : _repository = repository ?? ServiceTypeRepository();

  final ServiceTypeRepository _repository;

  final serviceTypesStatus = ApiStatus.initial.obs;
  final serviceTypes = <ServiceType>[].obs;

  final subServiceTypesStatus = ApiStatus.initial.obs;
  final subServiceTypes = <SubServiceType>[].obs;

  final Map<int, List<SubServiceType>> _subServiceCache = {};

  // Tracks the most recently requested category so a slow response for a
  // category the user has since moved away from can't overwrite newer data.
  int? _activeRequestId;

  /// Fetches the service category list. No-op if already loaded, so calling
  /// this again when the Home tab is revisited doesn't re-hit the network.
  Future<void> fetchServiceTypes({bool force = false}) async {
    if (!force && serviceTypes.isNotEmpty) return;

    serviceTypesStatus.value = ApiStatus.loading;
    final result = await _repository.getServiceTypes();
    switch (result) {
      case ApiSuccess(data: final data):
        serviceTypes.value = data.data;
        serviceTypesStatus.value = ApiStatus.successful;
      case ApiFailure():
        serviceTypesStatus.value = ApiStatus.error;
    }
  }

  /// Fetches sub-services for [serviceTypeId], serving from cache instantly
  /// when that category has already been fetched once this session.
  Future<void> fetchSubServiceTypes(int serviceTypeId) async {
    _activeRequestId = serviceTypeId;

    final cached = _subServiceCache[serviceTypeId];
    if (cached != null) {
      subServiceTypes.value = cached;
      subServiceTypesStatus.value = ApiStatus.successful;
      return;
    }

    subServiceTypes.value = [];
    subServiceTypesStatus.value = ApiStatus.loading;
    final result = await _repository.getSubServiceTypes(serviceTypeId);
    if (_activeRequestId != serviceTypeId) return; // stale — ignore

    switch (result) {
      case ApiSuccess(data: final data):
        _subServiceCache[serviceTypeId] = data.data;
        subServiceTypes.value = data.data;
        subServiceTypesStatus.value = ApiStatus.successful;
      case ApiFailure():
        subServiceTypesStatus.value = ApiStatus.error;
    }
  }
}
