import 'package:flutter/foundation.dart';

import '../domain/media_item.dart';
import '../domain/network_source_config.dart';

@immutable
class NetworkSourceDraft {
  const NetworkSourceDraft({
    required this.title,
    required this.description,
    required this.badge,
    required this.config,
    required this.items,
  });

  final String title;
  final String description;
  final String badge;
  final NetworkSourceConfig config;
  final List<MediaItem> items;
}

@immutable
sealed class NetworkSourceValidationResult {
  const NetworkSourceValidationResult();
}

class NetworkSourceValidationSuccess extends NetworkSourceValidationResult {
  const NetworkSourceValidationSuccess(this.draft);

  final NetworkSourceDraft draft;
}

class NetworkSourceValidationCancelled extends NetworkSourceValidationResult {
  const NetworkSourceValidationCancelled();
}

class NetworkSourceValidationUnsupported extends NetworkSourceValidationResult {
  const NetworkSourceValidationUnsupported();
}

class NetworkSourceValidationFailure extends NetworkSourceValidationResult {
  const NetworkSourceValidationFailure(this.message);

  final String message;
}
