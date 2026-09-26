// File: lib/core/network/network_providers.dart
// Purpose: Riverpod wiring for the network layer — the one Dio instance
// every repository receives.

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_services/core/session/session_provider.dart';

import 'dio_client.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = AppDio.create(
    // Read at request time (not captured once) so a fresh login is picked up.
    readToken: () async => ref.read(sessionProvider).token,
    onAuthExpired: () => ref.read(sessionProvider.notifier).expire(),
  );
  ref.onDispose(dio.close);
  return dio;
});
