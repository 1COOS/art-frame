import 'package:flutter/foundation.dart';

import 'media_item.dart';
import 'network_source_config.dart';

enum MediaSourceKind {
  bundled,
  localDirectory,
  localFiles,
  mediaLibrary,
  network,
}

@immutable
class MediaSource {
  const MediaSource({
    required this.id,
    required this.title,
    required this.description,
    required this.badge,
    required this.items,
    this.kind = MediaSourceKind.bundled,
    this.directoryPath,
    this.networkConfig,
  });

  factory MediaSource.fromJson(Map<String, Object?> json) {
    return MediaSource(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      badge: json['badge'] as String,
      kind: MediaSourceKind.values.byName(
        (json['kind'] as String?) ?? MediaSourceKind.bundled.name,
      ),
      directoryPath: json['directoryPath'] as String?,
      networkConfig: switch (json['networkConfig']) {
        final Map<String, Object?> config => NetworkSourceConfig.fromJson(config),
        _ => null,
      },
      items: (json['items'] as List<Object?>)
          .cast<Map<String, Object?>>()
          .map(MediaItem.fromJson)
          .toList(growable: false),
    );
  }

  final String id;
  final String title;
  final String description;
  final String badge;
  final List<MediaItem> items;
  final MediaSourceKind kind;
  final String? directoryPath;
  final NetworkSourceConfig? networkConfig;

  MediaSource copyWith({
    String? id,
    String? title,
    String? description,
    String? badge,
    List<MediaItem>? items,
    MediaSourceKind? kind,
    String? directoryPath,
    NetworkSourceConfig? networkConfig,
  }) {
    return MediaSource(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      badge: badge ?? this.badge,
      items: items ?? this.items,
      kind: kind ?? this.kind,
      directoryPath: directoryPath ?? this.directoryPath,
      networkConfig: networkConfig ?? this.networkConfig,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'badge': badge,
      'kind': kind.name,
      'directoryPath': directoryPath,
      'networkConfig': networkConfig?.toJson(),
      'items': items.map((item) => item.toJson()).toList(growable: false),
    };
  }
}
