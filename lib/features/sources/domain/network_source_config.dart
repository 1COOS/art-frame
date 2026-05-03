import 'dart:convert';

import 'package:flutter/foundation.dart';

enum NetworkSourceProtocol { webdav, smb, sftp }

@immutable
class NetworkSourceConfig {
  const NetworkSourceConfig({
    required this.protocol,
    required this.host,
    required this.remotePath,
    this.secure = true,
    this.port,
    this.username,
    this.password,
    this.displayName,
    this.domain,
  });

  factory NetworkSourceConfig.fromJson(Map<String, Object?> json) {
    return NetworkSourceConfig(
      protocol: NetworkSourceProtocol.values.byName(
        json['protocol'] as String,
      ),
      host: json['host'] as String,
      remotePath: json['remotePath'] as String,
      secure: json['secure'] as bool? ?? true,
      port: json['port'] as int?,
      username: json['username'] as String?,
      displayName: json['displayName'] as String?,
      domain: json['domain'] as String?,
    );
  }

  final NetworkSourceProtocol protocol;
  final String host;
  final String remotePath;
  final bool secure;
  final int? port;
  final String? username;
  final String? password;
  final String? displayName;
  final String? domain;

  String get stableId {
    final buffer = StringBuffer(protocol.name)
      ..write(':')
      ..write(_stableScheme)
      ..write(':')
      ..write(host)
      ..write(':')
      ..write(port ?? '')
      ..write(':')
      ..write(remotePath)
      ..write(':')
      ..write(username ?? '')
      ..write(':')
      ..write(domain ?? '');
    return buffer.toString();
  }

  String get _stableScheme {
    return switch (protocol) {
      NetworkSourceProtocol.webdav => secure ? 'https' : 'http',
      NetworkSourceProtocol.smb => 'smb',
      NetworkSourceProtocol.sftp => 'sftp',
    };
  }

  Uri get directoryUri {
    final normalizedPath = _normalizedRemotePath;
    return Uri(
      scheme: secure ? 'https' : 'http',
      host: host,
      port: port,
      path: normalizedPath,
    );
  }

  String get smbPath {
    if (protocol != NetworkSourceProtocol.smb) {
      return _normalizedRemotePath;
    }
    final normalizedPath = _normalizedRemotePath;
    return normalizedPath == '/' ? '/' : normalizedPath;
  }

  String get endpointLabel {
    final normalizedPath = _normalizedRemotePath;
    final suffix = port == null ? '' : ':$port';
    return switch (protocol) {
      NetworkSourceProtocol.webdav =>
        '${secure ? 'https' : 'http'}://$host$suffix$normalizedPath',
      NetworkSourceProtocol.smb => 'smb://$host$suffix$normalizedPath',
      NetworkSourceProtocol.sftp => 'sftp://$host$suffix$normalizedPath',
    };
  }

  Map<String, String> get authorizationHeaders {
    if (protocol != NetworkSourceProtocol.webdav) {
      return const <String, String>{};
    }

    final username = this.username;
    final password = this.password;
    if (username == null || username.isEmpty || password == null) {
      return const <String, String>{};
    }

    final token = base64Encode(utf8.encode('$username:$password'));
    return <String, String>{'authorization': 'Basic $token'};
  }

  NetworkSourceConfig copyWith({
    NetworkSourceProtocol? protocol,
    String? host,
    String? remotePath,
    bool? secure,
    int? port,
    String? username,
    String? password,
    String? displayName,
    String? domain,
  }) {
    return NetworkSourceConfig(
      protocol: protocol ?? this.protocol,
      host: host ?? this.host,
      remotePath: remotePath ?? this.remotePath,
      secure: secure ?? this.secure,
      port: port ?? this.port,
      username: username ?? this.username,
      password: password ?? this.password,
      displayName: displayName ?? this.displayName,
      domain: domain ?? this.domain,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'protocol': protocol.name,
      'host': host,
      'remotePath': remotePath,
      'secure': secure,
      'port': port,
      'username': username,
      'displayName': displayName,
      'domain': domain,
    };
  }

  String get _normalizedRemotePath {
    if (remotePath.trim().isEmpty) {
      return '/';
    }
    final normalized = remotePath.startsWith('/') ? remotePath : '/$remotePath';
    return normalized.endsWith('/') && normalized.length > 1
        ? normalized.substring(0, normalized.length - 1)
        : normalized;
  }
}
