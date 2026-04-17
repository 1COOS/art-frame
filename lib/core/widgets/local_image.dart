import 'package:flutter/widgets.dart';

import 'local_image_stub.dart'
    if (dart.library.io) 'local_image_io.dart'
    if (dart.library.html) 'local_image_web.dart' as impl;

Widget buildLocalImage(
  String path, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
}) {
  return impl.buildLocalImage(
    path,
    width: width,
    height: height,
    fit: fit,
  );
}
