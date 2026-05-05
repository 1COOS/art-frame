import 'package:flutter/material.dart';

import '../../domain/network_source_config.dart';
import '../../domain/network_source_result.dart';

const bool isSupported = false;

Future<void> testConnection(NetworkSourceConfig config) async {
  throw UnsupportedError('Network sources are not supported on this platform');
}

Future<NetworkSourceDraft?> validateAndBrowse(
  BuildContext context, {
  required NetworkSourceConfig config,
  required String title,
  required String badge,
}) async {
  throw UnsupportedError('Network sources are not supported on this platform');
}
