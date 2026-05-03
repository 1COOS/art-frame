import 'dart:io';

import '../../../../core/utils/image_format.dart';
import '../../domain/media_item.dart';

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
    if (!isSupportedImage(path)) {
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
