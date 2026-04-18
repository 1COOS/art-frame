import 'package:flutter/material.dart';

import 'media_asset_image_stub.dart'
    if (dart.library.io) 'media_asset_image_io.dart'
    as impl;

Widget buildMediaAssetImage(
  String assetId, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  bool isOriginal = false,
}) {
  return impl.buildMediaAssetImage(
    assetId,
    width: width,
    height: height,
    fit: fit,
    isOriginal: isOriginal,
  );
}
