import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/media_item.dart';
import 'local_directory_scanner_stub.dart'
    if (dart.library.io) 'local_directory_scanner_io.dart' as impl;

class LocalDirectoryScanner {
  const LocalDirectoryScanner();

  Future<List<MediaItem>> scanImages(String directoryPath) {
    return impl.scanImages(directoryPath);
  }
}

final localDirectoryScannerProvider = Provider<LocalDirectoryScanner>((ref) {
  return const LocalDirectoryScanner();
});
