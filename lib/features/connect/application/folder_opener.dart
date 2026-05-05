import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

const _channel = MethodChannel('art_frame/folder_opener');

bool get _isAndroid =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

/// Opens a folder path in the platform's file manager.
///
/// On Android, uses a platform channel to avoid [FileUriExposedException]
/// by converting file paths to content URIs.  On other platforms, delegates
/// to [launchUrl] with a `file://` directory URI.
Future<bool> openFolder(String path) async {
  if (_isAndroid) {
    try {
      final result = await _channel.invokeMethod<bool>('openFolder', {
        'path': path,
      });
      return result ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  return launchUrl(
    Uri.directory(
      path,
      windows: !kIsWeb && defaultTargetPlatform == TargetPlatform.windows,
    ),
    mode: LaunchMode.externalApplication,
  );
}

/// Opens the system gallery / photos app.  Only supported on Android.
Future<bool> openGallery() async {
  if (!_isAndroid) return false;

  try {
    final result = await _channel.invokeMethod<bool>('openGallery');
    return result ?? false;
  } on PlatformException {
    return false;
  } on MissingPluginException {
    return false;
  }
}
