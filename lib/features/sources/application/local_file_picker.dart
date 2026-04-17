import 'package:file_selector/file_selector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/media_item.dart';

const _imageTypeGroup = XTypeGroup(
  label: 'images',
  extensions: <String>['jpg', 'jpeg', 'png'],
  mimeTypes: <String>['image/jpeg', 'image/png'],
  uniformTypeIdentifiers: <String>['public.jpeg', 'public.png'],
  webWildCards: <String>['image/*'],
);

class LocalFilePicker {
  const LocalFilePicker();

  Future<List<MediaItem>> pickImages() async {
    final files = await openFiles(
      acceptedTypeGroups: const <XTypeGroup>[_imageTypeGroup],
      confirmButtonText: 'Import',
    );

    return files
        .where((file) => file.path.isNotEmpty)
        .map(
          (file) => MediaItem(
            id: file.path,
            title: file.name.isNotEmpty ? file.name : _basename(file.path),
            path: file.path,
            description: file.path,
            kind: MediaItemKind.file,
          ),
        )
        .toList(growable: false);
  }

  String _basename(String path) {
    final segments = path.split(RegExp(r'[\\/]'));
    return segments.isEmpty ? path : segments.last;
  }
}

final localFilePickerProvider = Provider<LocalFilePicker>((ref) {
  return const LocalFilePicker();
});
