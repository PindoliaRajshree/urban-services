// File: lib/features/home_provider/complete_profile/service_type_provider.dart
// Purpose: Provider service categories and their sub-services for the
// profile-completion "Service Details" step. ProviderHomeScreen preloads
// the categories; both lists are cached for the whole session (Riverpod
// keeps each category's sub-services separately, so switching back to a
// category is instant and a slow response for an old category can't
// overwrite the current one).

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_services/core/network/api_result.dart';
import 'package:urban_services/core/session/session_provider.dart';
import 'package:urban_services/features/home_provider/complete_profile/models/service_type.dart';
import 'package:urban_services/features/home_provider/complete_profile/models/sub_service_type.dart';
import 'package:urban_services/features/home_provider/complete_profile/service_type_repository.dart';

/// Service category list. Fetched once per session; errors surface as
/// AsyncError, and the wizard shows a Retry that invalidates this provider.
final serviceTypesProvider = FutureProvider<List<ServiceType>>((ref) async {
  // A new login starts with a fresh list.
  ref.watch(sessionProvider.select((s) => s.token));
  final result = await ref
      .watch(serviceTypeRepositoryProvider)
      .getServiceTypes();
  return switch (result) {
    ApiSuccess(data: final data) => data.data,
    ApiError(failure: final failure) => throw failure,
  };
});

/// Sub-services of one service category, cached per category id.
final subServiceTypesProvider =
    FutureProvider.family<List<SubServiceType>, int>((
      ref,
      serviceTypeId,
    ) async {
      ref.watch(sessionProvider.select((s) => s.token));
      final result = await ref
          .watch(serviceTypeRepositoryProvider)
          .getSubServiceTypes(serviceTypeId);
      return switch (result) {
        ApiSuccess(data: final data) => data.data,
        ApiError(failure: final failure) => throw failure,
      };
    });
