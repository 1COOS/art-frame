import 'dart:io';

import '../domain/media_item.dart';

const _supportedImageExtensions = <String>{'.jpg', '.jpeg', '.png'};

Future<List<MediaItem>> scanImages(String directoryPath) async {
  final directory = Directory(directoryPath);
  if (!await directory.exists()) {
    return const <MediaItem>[];
  }

  final items = <MediaItem>[];

  await for (final entity in directory.list(followLinks: false)) {
    if (entity is! File) {
      continue;
    }

    final path = entity.path;
    final lowerPath = path.toLowerCase();
    final isSupported = _supportedImageExtensions.any(
      (extension) => lowerPath.endsWith(extension),
    );
    if (!isSupported) {
      continue;
    }

    final name = _basename(path);
    items.add(
      MediaItem(
        id: path,
        title: name.isNotEmpty ? name : path,
        path: path,
        description: path,
        kind: MediaItemKind.file,
      ),
    );
  }

  items.sort((left, right) => left.path.compareTo(right.path));
  return items;
}

String _basename(String path) {
  final segments = path.split(RegExp(r'[\\/]'));
  return segments.isEmpty ? path : segments.last;
}
