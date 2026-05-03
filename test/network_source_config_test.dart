import 'package:flutter_test/flutter_test.dart';

import 'package:art_frame/features/sources/domain/network_source_config.dart';

void main() {
  test('endpointLabel 保留解码后的中文路径', () {
    const config = NetworkSourceConfig(
      protocol: NetworkSourceProtocol.webdav,
      host: '192.168.2.100',
      remotePath: '/photo/test',
      secure: false,
      port: 5005,
    );

    expect(config.endpointLabel, 'http://192.168.2.100:5005/photo/test');
  });

  test('SMB endpointLabel and stableId include protocol domain context', () {
    const config = NetworkSourceConfig(
      protocol: NetworkSourceProtocol.smb,
      host: 'demo.local',
      remotePath: '/public/gallery',
      port: 445,
      username: 'demo',
      domain: 'WORKGROUP',
    );

    expect(config.endpointLabel, 'smb://demo.local:445/public/gallery');
    expect(
      config.stableId,
      'smb:smb:demo.local:445:/public/gallery:demo:WORKGROUP',
    );
  });
}
