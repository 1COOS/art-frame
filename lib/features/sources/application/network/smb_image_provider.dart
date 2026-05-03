import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/network_source_config.dart';
import 'smb_client.dart';

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

final smbImageBytesProvider = FutureProvider.family
    .autoDispose<Uint8List, SmbImageRequest>((ref, request) async {
      return ref
          .read(smbClientProvider)
          .readFileBytes(request.config, request.remotePath);
    }, retry: (retryCount, error) => null);
