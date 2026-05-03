import 'package:flutter/material.dart';

import '../../domain/media_library_pick_result.dart';

const bool isSupported = false;

Future<MediaLibraryPickResult> pickImages(BuildContext context) async {
  return const MediaLibraryPickResult.unsupported();
}
