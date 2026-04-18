import 'package:flutter/material.dart';

Widget buildMediaAssetImage(
  String assetId, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  bool isOriginal = false,
}) {
  return ColoredBox(
    color: const Color(0x11000000),
    child: SizedBox(
      width: width,
      height: height,
      child: const Center(child: Icon(Icons.photo_library_outlined)),
    ),
  );
}
