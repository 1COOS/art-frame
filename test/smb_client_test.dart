import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:smb_connect/smb_connect.dart';

import 'package:art_frame/features/sources/application/network/smb_client.dart';
import 'package:art_frame/features/sources/domain/media_item.dart';
import 'package:art_frame/features/sources/domain/network_source_config.dart';

void main() {
  group('SmbClient', () {
    const config = NetworkSourceConfig(
      protocol: NetworkSourceProtocol.smb,
      host: 'demo.local',
      remotePath: '/public/gallery',
      port: 445,
      username: 'demo',
      password: 'secret',
      displayName: 'SMB Demo',
    );

    test('browseDirectory returns child directories and image files', () async {
      final client = SmbClient(
        connect: (_) async => _FakeSmbConnect(),
        listFiles: (connect, folder) async => [
          _fakeDirectory('/public/gallery/albums', 'albums'),
          _fakeFile('/public/gallery/cover.jpg', 'cover.jpg'),
          _fakeFile('/public/gallery/readme.txt', 'readme.txt'),
          _fakeFile('/public/gallery/poster.png', 'poster.png'),
        ],
      );

      final result = await client.browseDirectory(config);

      expect(result.normalizedPath, '/public/gallery');
      expect(result.directories, hasLength(1));
      expect(result.directories.first.name, 'albums');
      expect(result.directories.first.path, '/public/gallery/albums');
      expect(result.items, hasLength(2));
      expect(result.items.map((item) => item.title), ['cover.jpg', 'poster.png']);
      expect(result.items.every((item) => item.kind == MediaItemKind.remote), isTrue);
    });

    test('readFileBytes rejects non-default ports for current implementation', () async {
      const customPortConfig = NetworkSourceConfig(
        protocol: NetworkSourceProtocol.smb,
        host: 'demo.local',
        remotePath: '/public/gallery',
        port: 1445,
        username: 'demo',
        password: 'secret',
      );

      final client = SmbClient(
        connect: (_) async => throw StateError('should not connect'),
      );

      await expectLater(
        () => client.readFileBytes(customPortConfig, '/public/gallery/cover.jpg'),
        throwsA(
          isA<SmbException>().having(
            (error) => error.message,
            'message',
            contains('仅支持默认 445 端口'),
          ),
        ),
      );
    });

    test('readFileBytes reads file using synthetic SmbFile', () async {
      final client = SmbClient(
        connect: (_) async => _FakeSmbConnect(),
        readFile: (_, file) async {
          expect(file.path, '/public/gallery/cover.jpg');
          expect(file.share, 'public');
          return Uint8List.fromList([4, 5, 6]);
        },
      );

      final bytes = await client.readFileBytes(config, '/public/gallery/cover.jpg');

      expect(bytes, [4, 5, 6]);
    });

    test('readFileBytes serializes reads by host', () async {
      final completionOrder = <String>[];
      final firstCompleter = Completer<Uint8List>();
      final secondCompleter = Completer<Uint8List>();
      var readCount = 0;
      final client = SmbClient(
        connect: (_) async => _FakeSmbConnect(),
        readFile: (_, file) {
          readCount += 1;
          if (file.path.endsWith('first.jpg')) {
            completionOrder.add('first:start');
            return firstCompleter.future;
          }
          completionOrder.add('second:start');
          return secondCompleter.future;
        },
      );

      final first = client.readFileBytes(config, '/public/gallery/first.jpg');
      final second = client.readFileBytes(config, '/public/gallery/second.jpg');

      await Future<void>.delayed(Duration.zero);
      expect(readCount, 1);
      expect(completionOrder, ['first:start']);

      firstCompleter.complete(Uint8List.fromList([1]));
      expect(await first, [1]);

      await Future<void>.delayed(Duration.zero);
      expect(readCount, 2);
      expect(completionOrder, ['first:start', 'second:start']);

      secondCompleter.complete(Uint8List.fromList([2]));
      expect(await second, [2]);
    });

    test('readFileBytes de-duplicates concurrent reads for same path', () async {
      var connectCount = 0;
      var readCount = 0;
      final completer = Completer<Uint8List>();
      final client = SmbClient(
        connect: (_) async {
          connectCount += 1;
          return _FakeSmbConnect();
        },
        readFile: (_, file) async {
          readCount += 1;
          expect(file.path, '/public/gallery/cover.jpg');
          return completer.future;
        },
      );

      final first = client.readFileBytes(config, '/public/gallery/cover.jpg');
      final second = client.readFileBytes(config, '/public/gallery/cover.jpg');

      completer.complete(Uint8List.fromList([7, 8, 9]));

      expect(await first, [7, 8, 9]);
      expect(await second, [7, 8, 9]);
      expect(connectCount, 1);
      expect(readCount, 1);
    });
  });
}

SmbFile _fakeDirectory(String path, String name) {
  return _FakeSmbFile(
    path: path,
    fakeName: name,
    isDirectoryValue: true,
  );
}

SmbFile _fakeFile(String path, String name) {
  return _FakeSmbFile(
    path: path,
    fakeName: name,
    isDirectoryValue: false,
  );
}

class _FakeSmbConnect implements SmbConnect {
  @override
  Future<void> close() async {}

  @override
  Future<SmbFile> file(String path) async {
    if (path == '/public/gallery' || path == '/public/gallery/albums') {
      return _fakeDirectory(path, path.split('/').last);
    }
    return _fakeFile(path, path.split('/').last);
  }

  @override
  Future<List<SmbFile>> listFiles(SmbFile folder, [String wildcard = '*']) async {
    throw UnimplementedError();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeSmbFile extends SmbFile {
  _FakeSmbFile({
    required String path,
    required this.fakeName,
    required this.isDirectoryValue,
  }) : super(
          path,
          path.replaceAll('/', '\\'),
          'public',
          0,
          0,
          0,
          isDirectoryValue ? 16 : 0,
          0,
          true,
        );

  final String fakeName;
  final bool isDirectoryValue;

  @override
  String get name => fakeName;

  @override
  bool isDirectory() => isDirectoryValue;

  @override
  bool isFile() => !isDirectoryValue;
}
