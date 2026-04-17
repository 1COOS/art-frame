import 'package:flutter/material.dart';

Widget buildLocalImage(
  String path, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
}) {
  return ColoredBox(
    color: const Color(0x11000000),
    child: SizedBox(
      width: width,
      height: height,
      child: const Center(
        child: Icon(Icons.broken_image_outlined),
      ),
    ),
  );
}
