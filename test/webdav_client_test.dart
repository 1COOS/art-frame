import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:art_frame/features/sources/application/webdav_client.dart';
import 'package:art_frame/features/sources/domain/media_item.dart';
import 'package:art_frame/features/sources/domain/network_source_config.dart';

void main() {
  group('WebDavClient', () {
    test('browseDirectory returns child directories and image files', () async {
      final client = WebDavClient(
        propfind: (config, {required depth}) async {
          expect(depth, '1');
          return http.Response(_propfindBody, 207);
        },
      );
      const config = NetworkSourceConfig(
        protocol: NetworkSourceProtocol.webdav,
        host: 'demo.local',
        remotePath: '/gallery',
        secure: true,
      );

      final result = await client.browseDirectory(config);

      expect(result.normalizedPath, '/gallery');
      expect(result.directories, hasLength(1));
      expect(result.directories.first.name, 'albums');
      expect(result.directories.first.path, '/gallery/albums');
      expect(result.items, hasLength(2));
      expect(result.items.map((item) => item.title), ['cover.jpg', 'poster.png']);
      expect(result.items.first.kind, MediaItemKind.remote);
      expect(result.items.first.path, 'https://demo.local/gallery/cover.jpg');
    });

    test('browseDirectory decodes percent-encoded folder names from href', () async {
      final client = WebDavClient(
        propfind: (config, {required depth}) async => http.Response(
          _propfindBodyWithPercentEncodedHref,
          207,
        ),
      );
      const config = NetworkSourceConfig(
        protocol: NetworkSourceProtocol.webdav,
        host: 'demo.local',
        remotePath: '/photo',
      );

      final result = await client.browseDirectory(config);

      expect(result.directories.single.name, '奶奶');
      expect(result.directories.single.path, '/photo/奶奶');
    });

    test('browseDirectory surfaces invalid XML as diagnostic WebDavException', () async {
      final client = WebDavClient(
        propfind: (config, {required depth}) async => http.Response('not-xml', 207),
      );
      const config = NetworkSourceConfig(
        protocol: NetworkSourceProtocol.webdav,
        host: 'demo.local',
        remotePath: '/gallery',
      );

      expect(
        () => client.browseDirectory(config),
        throwsA(
          isA<WebDavException>()
              .having(
                (error) => error.message,
                'message prefix',
                startsWith('WebDAV 目录响应无法解析，请确认地址指向可浏览的 WebDAV 目录'),
              )
              .having(
                (error) => error.message,
                'stage',
                contains('阶段：目录浏览响应解析'),
              )
              .having(
                (error) => error.message,
                'depth',
                contains('Depth：1'),
              )
              .having(
                (error) => error.message,
                'snippet',
                contains('响应摘要：not-xml'),
              ),
        ),
      );
    });

    test('validate surfaces authorization failures with diagnostics', () async {
      final client = WebDavClient(
        propfind: (config, {required depth}) async => http.Response('', 401),
      );
      const config = NetworkSourceConfig(
        protocol: NetworkSourceProtocol.webdav,
        host: 'demo.local',
        remotePath: '/gallery',
      );

      expect(
        () => client.validate(config),
        throwsA(
          isA<WebDavException>()
              .having(
                (error) => error.message,
                'message prefix',
                startsWith('WebDAV 认证失败，请检查用户名或密码'),
              )
              .having(
                (error) => error.message,
                'stage',
                contains('阶段：连接验证'),
              )
              .having(
                (error) => error.message,
                'status',
                contains('状态码：401'),
              ),
        ),
      );
    });
  });
}

const _propfindBody = '''<?xml version="1.0" encoding="utf-8" ?>
<D:multistatus xmlns:D="DAV:">
  <D:response>
    <D:href>/gallery/</D:href>
    <D:propstat>
      <D:prop>
        <D:resourcetype><D:collection /></D:resourcetype>
      </D:prop>
    </D:propstat>
  </D:response>
  <D:response>
    <D:href>/gallery/albums/</D:href>
    <D:propstat>
      <D:prop>
        <D:displayname>albums</D:displayname>
        <D:resourcetype><D:collection /></D:resourcetype>
      </D:prop>
    </D:propstat>
  </D:response>
  <D:response>
    <D:href>/gallery/cover.jpg</D:href>
    <D:propstat>
      <D:prop><D:resourcetype /></D:prop>
    </D:propstat>
  </D:response>
  <D:response>
    <D:href>/gallery/readme.txt</D:href>
    <D:propstat>
      <D:prop><D:resourcetype /></D:prop>
    </D:propstat>
  </D:response>
  <D:response>
    <D:href>https://demo.local/gallery/poster.png</D:href>
    <D:propstat>
      <D:prop><D:resourcetype /></D:prop>
    </D:propstat>
  </D:response>
</D:multistatus>''';

const _propfindBodyWithPercentEncodedHref = '''<?xml version="1.0" encoding="utf-8" ?>
<D:multistatus xmlns:D="DAV:">
  <D:response>
    <D:href>/photo/</D:href>
    <D:propstat>
      <D:prop>
        <D:resourcetype><D:collection /></D:resourcetype>
      </D:prop>
    </D:propstat>
  </D:response>
  <D:response>
    <D:href>/photo/%E5%A5%B6%E5%A5%B6/</D:href>
    <D:propstat>
      <D:prop>
        <D:resourcetype><D:collection /></D:resourcetype>
      </D:prop>
    </D:propstat>
  </D:response>
</D:multistatus>''';

