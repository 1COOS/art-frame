import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

Widget buildMediaAssetImage(
  String assetId, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  bool isOriginal = false,
}) {
  if (!_supportsMediaAssetImage()) {
    return _placeholder(width: width, height: height);
  }

  return _MediaAssetImage(
    assetId: assetId,
    width: width,
    height: height,
    fit: fit,
    isOriginal: isOriginal,
  );
}

class _MediaAssetImage extends StatelessWidget {
  const _MediaAssetImage({
    required this.assetId,
    required this.width,
    required this.height,
    required this.fit,
    required this.isOriginal,
  });

  final String assetId;
  final double? width;
  final double? height;
  final BoxFit fit;
  final bool isOriginal;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AssetEntity?>(
      future: AssetEntity.fromId(assetId),
      builder: (context, snapshot) {
        final entity = snapshot.data;
        if (entity == null) {
          return _placeholder(width: width, height: height, context: context);
        }

        return Image(
          image: AssetEntityImageProvider(
            entity,
            isOriginal: isOriginal,
            thumbnailSize: isOriginal
                ? const ThumbnailSize.square(1600)
                : const ThumbnailSize.square(320),
            thumbnailFormat: ThumbnailFormat.jpeg,
          ),
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            return _placeholder(width: width, height: height, context: context);
          },
        );
      },
    );
  }
}

Widget _placeholder({double? width, double? height, BuildContext? context}) {
  final color = context == null
      ? const Color(0x11000000)
      : Theme.of(context).colorScheme.surfaceContainerHighest;

  return ColoredBox(
    color: color,
    child: SizedBox(
      width: width,
      height: height,
      child: const Center(child: Icon(Icons.photo_library_outlined)),
    ),
  );
}

bool _supportsMediaAssetImage() {
  if (kIsWeb) {
    return false;
  }

  return switch (defaultTargetPlatform) {
    TargetPlatform.android ||
    TargetPlatform.iOS ||
    TargetPlatform.macOS => true,
    TargetPlatform.fuchsia ||
    TargetPlatform.linux ||
    TargetPlatform.windows => false,
  };
}
