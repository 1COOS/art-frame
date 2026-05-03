import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smb_connect/smb_connect.dart';

import '../../domain/media_item.dart';
import '../../domain/network_source_config.dart';
import '../../../../core/utils/image_format.dart';

const bool _enableSmbDebugLogs = kDebugMode;

@immutable
class SmbDirectoryEntry {
  const SmbDirectoryEntry({required this.name, required this.path});

  final String name;
  final String path;
}

class SmbBrowseResult {
  const SmbBrowseResult({
    required this.directories,
    required this.items,
    required this.normalizedPath,
  });

  final List<SmbDirectoryEntry> directories;
  final List<MediaItem> items;
  final String normalizedPath;
}

typedef SmbConnectFactory = Future<SmbConnect> Function(NetworkSourceConfig config);
typedef SmbFileLister = Future<List<SmbFile>> Function(
  SmbConnect connect,
  SmbFile folder,
);
typedef SmbFileReader = Future<Uint8List> Function(
  SmbConnect connect,
  SmbFile file,
);

class SmbClient {
  SmbClient({
    SmbConnectFactory? connect,
    SmbFileLister? listFiles,
    SmbFileReader? readFile,
  }) : _connectOverride = connect,
       _listFilesOverride = listFiles,
       _readFileOverride = readFile;

  final SmbConnectFactory? _connectOverride;
  final SmbFileLister? _listFilesOverride;
  final SmbFileReader? _readFileOverride;
  final Map<String, Future<Uint8List>> _inflightReads = {};
  final Map<String, Future<void>> _hostReadChains = {};
  int _nextRequestId = 1;

  Future<void> validate(NetworkSourceConfig config) async {
    final connect = await _connect(config);
    try {
      final root = await connect.file(config.smbPath);
      _log('validate.root', _diagnosticLines(config, normalizedPath: config.smbPath, file: root));
      if (!root.isExists) {
        throw const SmbException('SMB 路径不存在，请检查共享名和目录');
      }
      if (!root.isDirectory()) {
        throw const SmbException('SMB 路径不是目录，请选择可浏览的共享目录');
      }
    } on SmbException {
      rethrow;
    } catch (error) {
      throw SmbException(_messageForUnexpectedError(error, config, stage: '连接验证'));
    } finally {
      await connect.close();
    }
  }

