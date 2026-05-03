import 'package:flutter/material.dart';

import '../../domain/network_source_result.dart';

const bool isSupported = false;

Future<NetworkSourceValidationResult> createSource(
  BuildContext context, {
  required String title,
  required String description,
  required String badge,
  NetworkSourceDraft? initialDraft,
}) async {
  return const NetworkSourceValidationUnsupported();
}
