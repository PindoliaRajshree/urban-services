// File: lib/features/home_provider/provider_home_controller.dart
// Purpose: State management for the Provider Home dashboard, including availability toggles.

import 'package:get/get.dart';

class ProviderHomeController extends GetxController {
  // Reactive boolean to track if the provider is active/available for new requests
  final isAvailable = true.obs;

  /// Toggles the provider's work availability status
  void toggleAvailability(bool value) {
    isAvailable.value = value;
  }
}
