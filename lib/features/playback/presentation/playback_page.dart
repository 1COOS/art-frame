import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/router/app_destination.dart';
import '../../../core/widgets/local_image.dart';
import '../../../core/widgets/media_asset_image.dart';
import '../../settings/domain/playback_settings.dart';
import '../../settings/application/playback_settings_controller.dart';
import '../../sources/application/selected_source_controller.dart';
import '../../sources/application/network/smb_image_provider.dart';
import '../../sources/domain/media_item.dart';
import '../../sources/domain/media_source.dart';
import '../../sources/domain/network_source_config.dart';

class PlaybackPage extends ConsumerStatefulWidget {
  const PlaybackPage({super.key});

  @override
  ConsumerState<PlaybackPage> createState() => _PlaybackPageState();
}

class _PlaybackPageState extends ConsumerState<PlaybackPage> {
  int _currentIndex = 0;
  Timer? _timer;
  String? _timerKey;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listenManual(selectedSourceProvider, (_, _) {
        _reconfigureTimer();
      });
      ref.listenManual(playbackSettingsControllerProvider, (_, _) {
        _reconfigureTimer();
      });
      _reconfigureTimer();
    });
  }

  void _reconfigureTimer() {
    final source = ref.read(selectedSourceProvider);
    final settings =
        ref.read(playbackSettingsControllerProvider).asData?.value ??
        const PlaybackSettings.defaults();
    _configureTimer(source: source, settings: settings);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final source = ref.watch(selectedSourceProvider);

    if (source == null || source.items.isEmpty) {
      _timer?.cancel();
      _timer = null;
      _timerKey = null;

      return Scaffold(
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.playbackEmptyTitle,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 12),
                      Text(l10n.playbackEmptyBody),
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: () => context.go(AppDestination.sources.path),
                        child: Text(l10n.goToSources),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    final normalizedIndex = _normalizeIndex(source.items.length);
    final currentItem = source.items[normalizedIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            _PlaybackFrame(
              item: currentItem,
              headers:
                  source.networkConfig?.authorizationHeaders ??
                  const <String, String>{},
              networkConfig: source.networkConfig,
            ),
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  FilledButton.tonal(
                    onPressed: () => context.go(AppDestination.sources.path),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                    child: const Icon(Icons.arrow_back),
                  ),
                  const Spacer(),
                  _OverlayBadge(value: l10n.playbackCounter(normalizedIndex + 1, source.items.length)),
                ],
              ),
            ),
            Positioned(
              left: 24,
              right: 24,
              bottom: 24,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      source.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.tonal(
                    onPressed: _showPrevious,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(48, 48),
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Icon(Icons.chevron_left),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.tonal(
                    onPressed: _showNext,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(48, 48),
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _normalizeIndex(int length) {
    if (_currentIndex >= length) {
      _currentIndex = 0;
    }

    return _currentIndex;
  }

  void _configureTimer({
    required MediaSource? source,
    required PlaybackSettings settings,
  }) {
    final nextKey =
        '${source?.id ?? 'none'}-${settings.autoplay}-${settings.intervalSeconds}';
    if (_timerKey == nextKey) {
      return;
    }

    _timerKey = nextKey;
    _timer?.cancel();
    _timer = null;

    if (!settings.autoplay || source == null || source.items.length < 2) {
      return;
    }

    _timer = Timer.periodic(Duration(seconds: settings.intervalSeconds), (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _currentIndex = (_currentIndex + 1) % source.items.length;
      });
    });
  }

  void _showNext() {
    final source = ref.read(selectedSourceProvider);
    if (source == null || source.items.isEmpty) {
      return;
    }

    setState(() {
      _currentIndex = (_currentIndex + 1) % source.items.length;
    });
  }

  void _showPrevious() {
    final source = ref.read(selectedSourceProvider);
    if (source == null || source.items.isEmpty) {
      return;
    }

    setState(() {
      _currentIndex =
          (_currentIndex - 1 + source.items.length) % source.items.length;
    });
  }
}

class _PlaybackFrame extends ConsumerWidget {
  const _PlaybackFrame({
    required this.item,
    required this.headers,
    required this.networkConfig,
  });

  final MediaItem item;
  final Map<String, String> headers;
  final NetworkSourceConfig? networkConfig;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (item.kind == MediaItemKind.file) {
      return buildLocalImage(item.path);
    }

    if (item.kind == MediaItemKind.mediaAsset) {
      return buildMediaAssetImage(item.path, isOriginal: true);
    }

    if (item.kind == MediaItemKind.remote) {
      final config = networkConfig;
      if (config?.protocol == NetworkSourceProtocol.smb) {
        final smbBytes = ref.watch(
          smbImageBytesProvider(
            SmbImageRequest(config: config!, remotePath: item.path),
          ),
        );
        return smbBytes.when(
          data: (bytes) => Image.memory(
            bytes,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const _RemoteErrorPlaceholder();
            },
          ),
          error: (error, stackTrace) => const _RemoteErrorPlaceholder(),
          loading: () => ColoredBox(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: const Center(child: CircularProgressIndicator()),
          ),
        );
      }

      final memoryBytes = item.tryDecodeBase64Path();
      if (memoryBytes != null) {
        return Image.memory(
          memoryBytes,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const _RemoteErrorPlaceholder();
          },
        );
      }

      return Image.network(
        item.path,
        headers: headers.isEmpty ? null : headers,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const _RemoteErrorPlaceholder();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return ColoredBox(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: const Center(child: CircularProgressIndicator()),
          );
        },
      );
    }

    return Image.asset(item.assetPath, fit: BoxFit.cover);
  }

}

class _RemoteErrorPlaceholder extends StatelessWidget {
  const _RemoteErrorPlaceholder();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Center(
        child: Icon(Icons.cloud_off_outlined, size: 64),
      ),
    );
  }
}

class _OverlayBadge extends StatelessWidget {
  const _OverlayBadge({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.44),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Text(
          value,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
