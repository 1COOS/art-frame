import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/network_source_result.dart';
import 'network_source_service_stub.dart' if (dart.library.io) 'network_source_service_io.dart'
    as impl;

class NetworkSourceService {
  const NetworkSourceService();

  bool get isSupported => impl.isSupported;

  Future<NetworkSourceValidationResult> createSource(
    BuildContext context, {
    required String title,
    required String description,
    required String badge,
    NetworkSourceDraft? initialDraft,
  }) {
    return impl.createSource(
      context,
      title: title,
      description: description,
      badge: badge,
      initialDraft: initialDraft,
    );
  }
}

final networkSourceServiceProvider = Provider<NetworkSourceService>((ref) {
  return const NetworkSourceService();
});
