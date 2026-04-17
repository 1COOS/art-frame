import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:art_frame/features/sources/application/local_sources_controller.dart';
import 'package:art_frame/features/sources/application/selected_source_controller.dart';
import 'package:art_frame/features/sources/domain/media_item.dart';
import 'package:art_frame/features/sources/domain/media_source.dart';

void main() {
  test('删除当前选中的本地图源后清理选中状态', () async {
    SharedPreferences.setMockInitialValues({});

    final container = ProviderContainer();
    addTearDown(container.dispose);

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

    await container.read(localSourcesControllerProvider.notifier).upsert(localSource);
    await container
        .read(selectedSourceControllerProvider.notifier)
        .select(localSource.id);

    expect(container.read(selectedSourceProvider)?.id, localSource.id);

    await container.read(localSourcesControllerProvider.notifier).remove(localSource.id);
    await container.read(selectedSourceControllerProvider.notifier).clear();

    expect(container.read(selectedSourceProvider), isNull);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('selected_source_id'), isNull);
  });
}
