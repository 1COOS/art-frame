import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/network_source_config.dart';
import 'smb_client.dart';

const _maxCachedSmbImages = 24;

@immutable
class SmbImageRequest {
  const SmbImageRequest({required this.config, required this.remotePath});

  final NetworkSourceConfig config;
  final String remotePath;

  String get cacheKey => '${config.stableId}:$remotePath';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is SmbImageRequest &&
            config.stableId == other.config.stableId &&
            remotePath == other.remotePath;
  }

  @override
  int get hashCode => Object.hash(config.stableId, remotePath);
}

class SmbImageMemoryCache {
  final _entries = <String, Uint8List>{};

  Uint8List? get(SmbImageRequest request) {
    final bytes = _entries.remove(request.cacheKey);
    if (bytes == null) {
      return null;
    }
    _entries[request.cacheKey] = bytes;
    return bytes;
  }

  void put(SmbImageRequest request, Uint8List bytes) {
    _entries.remove(request.cacheKey);
    _entries[request.cacheKey] = bytes;
    while (_entries.length > _maxCachedSmbImages) {
      _entries.remove(_entries.keys.first);
    }
  }
}

final smbImageMemoryCacheProvider = Provider<SmbImageMemoryCache>((ref) {
  return SmbImageMemoryCache();
});

final smbImageBytesProvider = FutureProvider.family
    .autoDispose<Uint8List, SmbImageRequest>((ref, request) async {
      final cache = ref.read(smbImageMemoryCacheProvider);
      final cached = cache.get(request);
      if (cached != null) {
        return cached;
      }

      final bytes = await ref
          .read(smbClientProvider)
          .readFileBytes(request.config, request.remotePath);
      cache.put(request, bytes);
      return bytes;
    }, retry: (retryCount, error) => null);
