import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/media_item.dart';
import '../domain/media_source.dart';
import 'bundled_sources_provider.dart';
import 'local_sources_repository.dart';

part 'local_sources_controller.g.dart';

@riverpod
class LocalSourcesController extends _$LocalSourcesController {
  @override
  Future<List<MediaSource>> build() async {
    final repository = ref.watch(localSourcesRepositoryProvider);
    return repository.load();
  }

  Future<MediaSource?> importItems(
    List<MediaItem> items, {
    required String title,
    required String description,
    required String badge,
  }) async {
    if (items.isEmpty) {
      return null;
    }

    final source = MediaSource(
      id: 'local-files-${DateTime.now().microsecondsSinceEpoch}',
      title: title,
      description: description,
      badge: badge,
      kind: MediaSourceKind.localFiles,
      items: items,
    );

    await upsert(source);
    return source;
  }

  Future<void> replaceAll(List<MediaSource> sources) async {
    state = AsyncData(sources);
    final repository = ref.read(localSourcesRepositoryProvider);
    await repository.save(sources);
  }

  Future<void> remove(String sourceId) async {
    final current = state.asData?.value ?? const <MediaSource>[];
    final next = [
      for (final item in current)
        if (item.id != sourceId) item,
    ];
    await replaceAll(next);
  }

  Future<void> upsert(MediaSource source) async {
    final current = state.asData?.value ?? const <MediaSource>[];
    final next = [
      for (final item in current)
        if (item.id != source.id) item,
      source,
    ];
    await replaceAll(next);
  }
}

final allSourcesProvider = Provider<List<MediaSource>>((ref) {
  final bundled = ref.watch(bundledSourcesProvider);
  final local =
      ref.watch(localSourcesControllerProvider).asData?.value ??
      const <MediaSource>[];
  return [...bundled, ...local];
});
