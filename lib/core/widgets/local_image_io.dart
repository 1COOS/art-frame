import 'dart:io';

import 'package:flutter/material.dart';

Widget buildLocalImage(
  String path, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
}) {
  return Image.file(
    File(path),
    width: width,
    height: height,
    fit: fit,
    errorBuilder: (context, error, stackTrace) {
      return ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: SizedBox(
          width: width,
          height: height,
          child: const Center(
            child: Icon(Icons.broken_image_outlined),
          ),
        ),
      );
    },
  );
}
