import 'package:flutter/foundation.dart';

enum MediaItemKind { asset, file, mediaAsset, remote }

@immutable
class MediaItem {
  const MediaItem({
    required this.id,
    required this.title,
    required this.path,
    required this.description,
    this.kind = MediaItemKind.asset,
  });

  factory MediaItem.fromJson(Map<String, Object?> json) {
    return MediaItem(
      id: json['id'] as String,
      title: json['title'] as String,
      path: json['path'] as String,
      description: json['description'] as String,
      kind: MediaItemKind.values.byName(
        (json['kind'] as String?) ?? MediaItemKind.asset.name,
      ),
    );
  }

  final String id;
  final String title;
  final String path;
  final String description;
  final MediaItemKind kind;

  String get assetPath => path;

  MediaItem copyWith({
    String? id,
    String? title,
    String? path,
    String? description,
    MediaItemKind? kind,
  }) {
    return MediaItem(
      id: id ?? this.id,
      title: title ?? this.title,
      path: path ?? this.path,
      description: description ?? this.description,
      kind: kind ?? this.kind,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'title': title,
      'path': path,
      'description': description,
      'kind': kind.name,
    };
  }
}
