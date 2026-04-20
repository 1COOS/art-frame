import 'package:flutter_test/flutter_test.dart';

import 'package:art_frame/features/sources/application/network_source_io.dart';

void main() {
  group('parse WebDAV endpoint', () {
    test('supports full http URL in host field', () {
      final parsed = parseWebDavEndpointForTest(
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
      final parsed = parseWebDavEndpointForTest(
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
      final parsed = parseWebDavEndpointForTest(
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
}
