import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

import '../domain/media_item.dart';
import '../domain/network_source_config.dart';

@immutable
class WebDavDirectoryEntry {
  const WebDavDirectoryEntry({required this.name, required this.path});

  final String name;
  final String path;
}

class WebDavBrowseResult {
  const WebDavBrowseResult({
    required this.directories,
    required this.items,
    required this.normalizedPath,
  });

  final List<WebDavDirectoryEntry> directories;
  final List<MediaItem> items;
  final String normalizedPath;
}

typedef WebDavPropfind = Future<http.Response> Function(
  NetworkSourceConfig config, {
  required String depth,
});

class WebDavClient {
  WebDavClient({WebDavPropfind? propfind}) : _propfindOverride = propfind;

  final WebDavPropfind? _propfindOverride;

  Future<void> validate(NetworkSourceConfig config) async {
    try {
      final response = await _propfind(config, depth: '0');
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw WebDavException(
          _messageForResponse(
            response,
            config,
            responseBody: _decodeResponseBody(response),
            stage: '连接验证',
            depth: '0',
          ),
        );
      }
    } on WebDavException {
      rethrow;
    } catch (error) {
      throw WebDavException(
        _messageForUnexpectedError(
          error,
          config,
          stage: '连接验证',
          depth: '0',
        ),
      );
    }
  }

  Future<WebDavBrowseResult> browseDirectory(NetworkSourceConfig config) async {
    try {
      final response = await _propfind(config, depth: '1');
      final responseBody = _decodeResponseBody(response);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw WebDavException(
          _messageForResponse(
            response,
            config,
            responseBody: responseBody,
            stage: '目录浏览',
            depth: '1',
          ),
        );
      }

      try {
        final document = XmlDocument.parse(responseBody);
        final normalizedPath = _normalizeRemotePath(config.remotePath);
        final responses = document.descendants
            .whereType<XmlElement>()
            .where((element) => element.name.local == 'response');

        final directories = <WebDavDirectoryEntry>[];
        final items = <MediaItem>[];
        for (final node in responses) {
          final hrefNode = node.descendants
              .whereType<XmlElement>()
              .firstWhereOrNull((element) => element.name.local == 'href');
          final href = hrefNode?.innerText.trim();
          if (href == null || href.isEmpty) {
            continue;
          }

          final rawPath = Uri.tryParse(href)?.path ?? href;
          final decodedPath = Uri.decodeFull(rawPath);
          final normalizedEntryPath = _normalizeRemotePath(decodedPath);
          if (normalizedEntryPath == normalizedPath) {
            continue;
          }

          final displayNameNode = node.descendants
              .whereType<XmlElement>()
              .firstWhereOrNull((element) => element.name.local == 'displayname');
          final fallbackName = normalizedEntryPath
              .split('/')
              .where((segment) => segment.isNotEmpty)
              .lastOrNull
              ?.takeIfNotEmpty();
          final name = displayNameNode?.innerText.trim().takeIfNotEmpty() ?? fallbackName;
          if (name == null) {
            continue;
          }

          if (_isCollection(node)) {
            directories.add(
              WebDavDirectoryEntry(name: name, path: normalizedEntryPath),
            );
            continue;
          }

          if (!_isSupportedImage(name)) {
            continue;
          }

          items.add(
            MediaItem(
              id: '${config.stableId}:$normalizedEntryPath',
              title: name,
              path: _buildRemoteUrl(config, normalizedEntryPath),
              description: normalizedEntryPath,
              kind: MediaItemKind.remote,
            ),
          );
        }

        directories.sort(
          (left, right) => left.name.toLowerCase().compareTo(right.name.toLowerCase()),
        );
        items.sort(
          (left, right) => left.title.toLowerCase().compareTo(right.title.toLowerCase()),
        );

        return WebDavBrowseResult(
          directories: directories,
          items: items,
          normalizedPath: normalizedPath,
        );
      } catch (error) {
        throw WebDavException(
          _messageForUnexpectedBody(
            responseBody,
            config,
            stage: '目录浏览响应解析',
            depth: '1',
            error: error,
          ),
        );
      }
    } on WebDavException {
      rethrow;
    } catch (error) {
      throw WebDavException(
        _messageForUnexpectedError(
          error,
          config,
          stage: '目录浏览',
          depth: '1',
        ),
      );
    }
  }

  Future<http.Response> _propfind(
    NetworkSourceConfig config, {
    required String depth,
  }) async {
    final override = _propfindOverride;
    if (override != null) {
      return override(config, depth: depth);
    }

    final request = http.Request('PROPFIND', config.directoryUri)
      ..headers.addAll({
        'depth': depth,
        ...config.authorizationHeaders,
      })
      ..body = '''<?xml version="1.0" encoding="utf-8" ?>
<D:propfind xmlns:D="DAV:">
  <D:prop>
    <D:resourcetype />
    <D:displayname />
  </D:prop>
</D:propfind>''';

    final streamed = await request.send();
    return http.Response.fromStream(streamed);
  }

  String _messageForStatus(int statusCode) {
    return switch (statusCode) {
      401 || 403 => 'WebDAV 认证失败，请检查用户名或密码',
      404 => 'WebDAV 路径不存在，请检查远程目录',
      _ => 'WebDAV 连接失败（$statusCode）',
    };
  }

  String _messageForResponse(
    http.Response response,
    NetworkSourceConfig config, {
    required String responseBody,
    required String stage,
    required String depth,
  }) {
    final snippet = _bodySnippet(responseBody);
    final lines = <String>[
      _messageForStatus(response.statusCode),
      '阶段：$stage',
      '地址：${config.endpointLabel}',
      'Depth：$depth',
      '状态码：${response.statusCode}',
    ];
    if (snippet != null) {
      lines.add('响应摘要：$snippet');
    }
    return lines.join('\n');
  }

  String _messageForUnexpectedError(
    Object error,
    NetworkSourceConfig config, {
    required String stage,
    required String depth,
  }) {
    final lines = <String>[
      'WebDAV 请求发生异常',
      '阶段：$stage',
      '地址：${config.endpointLabel}',
      'Depth：$depth',
      '异常：${error.runtimeType}',
      '详情：${error.toString().trim()}',
    ];
    return lines.join('\n');
  }

  String _messageForUnexpectedBody(
    String body,
    NetworkSourceConfig config, {
    required String stage,
    required String depth,
    required Object error,
  }) {
    final snippet = _bodySnippet(body);
    final lines = <String>[
      'WebDAV 目录响应无法解析，请确认地址指向可浏览的 WebDAV 目录',
      '阶段：$stage',
      '地址：${config.endpointLabel}',
      'Depth：$depth',
      '异常：${error.runtimeType}',
    ];
    if (snippet != null) {
      lines.add('响应摘要：$snippet');
    }
    return lines.join('\n');
  }

  String _decodeResponseBody(http.Response response) {
    if (response.bodyBytes.isEmpty) {
      return '';
    }

    final contentType = response.headers['content-type'];
    final charset = _extractCharset(contentType);
    if (charset == 'iso-8859-1' || charset == 'latin1') {
      return latin1.decode(response.bodyBytes);
    }

    try {
      return utf8.decode(response.bodyBytes);
    } on FormatException {
      return latin1.decode(response.bodyBytes);
    }
  }

  String? _extractCharset(String? contentType) {
    if (contentType == null) {
      return null;
    }
    final match = RegExp(r'charset=([^;]+)', caseSensitive: false).firstMatch(contentType);
    return match?.group(1)?.trim().toLowerCase();
  }

  String? _bodySnippet(String body) {
    final compact = body.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (compact.isEmpty) {
      return null;
    }
    if (compact.length <= 220) {
      return compact;
    }
    return '${compact.substring(0, 220)}…';
  }

  bool _isCollection(XmlElement node) {
    return node.descendants
        .whereType<XmlElement>()
        .any((element) => element.name.local == 'collection');
  }

  bool _isSupportedImage(String name) {
    final lower = name.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp');
  }

  String _normalizeRemotePath(String path) {
    if (path.trim().isEmpty) {
      return '/';
    }
    final normalized = path.startsWith('/') ? path : '/$path';
    return normalized.endsWith('/') && normalized.length > 1
        ? normalized.substring(0, normalized.length - 1)
        : normalized;
  }

  String _buildRemoteUrl(NetworkSourceConfig config, String path) {
    final uri = Uri(
      scheme: config.secure ? 'https' : 'http',
      host: config.host,
      port: config.port,
      path: path,
    );
    return uri.toString();
  }
}

class WebDavException implements Exception {
  const WebDavException(this.message);

  final String message;

  @override
  String toString() => message;
}

extension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T value) test) {
    for (final value in this) {
      if (test(value)) {
        return value;
      }
    }
    return null;
  }
}

extension on Iterable<String> {
  String? get lastOrNull => isEmpty ? null : last;
}

extension on String {
  String? takeIfNotEmpty() => trim().isEmpty ? null : trim();
}

final webDavClientProvider = Provider<WebDavClient>((ref) {
  return WebDavClient();
});
