import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/network_source_config.dart';
import '../../domain/network_source_result.dart';
import 'network_source_service_stub.dart'
    if (dart.library.io) 'network_source_service_io.dart' as impl;

class NetworkSourceService {
  const NetworkSourceService();

  bool get isSupported => impl.isSupported;

  Future<void> testConnection(NetworkSourceConfig config) {
    return impl.testConnection(config);
  }

  Future<NetworkSourceDraft?> validateAndBrowse(
    BuildContext context, {
    required NetworkSourceConfig config,
    required String title,
    required String badge,
  }) {
    return impl.validateAndBrowse(
      context,
      config: config,
      title: title,
      badge: badge,
    );
  }
}

final networkSourceServiceProvider = Provider<NetworkSourceService>((ref) {
  return const NetworkSourceService();
});