  Future<SmbBrowseResult> browseDirectory(NetworkSourceConfig config) async {
    final connect = await _connect(config);
    try {
      final folder = await connect.file(config.smbPath);
      _log('browse.root', _diagnosticLines(config, normalizedPath: config.smbPath, file: folder));
      if (!folder.isExists) {
        throw const SmbException('SMB 路径不存在，请检查共享名和目录');
      }
      if (!folder.isDirectory()) {
        throw const SmbException('SMB 路径不是目录，请选择可浏览的共享目录');
      }

      final files = await _listFiles(connect, folder);
      final directories = <SmbDirectoryEntry>[];
      final items = <MediaItem>[];
      final normalizedPath = _normalizeRemotePath(folder.path);

      for (final entry in files) {
        final normalizedEntryPath = _normalizeRemotePath(entry.path);
        if (normalizedEntryPath == normalizedPath) {
          continue;
        }

        if (entry.isDirectory()) {
          directories.add(
            SmbDirectoryEntry(name: entry.name, path: normalizedEntryPath),
          );
          continue;
        }

        if (!isSupportedImage(entry.name)) {
          continue;
        }

        items.add(
          MediaItem(
            id: '${config.stableId}:$normalizedEntryPath',
            title: entry.name,
            path: normalizedEntryPath,
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

      return SmbBrowseResult(
        directories: directories,
        items: items,
        normalizedPath: normalizedPath,
      );
    } on SmbException {
      rethrow;
    } catch (error) {
      throw SmbException(_messageForUnexpectedError(error, config, stage: '目录浏览'));
    } finally {
      await connect.close();
    }
  }

  Future<Uint8List> readFileBytes(
    NetworkSourceConfig config,
    String remotePath,
  ) {
    final requestId = _nextRequestId++;
    final normalizedPath = _normalizeRemotePath(remotePath);
    final readKey = '${config.stableId}:$normalizedPath';
    final hostKey = _hostReadKey(config);
    _log('read.request.start', [
      'requestId：$requestId',
      'key：$readKey',
      'hostKey：$hostKey',
      'normalizedPath：$normalizedPath',
      'inflightReads：${_inflightReads.length}',
    ]);
    final inflight = _inflightReads[readKey];
    if (inflight != null) {
      _log('read.dedup.hit', [
        'requestId：$requestId',
        'key：$readKey',
        'normalizedPath：$normalizedPath',
      ]);
      return inflight;
    }

    final future = _serializeRead(
      hostKey,
      requestId,
      () => _readFileBytesInternal(config, normalizedPath, requestId),
    );
    _inflightReads[readKey] = future;
    return future.whenComplete(() {
      if (identical(_inflightReads[readKey], future)) {
        _inflightReads.remove(readKey);
      }
      _log('read.request.finish', [
        'requestId：$requestId',
        'key：$readKey',
        'hostKey：$hostKey',
        'normalizedPath：$normalizedPath',
        'inflightReads：${_inflightReads.length}',
      ]);
    });
  }

  String _hostReadKey(NetworkSourceConfig config) {
    return [
      config.host,
      '${config.port ?? 445}',
      config.username ?? '',
      config.domain ?? '',
    ].join(':');
  }

  Future<T> _serializeRead<T>(
    String hostKey,
    int requestId,
    Future<T> Function() action,
  ) {
    final previous = _hostReadChains[hostKey];
    if (previous != null) {
      _log('read.hostQueue.wait', [
        'requestId：$requestId',
        'hostKey：$hostKey',
      ]);
    }

    final gate = Completer<void>();
    final completer = Completer<T>();

    () async {
      try {
        if (previous != null) {
          try {
            await previous;
          } catch (_) {}
        }
        _log('read.hostQueue.start', [
          'requestId：$requestId',
          'hostKey：$hostKey',
        ]);
        final result = await action();
        if (!completer.isCompleted) {
          completer.complete(result);
        }
      } catch (error, stackTrace) {
        if (!completer.isCompleted) {
          completer.completeError(error, stackTrace);
        }
      } finally {
        if (!gate.isCompleted) {
          gate.complete();
        }
        if (identical(_hostReadChains[hostKey], gate.future)) {
          _hostReadChains.remove(hostKey);
        }
        _log('read.hostQueue.finish', [
          'requestId：$requestId',
          'hostKey：$hostKey',
        ]);
      }
    }();

    _hostReadChains[hostKey] = gate.future;
    return completer.future;
  }

  Future<T> _guardLibraryCall<T>(
    Future<T> Function() action,
    NetworkSourceConfig config, {
    required String stage,
    required String normalizedPath,
    SmbFile? file,
  }) async {
    try {
      return await action();
    } catch (error) {
      if (error is SmbException) {
        rethrow;
      }
      throw SmbException(
        _messageForUnexpectedError(
          error,
          config,
          stage: stage,
          normalizedPath: normalizedPath,
          file: file,
        ),
      );
    }
  }

  Future<void> _closeSafely(
    SmbConnect connect,
    NetworkSourceConfig config, {
    required String normalizedPath,
    required int requestId,
    required Stopwatch stopwatch,
  }) async {
    try {
      await connect.close();
    } catch (error) {
      _log('read.connect.close.failure', [
        'requestId：$requestId',
        'connectType：${connect.runtimeType}',
        'connectId：${identityHashCode(connect)}',
        'elapsedMs：${stopwatch.elapsedMilliseconds}',
        _messageForUnexpectedError(
          error,
          config,
          stage: '关闭 SMB 连接',
          normalizedPath: normalizedPath,
        ),
      ]);
    }
  }

  Future<void> _closeRandomAccessSafely(
    RandomAccessFile randomAccessFile,
    NetworkSourceConfig config, {
    required String normalizedPath,
    required SmbFile file,
    required int requestId,
    required Stopwatch stopwatch,
    required SmbConnect connect,
  }) async {
    try {
      await randomAccessFile.close();
    } catch (error) {
      _log('read.randomAccess.close.failure', [
        'requestId：$requestId',
        'connectType：${connect.runtimeType}',
        'connectId：${identityHashCode(connect)}',
        'fileId：${identityHashCode(file)}',
        'elapsedMs：${stopwatch.elapsedMilliseconds}',
        _messageForUnexpectedError(
          error,
          config,
          stage: '关闭 SMB 随机读取句柄',
          normalizedPath: normalizedPath,
          file: file,
        ),
      ]);
    }
  }

  Future<Uint8List> _readFileBytesInternal(
    NetworkSourceConfig config,
    String normalizedPath,
    int requestId,
  ) async {
    final stopwatch = Stopwatch()..start();
    final connect = await _guardLibraryCall(
      () => _connect(config, requestId: requestId),
      config,
      stage: '建立连接',
      normalizedPath: normalizedPath,
    );
    final targetFile = _targetFile(normalizedPath);
    try {
      _log('read.lookup.start', [
        'requestId：$requestId',
        'connectType：${connect.runtimeType}',
        'connectId：${identityHashCode(connect)}',
        'normalizedPath：$normalizedPath',
        'target.share：${targetFile.share}',
        'target.uncPath：${targetFile.uncPath}',
        'target.name：${targetFile.name}',
      ]);
      return _readFileBytes(connect, targetFile, config, normalizedPath, requestId, stopwatch);
    } on SmbException {
      rethrow;
    } catch (error) {
      final fileForDiagnostics = await _loadDiagnosticFile(
        config,
        normalizedPath,
        requestId,
      );
      throw SmbException(
        _messageForUnexpectedError(
          error,
          config,
          stage: '读取 SMB 文件',
          normalizedPath: normalizedPath,
          file: fileForDiagnostics,
        ),
      );
    } finally {
      _log('read.connect.close', [
        'requestId：$requestId',
        'connectType：${connect.runtimeType}',
        'connectId：${identityHashCode(connect)}',
        'elapsedMs：${stopwatch.elapsedMilliseconds}',
      ]);
      await connect.close();
    }
  }

  Future<SmbConnect> _connect(
    NetworkSourceConfig config, {
    int? requestId,
  }) async {
    if (config.port != null && config.port != 445) {
      throw const SmbException('当前 SMB 实现仅支持默认 445 端口');
    }

    final override = _connectOverride;
    if (override != null) {
      return override(config);
    }

    final stopwatch = Stopwatch()..start();
    _log('connect.start', [
      if (requestId != null) 'requestId：$requestId',
      'host：${config.host}',
      'port：${config.port ?? 445}',
      'path：${config.smbPath}',
    ]);

    try {
      final connection = await SmbConnect.connectAuth(
        host: config.host,
        domain: config.domain ?? '',
        username: config.username ?? '',
        password: config.password ?? '',
        debugPrint: _enableSmbDebugLogs,
        debugPrintLowLevel: _enableSmbDebugLogs,
      );
      _log('connect.success', [
        if (requestId != null) 'requestId：$requestId',
        'connectType：${connection.runtimeType}',
        'connectId：${identityHashCode(connection)}',
        'elapsedMs：${stopwatch.elapsedMilliseconds}',
        ..._diagnosticLines(config, normalizedPath: config.smbPath),
      ]);
      return connection;
    } catch (error) {
      throw SmbException(
        _messageForUnexpectedError(error, config, stage: '建立连接'),
      );
    }
  }

  Future<List<SmbFile>> _listFiles(SmbConnect connect, SmbFile folder) async {
    final override = _listFilesOverride;
    if (override != null) {
      return override(connect, folder);
    }
    return connect.listFiles(folder);
  }

  Future<Uint8List> _readFileBytes(
    SmbConnect connect,
    SmbFile file,
    NetworkSourceConfig config,
    String normalizedPath,
    int requestId,
    Stopwatch stopwatch,
  ) async {
    final override = _readFileOverride;
    if (override != null) {
      return override(connect, file);
    }

    try {
      _log('read.openRead.start', [
        'requestId：$requestId',
        'connectType：${connect.runtimeType}',
        'connectId：${identityHashCode(connect)}',
        'fileId：${identityHashCode(file)}',
        'elapsedMs：${stopwatch.elapsedMilliseconds}',
        ..._diagnosticLines(config, normalizedPath: normalizedPath, file: file),
      ]);
      final reader = await _guardLibraryCall(
        () => connect.openRead(file),
        config,
        stage: '打开 SMB 文件流',
        normalizedPath: normalizedPath,
        file: file,
      );
      final builder = BytesBuilder(copy: false);
      await for (final chunk in reader) {
        builder.add(chunk);
      }
      _log('read.openRead.success', [
        'requestId：$requestId',
        'connectType：${connect.runtimeType}',
        'connectId：${identityHashCode(connect)}',
        'fileId：${identityHashCode(file)}',
        'normalizedPath：$normalizedPath',
        'bytes：${builder.length}',
        'elapsedMs：${stopwatch.elapsedMilliseconds}',
      ]);
      return builder.takeBytes();
    } catch (openReadError) {
      final fileForDiagnostics = await _loadDiagnosticFile(
        config,
        normalizedPath,
        requestId,
      );
      _log('read.openRead.failure', [
        'requestId：$requestId',
        'connectType：${connect.runtimeType}',
        'connectId：${identityHashCode(connect)}',
        'fileId：${identityHashCode(file)}',
        'elapsedMs：${stopwatch.elapsedMilliseconds}',
        _messageForUnexpectedError(
          openReadError,
          config,
          stage: '打开 SMB 文件流',
          normalizedPath: normalizedPath,
          file: fileForDiagnostics,
        ),
      ]);
      try {
        _log('read.randomAccess.start', [
          'requestId：$requestId',
          'connectType：${connect.runtimeType}',
          'connectId：${identityHashCode(connect)}',
          'fileId：${identityHashCode(file)}',
          'elapsedMs：${stopwatch.elapsedMilliseconds}',
          ..._diagnosticLines(config, normalizedPath: normalizedPath, file: fileForDiagnostics ?? file),
        ]);
        final randomAccessFile = await _guardLibraryCall(
          () => connect.open(file, mode: FileMode.read),
          config,
          stage: '打开 SMB 随机读取句柄',
          normalizedPath: normalizedPath,
          file: fileForDiagnostics ?? file,
        );
        try {
          final length = await randomAccessFile.length();
          final bytes = await randomAccessFile.read(length);
          _log('read.randomAccess.success', [
            'requestId：$requestId',
            'connectType：${connect.runtimeType}',
            'connectId：${identityHashCode(connect)}',
            'fileId：${identityHashCode(file)}',
            'normalizedPath：$normalizedPath',
            'bytes：${bytes.length}',
            'elapsedMs：${stopwatch.elapsedMilliseconds}',
          ]);
          return bytes;
        } finally {
          await _closeRandomAccessSafely(
            randomAccessFile,
            config,
            normalizedPath: normalizedPath,
            file: fileForDiagnostics ?? file,
            requestId: requestId,
            stopwatch: stopwatch,
            connect: connect,
          );
        }
      } catch (openError) {
        throw SmbException(
          [
            _messageForUnexpectedError(
              openReadError,
              config,
              stage: '打开 SMB 文件流',
              normalizedPath: normalizedPath,
              file: fileForDiagnostics,
            ),
            '',
            'fallback：RandomAccessFile.open',
            'fallback异常：${openError.runtimeType}',
            'fallback详情：${openError.toString().trim()}',
          ].join('\n'),
        );
      }
    }
  }

  SmbFile _targetFile(String normalizedPath) {
    return SmbFile(
      normalizedPath,
      SmbConnect.getUncPath(normalizedPath),
      SmbConnect.getShare(normalizedPath),
      0,
      0,
      0,
      0,
      0,
      true,
    );
  }

  Future<SmbFile?> _loadDiagnosticFile(
    NetworkSourceConfig config,
    String normalizedPath,
    int requestId,
  ) async {
    SmbConnect? diagnosticsConnect;
    try {
      _log('read.diagnostics.start', [
        'requestId：$requestId',
        'normalizedPath：$normalizedPath',
      ]);
      diagnosticsConnect = await _guardLibraryCall(
        () => _connect(config, requestId: requestId),
        config,
        stage: '建立诊断连接',
        normalizedPath: normalizedPath,
      );
      final file = await _guardLibraryCall(
        () => diagnosticsConnect!.file(normalizedPath),
        config,
        stage: '读取 SMB 文件诊断信息',
        normalizedPath: normalizedPath,
      );
      _log('read.lookup', [
        'requestId：$requestId',
        'connectType：${diagnosticsConnect.runtimeType}',
        'connectId：${identityHashCode(diagnosticsConnect)}',
        'fileId：${identityHashCode(file)}',
        ..._diagnosticLines(config, normalizedPath: normalizedPath, file: file),
      ]);
      return file;
    } catch (error) {
      _log('read.diagnostics.failure', [
        'requestId：$requestId',
        'normalizedPath：$normalizedPath',
        '异常：${error.runtimeType}',
        '详情：${error.toString().trim()}',
      ]);
      return null;
    } finally {
      if (diagnosticsConnect != null) {
        await _closeSafely(
          diagnosticsConnect,
          config,
          normalizedPath: normalizedPath,
          requestId: requestId,
          stopwatch: Stopwatch()..start(),
        );
      }
    }
  }

  List<String> _diagnosticLines(
    NetworkSourceConfig config, {
    required String normalizedPath,
    SmbFile? file,
  }) {
    return [
      '地址：${config.endpointLabel}',
      'host：${config.host}',
      'port：${config.port ?? 445}',
      'username：${config.username ?? ''}',
      'domain：${config.domain ?? ''}',
      'configuredPath：${config.remotePath}',
      'normalizedPath：$normalizedPath',
      if (file != null) 'file.path：${file.path}',
      if (file != null) 'file.uncPath：${file.uncPath}',
      if (file != null) 'file.share：${file.share}',
      if (file != null) 'file.name：${file.name}',
      if (file != null) 'file.exists：${file.isExists}',
      if (file != null) 'file.isDirectory：${file.isDirectory()}',
      if (file != null) 'file.isFile：${file.isFile()}',
      if (file != null) 'file.canRead：${file.canRead()}',
      if (file != null) 'file.size：${file.size}',
    ];
  }

  String _messageForUnexpectedError(
    Object error,
    NetworkSourceConfig config, {
      required String stage,
      String? normalizedPath,
      SmbFile? file,
    }) {
    return [
      'SMB 请求发生异常',
      '阶段：$stage',
      '异常：${error.runtimeType}',
      '详情：${error.toString().trim()}',
      ..._diagnosticLines(
        config,
        normalizedPath: normalizedPath ?? config.smbPath,
        file: file,
      ),
    ].join('\n');
  }

  void _log(String tag, List<String> lines) {
    if (!_enableSmbDebugLogs) {
      return;
    }
    debugPrint('[SMB][$tag]');
    for (final line in lines) {
      debugPrint(line);
    }
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
}

class SmbException implements Exception {
  const SmbException(this.message);

  final String message;

  @override
  String toString() => message;
}

final smbClientProvider = Provider<SmbClient>((ref) {
  return SmbClient();
});
