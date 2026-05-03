import 'dart:io';

import 'package:flutter/services.dart';

import '../../domain/media_source.dart';

const _channel = MethodChannel('art_frame/security_scope');

Future<void> persistSourceAccess(MediaSource source) async {
  if (!_canUsePlatformChannel()) {
    return;
  }

  final paths = _pathsForSource(source);
  if (paths.isEmpty) {
    return;
  }

  await _invoke('persistPaths', paths);
}

Future<void> restoreAccess(List<MediaSource> sources) async {
  if (!_canUsePlatformChannel()) {
    return;
  }

  final paths = _pathsForSources(sources);
  if (paths.isEmpty) {
    return;
  }

  await _invoke('startAccessingPaths', paths);
}

Future<void> syncSources(List<MediaSource> sources) async {
  if (!_canUsePlatformChannel()) {
    return;
  }

  await _invoke('syncKnownPaths', _pathsForSources(sources));
}

Future<void> _invoke(String method, List<String> paths) async {
  try {
    await _channel.invokeMethod<void>(method, <String, Object?>{
      'paths': paths,
    });
  } on MissingPluginException {
    return;
  }
}

List<String> _pathsForSources(List<MediaSource> sources) {
  return {
    for (final source in sources) ..._pathsForSource(source),
  }.toList(growable: false);
}

List<String> _pathsForSource(MediaSource source) {
  return switch (source.kind) {
    MediaSourceKind.localDirectory => [source.directoryPath!],
    MediaSourceKind.localFiles => [
      for (final item in source.items)
        if (item.path.isNotEmpty) item.path,
    ],
    MediaSourceKind.mediaLibrary ||
    MediaSourceKind.bundled ||
    MediaSourceKind.network => const <String>[],
  };
}

bool _canUsePlatformChannel() {
  if (!Platform.isMacOS) {
    return false;
  }

  try {
    ServicesBinding.instance;
    return true;
  } catch (_) {
    return false;
  }
}
