import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../domain/media_item.dart';
import 'media_library_picker_result.dart';

bool get isSupported {
  if (kIsWeb) {
    return false;
  }

  return switch (defaultTargetPlatform) {
    TargetPlatform.android || TargetPlatform.iOS => true,
    TargetPlatform.fuchsia ||
    TargetPlatform.linux ||
    TargetPlatform.macOS ||
    TargetPlatform.windows => false,
  };
}

Future<MediaLibraryPickResult> pickImages(BuildContext context) async {
  if (!isSupported) {
    return const MediaLibraryPickResult.unsupported();
  }

  final permission = await PhotoManager.requestPermissionExtend();
  if (!permission.hasAccess) {
    return const MediaLibraryPickResult.permissionDenied();
  }

  if (!context.mounted) {
    return const MediaLibraryPickResult.cancelled();
  }

  final assets = await AssetPicker.pickAssets(
    context,
    pickerConfig: const AssetPickerConfig(
      maxAssets: 200,
      requestType: RequestType.image,
    ),
  );

  if (assets == null) {
    return const MediaLibraryPickResult.cancelled();
  }

  if (assets.isEmpty) {
    return const MediaLibraryPickResult.empty();
  }

  return MediaLibraryPickResult.success(
    assets.map(_toMediaItem).toList(growable: false),
  );
}

MediaItem _toMediaItem(AssetEntity asset) {
  final title = (asset.title ?? '').trim();
  final resolvedTitle = title.isNotEmpty ? title : asset.id;

  return MediaItem(
    id: asset.id,
    title: resolvedTitle,
    path: asset.id,
    description: resolvedTitle,
    kind: MediaItemKind.mediaAsset,
  );
}
