import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:art_frame/features/sources/application/network_source_secrets_store.dart';
import 'package:art_frame/features/sources/domain/media_item.dart';
import 'package:art_frame/features/sources/domain/media_source.dart';
import 'package:art_frame/features/sources/domain/network_source_config.dart';

void main() {
  test('network secrets store 可保存并恢复密码到网络图源', () async {
    SharedPreferences.setMockInitialValues({});
    const store = NetworkSourceSecretsStore();

    const source = MediaSource(
      id: 'network-webdav:https:demo.local::/gallery:demo',
      title: 'WebDAV Demo',
      description: 'demo.local/gallery',
      badge: 'Network source',
      kind: MediaSourceKind.network,
      networkConfig: NetworkSourceConfig(
        protocol: NetworkSourceProtocol.webdav,
        host: 'demo.local',
        remotePath: '/gallery',
        secure: true,
        username: 'demo',
        password: 'secret',
        displayName: 'WebDAV Demo',
      ),
      items: [
        MediaItem(
          id: 'network-demo-item-1',
          title: 'Remote placeholder',
          path: 'https://demo.local/gallery/frame-1.jpg',
          description: '/gallery/frame-1.jpg',
          kind: MediaItemKind.remote,
        ),
      ],
    );

    await store.save(source);
    final restored = await store.attachSecrets(const [
      MediaSource(
        id: 'network-webdav:https:demo.local::/gallery:demo',
        title: 'WebDAV Demo',
        description: 'demo.local/gallery',
        badge: 'Network source',
        kind: MediaSourceKind.network,
        networkConfig: NetworkSourceConfig(
          protocol: NetworkSourceProtocol.webdav,
          host: 'demo.local',
          remotePath: '/gallery',
          secure: true,
          username: 'demo',
          displayName: 'WebDAV Demo',
        ),
        items: [
          MediaItem(
            id: 'network-demo-item-1',
            title: 'Remote placeholder',
            path: 'https://demo.local/gallery/frame-1.jpg',
            description: '/gallery/frame-1.jpg',
            kind: MediaItemKind.remote,
          ),
        ],
      ),
    ]);

    expect(restored.single.networkConfig?.password, 'secret');
  });

  test('network secrets store 删除图源时会清理密码', () async {
    SharedPreferences.setMockInitialValues({});
    const store = NetworkSourceSecretsStore();

    const source = MediaSource(
      id: 'network-webdav:https:demo.local::/gallery:demo',
      title: 'WebDAV Demo',
      description: 'demo.local/gallery',
      badge: 'Network source',
      kind: MediaSourceKind.network,
      networkConfig: NetworkSourceConfig(
        protocol: NetworkSourceProtocol.webdav,
        host: 'demo.local',
        remotePath: '/gallery',
        secure: true,
        username: 'demo',
        password: 'secret',
        displayName: 'WebDAV Demo',
      ),
      items: [
        MediaItem(
          id: 'network-demo-item-1',
          title: 'Remote placeholder',
          path: 'https://demo.local/gallery/frame-1.jpg',
          description: '/gallery/frame-1.jpg',
          kind: MediaItemKind.remote,
        ),
      ],
    );

    await store.save(source);
    await store.remove(source);

    final restored = await store.attachSecrets(const [
      MediaSource(
        id: 'network-webdav:https:demo.local::/gallery:demo',
        title: 'WebDAV Demo',
        description: 'demo.local/gallery',
        badge: 'Network source',
        kind: MediaSourceKind.network,
        networkConfig: NetworkSourceConfig(
          protocol: NetworkSourceProtocol.webdav,
          host: 'demo.local',
          remotePath: '/gallery',
          secure: true,
          username: 'demo',
          displayName: 'WebDAV Demo',
        ),
        items: [
          MediaItem(
            id: 'network-demo-item-1',
            title: 'Remote placeholder',
            path: 'https://demo.local/gallery/frame-1.jpg',
            description: '/gallery/frame-1.jpg',
            kind: MediaItemKind.remote,
          ),
        ],
      ),
    ]);

    expect(restored.single.networkConfig?.password, isNull);
  });

  test('network secrets store 更新 stableId 时会迁移密码', () async {
    SharedPreferences.setMockInitialValues({});
    const store = NetworkSourceSecretsStore();

    const updated = MediaSource(
      id: 'network-webdav:https:demo.local::/gallery-2:demo',
      title: 'WebDAV Demo',
      description: 'demo.local/gallery-2',
      badge: 'Network source',
      kind: MediaSourceKind.network,
      networkConfig: NetworkSourceConfig(
        protocol: NetworkSourceProtocol.webdav,
        host: 'demo.local',
        remotePath: '/gallery-2',
        secure: true,
        username: 'demo',
        password: 'secret-2',
        displayName: 'WebDAV Demo',
      ),
      items: [
        MediaItem(
          id: 'network-demo-item-2',
          title: 'Remote placeholder 2',
          path: 'https://demo.local/gallery-2/frame-1.jpg',
          description: '/gallery-2/frame-1.jpg',
          kind: MediaItemKind.remote,
        ),
      ],
    );

    await store.save(
      updated,
      previousStableId: 'webdav:https:demo.local::/gallery:demo',
    );

    final restored = await store.attachSecrets(const [
      MediaSource(
        id: 'network-webdav:https:demo.local::/gallery:demo',
        title: 'Old WebDAV Demo',
        description: 'demo.local/gallery',
        badge: 'Network source',
        kind: MediaSourceKind.network,
        networkConfig: NetworkSourceConfig(
          protocol: NetworkSourceProtocol.webdav,
          host: 'demo.local',
          remotePath: '/gallery',
          secure: true,
          username: 'demo',
          displayName: 'Old WebDAV Demo',
        ),
        items: [
          MediaItem(
            id: 'old-item',
            title: 'Old item',
            path: 'https://demo.local/gallery/frame-1.jpg',
            description: '/gallery/frame-1.jpg',
            kind: MediaItemKind.remote,
          ),
        ],
      ),
      MediaSource(
        id: 'network-webdav:https:demo.local::/gallery-2:demo',
        title: 'WebDAV Demo',
        description: 'demo.local/gallery-2',
        badge: 'Network source',
        kind: MediaSourceKind.network,
        networkConfig: NetworkSourceConfig(
          protocol: NetworkSourceProtocol.webdav,
          host: 'demo.local',
          remotePath: '/gallery-2',
          secure: true,
          username: 'demo',
          displayName: 'WebDAV Demo',
        ),
        items: [
          MediaItem(
            id: 'network-demo-item-2',
            title: 'Remote placeholder 2',
            path: 'https://demo.local/gallery-2/frame-1.jpg',
            description: '/gallery-2/frame-1.jpg',
            kind: MediaItemKind.remote,
          ),
        ],
      ),
    ]);

    expect(restored.first.networkConfig?.password, isNull);
    expect(restored.last.networkConfig?.password, 'secret-2');
  });
}
