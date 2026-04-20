import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:art_frame/features/sources/application/local_sources_controller.dart';
import 'package:art_frame/features/sources/application/selected_source_controller.dart';
import 'package:art_frame/features/sources/domain/media_item.dart';
import 'package:art_frame/features/sources/domain/media_source.dart';
import 'package:art_frame/features/sources/domain/network_source_config.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('删除当前选中的本地图源后清理选中状态', () async {
    SharedPreferences.setMockInitialValues({});

    final container = ProviderContainer();
    addTearDown(container.dispose);
    final localSourcesSub = container.listen(
      localSourcesControllerProvider,
      (previous, next) {},
      fireImmediately: true,
    );
    final selectedSourceControllerSub = container.listen(
      selectedSourceControllerProvider,
      (previous, next) {},
      fireImmediately: true,
    );
    addTearDown(localSourcesSub.close);
    addTearDown(selectedSourceControllerSub.close);

    const localSource = MediaSource(
      id: 'picked-files',
      title: 'Picked files',
      description: 'Images imported directly from the picker.',
      badge: 'Local files',
      kind: MediaSourceKind.localFiles,
      items: [
        MediaItem(
          id: '/mock/photo-1.jpg',
          title: 'photo-1.jpg',
          path: '/mock/photo-1.jpg',
          description: '/mock/photo-1.jpg',
          kind: MediaItemKind.file,
        ),
      ],
    );

    await container.read(localSourcesControllerProvider.future);
    await container.read(selectedSourceControllerProvider.future);

    await container
        .read(localSourcesControllerProvider.notifier)
        .upsert(localSource);
    await container
        .read(selectedSourceControllerProvider.notifier)
        .select(localSource.id);

    expect(container.read(selectedSourceProvider)?.id, localSource.id);

    await container
        .read(localSourcesControllerProvider.notifier)
        .remove(localSource.id);
    await container.read(selectedSourceControllerProvider.notifier).clear();

    expect(container.read(selectedSourceProvider), isNull);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('selected_source_id'), isNull);
  });

  test('删除当前选中的目录图源后清理选中状态', () async {
    SharedPreferences.setMockInitialValues({});

    final container = ProviderContainer();
    addTearDown(container.dispose);
    final localSourcesSub = container.listen(
      localSourcesControllerProvider,
      (previous, next) {},
      fireImmediately: true,
    );
    final selectedSourceControllerSub = container.listen(
      selectedSourceControllerProvider,
      (previous, next) {},
      fireImmediately: true,
    );
    addTearDown(localSourcesSub.close);
    addTearDown(selectedSourceControllerSub.close);

    const localDirectorySource = MediaSource(
      id: 'local-directory-/mock/pictures',
      title: 'pictures',
      description: '/mock/pictures',
      badge: 'Local directory',
      kind: MediaSourceKind.localDirectory,
      directoryPath: '/mock/pictures',
      items: [
        MediaItem(
          id: '/mock/pictures/frame-1.jpg',
          title: 'frame-1.jpg',
          path: '/mock/pictures/frame-1.jpg',
          description: '/mock/pictures/frame-1.jpg',
          kind: MediaItemKind.file,
        ),
      ],
    );

    await container.read(localSourcesControllerProvider.future);
    await container.read(selectedSourceControllerProvider.future);

    await container
        .read(localSourcesControllerProvider.notifier)
        .upsert(localDirectorySource);
    await container
        .read(selectedSourceControllerProvider.notifier)
        .select(localDirectorySource.id);

    expect(container.read(selectedSourceProvider)?.id, localDirectorySource.id);

    await container
        .read(localSourcesControllerProvider.notifier)
        .remove(localDirectorySource.id);
    await container.read(selectedSourceControllerProvider.notifier).clear();

    expect(container.read(selectedSourceProvider), isNull);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('selected_source_id'), isNull);
  });

  test('删除当前选中的媒体库图源后清理选中状态', () async {
    SharedPreferences.setMockInitialValues({});

    final container = ProviderContainer();
    addTearDown(container.dispose);
    final localSourcesSub = container.listen(
      localSourcesControllerProvider,
      (previous, next) {},
      fireImmediately: true,
    );
    final selectedSourceControllerSub = container.listen(
      selectedSourceControllerProvider,
      (previous, next) {},
      fireImmediately: true,
    );
    addTearDown(localSourcesSub.close);
    addTearDown(selectedSourceControllerSub.close);

    const mediaLibrarySource = MediaSource(
      id: 'media-library-1',
      title: 'Media library',
      description: 'Images selected from the system photo library.',
      badge: 'Media library',
      kind: MediaSourceKind.mediaLibrary,
      items: [
        MediaItem(
          id: 'asset-001',
          title: 'IMG_0001.JPG',
          path: 'asset-001',
          description: 'IMG_0001.JPG',
          kind: MediaItemKind.mediaAsset,
        ),
      ],
    );

    await container.read(localSourcesControllerProvider.future);
    await container.read(selectedSourceControllerProvider.future);

    await container
        .read(localSourcesControllerProvider.notifier)
        .upsert(mediaLibrarySource);
    await container
        .read(selectedSourceControllerProvider.notifier)
        .select(mediaLibrarySource.id);

    expect(container.read(selectedSourceProvider)?.id, mediaLibrarySource.id);

    await container
        .read(localSourcesControllerProvider.notifier)
        .remove(mediaLibrarySource.id);
    await container.read(selectedSourceControllerProvider.notifier).clear();

    expect(container.read(selectedSourceProvider), isNull);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('selected_source_id'), isNull);
  });

  test('删除当前选中的网络图源后清理选中状态', () async {
    SharedPreferences.setMockInitialValues({});

    final container = ProviderContainer();
    addTearDown(container.dispose);
    final localSourcesSub = container.listen(
      localSourcesControllerProvider,
      (previous, next) {},
      fireImmediately: true,
    );
    final selectedSourceControllerSub = container.listen(
      selectedSourceControllerProvider,
      (previous, next) {},
      fireImmediately: true,
    );
    addTearDown(localSourcesSub.close);
    addTearDown(selectedSourceControllerSub.close);

    const networkSource = MediaSource(
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
    );

    await container.read(localSourcesControllerProvider.future);
    await container.read(selectedSourceControllerProvider.future);

    await container
        .read(localSourcesControllerProvider.notifier)
        .upsert(networkSource);
    await container
        .read(selectedSourceControllerProvider.notifier)
        .select(networkSource.id);

    expect(container.read(selectedSourceProvider)?.id, networkSource.id);

    await container
        .read(localSourcesControllerProvider.notifier)
        .remove(networkSource.id);
    await container.read(selectedSourceControllerProvider.notifier).clear();

    expect(container.read(selectedSourceProvider), isNull);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('selected_source_id'), isNull);
  });
}
