import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:art_frame/features/sources/application/local_sources_repository.dart';
import 'package:art_frame/features/sources/domain/media_item.dart';
import 'package:art_frame/features/sources/domain/media_source.dart';

void main() {
  test('本地图源仓储可保存并恢复目录与文件列表', () async {
    SharedPreferences.setMockInitialValues({});
    const repository = LocalSourcesRepository();

    const source = MediaSource(
      id: 'local-album',
      title: 'Local Album',
      description: 'Images discovered from a local directory.',
      badge: 'Local files',
      kind: MediaSourceKind.localDirectory,
      directoryPath: '/mock/pictures',
      items: [
        MediaItem(
          id: 'frame-1',
          title: 'Frame 1',
          path: '/mock/pictures/frame-1.jpg',
          description: 'First local image',
          kind: MediaItemKind.file,
        ),
        MediaItem(
          id: 'frame-2',
          title: 'Frame 2',
          path: '/mock/pictures/frame-2.jpg',
          description: 'Second local image',
          kind: MediaItemKind.file,
        ),
      ],
    );

    await repository.save(const [source]);
    final restored = await repository.load();

    expect(restored, hasLength(1));
    expect(restored.first.id, source.id);
    expect(restored.first.kind, MediaSourceKind.localDirectory);
    expect(restored.first.directoryPath, '/mock/pictures');
    expect(restored.first.items, hasLength(2));
    expect(restored.first.items.first.kind, MediaItemKind.file);
    expect(restored.first.items.first.path, '/mock/pictures/frame-1.jpg');
  });

  test('本地图源仓储可保存并恢复 localFiles 图源', () async {
    SharedPreferences.setMockInitialValues({});
    const repository = LocalSourcesRepository();

    const source = MediaSource(
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

    await repository.save(const [source]);
    final restored = await repository.load();

    expect(restored, hasLength(1));
    expect(restored.first.kind, MediaSourceKind.localFiles);
    expect(restored.first.directoryPath, isNull);
    expect(restored.first.items.single.title, 'photo-1.jpg');
    expect(restored.first.items.single.kind, MediaItemKind.file);
  });
}
