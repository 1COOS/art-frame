import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/media_item.dart';
import '../domain/media_source.dart';
import 'bundled_sources_provider.dart';
import 'local/local_directory_scanner.dart';
import 'local/local_security_scope_access.dart';
import 'local_sources_repository.dart';
import '../domain/network_source_result.dart';
import 'network_source_secrets_store.dart';

part 'local_sources_controller.g.dart';

@riverpod
class LocalSourcesController extends _$LocalSourcesController {
  @override
  Future<List<MediaSource>> build() async {
    final repository = ref.watch(localSourcesRepositoryProvider);
    final restored = await repository.load();
    final sources = await ref
        .read(networkSourceSecretsStoreProvider)
        .attachSecrets(restored);
    await ref.read(localSecurityScopeAccessProvider).restoreAccess(sources);
    return sources;
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

    await ref
        .read(localSecurityScopeAccessProvider)
        .persistSourceAccess(source);
    await upsert(source);
    return source;
  }

  Future<MediaSource?> importDirectory(
    String directoryPath, {
    required String badge,
  }) async {
    final normalizedPath = _trimTrailingSeparators(directoryPath.trim());
    if (normalizedPath.isEmpty) {
      return null;
    }

    final items = await ref
        .read(localDirectoryScannerProvider)
        .scanImages(normalizedPath);
    if (items.isEmpty) {
      return null;
    }

    final directoryName = _basename(normalizedPath);
    final source = MediaSource(
      id: 'local-directory-$normalizedPath',
      title: directoryName.isNotEmpty ? directoryName : normalizedPath,
      description: normalizedPath,
      badge: badge,
      kind: MediaSourceKind.localDirectory,
      directoryPath: normalizedPath,
      items: items,
    );

    await ref
        .read(localSecurityScopeAccessProvider)
        .persistSourceAccess(source);
    await upsert(source);
    return source;
  }

  Future<MediaSource?> importMediaLibraryItems(
    List<MediaItem> items, {
    required String title,
    required String description,
    required String badge,
  }) async {
    if (items.isEmpty) {
      return null;
    }

    final source = MediaSource(
      id: 'media-library-${DateTime.now().microsecondsSinceEpoch}',
      title: title,
      description: description,
      badge: badge,
      kind: MediaSourceKind.mediaLibrary,
      items: items,
    );

    await upsert(source);
    return source;
  }

  Future<MediaSource?> importNetworkSource(NetworkSourceDraft draft) async {
    if (draft.items.isEmpty) {
      return null;
    }

    final source = MediaSource(
      id: 'network-${draft.config.stableId}',
      title: draft.title,
      description: draft.description,
      badge: draft.badge,
      kind: MediaSourceKind.network,
      networkConfig: draft.config,
      items: draft.items,
    );

    await upsert(source);
    return source;
  }

  Future<MediaSource?> updateNetworkSource(
    String sourceId,
    NetworkSourceDraft draft, {
    String? previousStableId,
  }) async {
    if (draft.items.isEmpty) {
      return null;
    }

    final source = MediaSource(
      id: sourceId,
      title: draft.title,
      description: draft.description,
      badge: draft.badge,
      kind: MediaSourceKind.network,
      networkConfig: draft.config,
      items: draft.items,
    );

    await upsert(source, previousStableId: previousStableId);
    return source;
  }

  Future<void> replaceAll(List<MediaSource> sources) async {
    state = AsyncData(sources);
    final repository = ref.read(localSourcesRepositoryProvider);
    await repository.save(sources);
    await ref.read(localSecurityScopeAccessProvider).syncSources(sources);
  }

  Future<void> remove(String sourceId) async {
    final current = state.asData?.value ?? const <MediaSource>[];
    final removed = current.where((item) => item.id == sourceId).toList();
    final next = [
      for (final item in current)
        if (item.id != sourceId) item,
    ];
    for (final source in removed) {
      await ref.read(networkSourceSecretsStoreProvider).remove(source);
    }
    await replaceAll(next);
  }

  Future<void> upsert(MediaSource source, {String? previousStableId}) async {
    final current = state.asData?.value ?? const <MediaSource>[];
    final next = [
      for (final item in current)
        if (item.id != source.id) item,
      source,
    ];
    await ref.read(networkSourceSecretsStoreProvider).save(
      source,
      previousStableId: previousStableId,
    );
    await replaceAll(next);
  }

  String _basename(String path) {
    final segments = path.split(RegExp(r'[\\/]'));
    return segments.isEmpty ? path : segments.last;
  }

  String _trimTrailingSeparators(String path) {
    var result = path;
    while (result.length > 1 &&
        (result.endsWith('/') || result.endsWith('\\'))) {
      result = result.substring(0, result.length - 1);
    }
    return result;
  }
}

final allSourcesProvider = Provider<List<MediaSource>>((ref) {
  final bundled = ref.watch(bundledSourcesProvider);
  final local =
      ref.watch(localSourcesControllerProvider).asData?.value ??
      const <MediaSource>[];
  return [...bundled, ...local];
});
