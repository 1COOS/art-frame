import 'package:flutter/foundation.dart';

import 'media_item.dart';

enum MediaSourceKind { bundled, localDirectory, localFiles, mediaLibrary }

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

  MediaSource copyWith({
    String? id,
    String? title,
    String? description,
    String? badge,
    List<MediaItem>? items,
    MediaSourceKind? kind,
    String? directoryPath,
  }) {
    return MediaSource(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      badge: badge ?? this.badge,
      items: items ?? this.items,
      kind: kind ?? this.kind,
      directoryPath: directoryPath ?? this.directoryPath,
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
      'items': items.map((item) => item.toJson()).toList(growable: false),
    };
  }
}
