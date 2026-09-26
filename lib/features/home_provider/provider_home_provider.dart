// File: lib/features/home_provider/provider_home_provider.dart
// Purpose: State for the Provider Home dashboard, including the
// availability toggle.

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether the provider is active/available for new requests.
class ProviderAvailabilityNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  /// Toggles the provider's work availability status
  void toggleAvailability(bool value) => state = value;
}

final providerAvailabilityProvider =
    NotifierProvider.autoDispose<ProviderAvailabilityNotifier, bool>(
      ProviderAvailabilityNotifier.new,
    );
