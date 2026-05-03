import 'package:flutter_test/flutter_test.dart';

import 'package:art_frame/features/sources/application/network/network_endpoint_parser.dart';

void main() {
  group('parse WebDAV endpoint', () {
    test('supports full http URL in host field', () {
      final parsed = parseWebDavEndpoint(
        hostInput: 'http://192.168.2.100:5005/gallery',
        portInput: '',
        pathInput: '',
        secure: false,
      );

      expect(parsed.host, '192.168.2.100');
      expect(parsed.port, 5005);
      expect(parsed.remotePath, '/gallery');
      expect(parsed.secure, isFalse);
    });

    test('prefers explicit path and port over URL defaults', () {
      final parsed = parseWebDavEndpoint(
        hostInput: 'https://demo.local/base',
        portInput: '8443',
        pathInput: '/gallery',
        secure: false,
      );

      expect(parsed.host, 'demo.local');
      expect(parsed.port, 8443);
      expect(parsed.remotePath, '/gallery');
      expect(parsed.secure, isTrue);
    });

    test('supports plain host and port syntax', () {
      final parsed = parseWebDavEndpoint(
        hostInput: 'demo.local:5005',
        portInput: '',
        pathInput: '/gallery',
        secure: false,
      );

      expect(parsed.host, 'demo.local');
      expect(parsed.port, 5005);
      expect(parsed.remotePath, '/gallery');
      expect(parsed.secure, isFalse);
    });
  });

  group('parse SMB endpoint', () {
    test('supports smb URL in host field', () {
      final parsed = parseSmbEndpoint(
        hostInput: 'smb://demo.local/public/gallery',
        portInput: '',
        pathInput: '',
      );

      expect(parsed.host, 'demo.local');
      expect(parsed.port, isNull);
      expect(parsed.remotePath, '/public/gallery');
    });

    test('prefers explicit path and port for smb endpoint', () {
      final parsed = parseSmbEndpoint(
        hostInput: 'demo.local:445',
        portInput: '445',
        pathInput: '/public/gallery',
      );

      expect(parsed.host, 'demo.local');
      expect(parsed.port, 445);
      expect(parsed.remotePath, '/public/gallery');
    });
  });
}
