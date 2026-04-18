import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'media_library_picker_result.dart';
import 'media_library_picker_stub.dart'
    if (dart.library.io) 'media_library_picker_io.dart'
    as impl;

class MediaLibraryPicker {
  const MediaLibraryPicker();

  bool get isSupported => impl.isSupported;

  Future<MediaLibraryPickResult> pickImages(BuildContext context) {
    return impl.pickImages(context);
  }
}

final mediaLibraryPickerProvider = Provider<MediaLibraryPicker>((ref) {
  return const MediaLibraryPicker();
});
