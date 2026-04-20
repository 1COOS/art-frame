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

  String get stableId {
    final buffer = StringBuffer(protocol.name)
      ..write(':')
      ..write(secure ? 'https' : 'http')
      ..write(':')
      ..write(host)
      ..write(':')
      ..write(port ?? '')
      ..write(':')
      ..write(remotePath)
      ..write(':')
      ..write(username ?? '');
    return buffer.toString();
  }

  Uri get directoryUri {
    final normalizedPath = remotePath.startsWith('/')
        ? remotePath
        : '/$remotePath';
    return Uri(
      scheme: secure ? 'https' : 'http',
      host: host,
      port: port,
      path: normalizedPath,
    );
  }

  String get endpointLabel {
    final scheme = secure ? 'https' : 'http';
    final suffix = port == null ? '' : ':$port';
    final normalizedPath = remotePath.startsWith('/') ? remotePath : '/$remotePath';
    return '$scheme://$host$suffix$normalizedPath';
  }

  Map<String, String> get authorizationHeaders {
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
    };
  }
}
