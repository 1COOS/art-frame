import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/router/app_destination.dart';
import '../../../app/theme/app_motion.dart';
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
  bool _controlsVisible = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _scheduleHideControls(firstEntry: true);
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

  void _scheduleHideControls({bool firstEntry = false}) {
    _hideTimer?.cancel();
    final delay = firstEntry ? 5 : 3;
    _hideTimer = Timer(Duration(seconds: delay), () {
      if (mounted) setState(() => _controlsVisible = false);
    });
  }

  void _showControls() {
    if (!_controlsVisible) {
      setState(() => _controlsVisible = true);
    }
    _scheduleHideControls();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _hideTimer?.cancel();
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
                        onPressed: () =>
                            context.go(AppDestination.library.path),
                        child: Text(l10n.goToLibrary),
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
    final nextItem = _nextRemoteItem(source.items, normalizedIndex);

    return Scaffold(
      backgroundColor: Colors.black,
      body: MouseRegion(
        onHover: (_) => _showControls(),
        child: GestureDetector(
          onTap: _showControls,
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity == null) return;
            if (details.primaryVelocity! < -200) {
              _showNext();
              _resetAutoplayTimer();
            } else if (details.primaryVelocity! > 200) {
              _showPrevious();
              _resetAutoplayTimer();
            }
          },
          child: SafeArea(
            child: Stack(
              fit: StackFit.expand,
              children: [
                _PlaybackFrame(
                  item: currentItem,
                  nextItem: nextItem,
                  headers:
                      source.networkConfig?.authorizationHeaders ??
                      const <String, String>{},
                  networkConfig: source.networkConfig,
                ),
                // Auto-hiding controls
                AnimatedOpacity(
                  opacity: _controlsVisible ? 1.0 : 0.0,
                  duration: AppMotion.standard,
                  curve: AppMotion.curve,
                  child: IgnorePointer(
                    ignoring: !_controlsVisible,
                    child: Stack(
                      children: [
                        Positioned(
                          top: 16,
                          left: 16,
                          right: 16,
                          child: Row(
                            children: [
                              _GlassButton(
                                onTap: () =>
                                    context.go(AppDestination.library.path),
                                child: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const Spacer(),
                              _GlassBadge(
                                value: l10n.playbackCounter(
                                  normalizedIndex + 1,
                                  source.items.length,
                                ),
                              ),
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
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(color: Colors.white70),
                                ),
                              ),
                              const SizedBox(width: 12),
                              _GlassButton(
                                onTap: _showPrevious,
                                child: const Icon(
                                  Icons.chevron_left,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _GlassButton(
                                onTap: _showNext,
                                child: const Icon(
                                  Icons.chevron_right,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
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

  MediaItem? _nextRemoteItem(List<MediaItem> items, int currentIndex) {
    if (items.length < 2) {
      return null;
    }

    final nextItem = items[(currentIndex + 1) % items.length];
    return nextItem.kind == MediaItemKind.remote ? nextItem : null;
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

  void _resetAutoplayTimer() {
    _reconfigureTimer();
  }
}

class _PlaybackFrame extends ConsumerStatefulWidget {
  const _PlaybackFrame({
    required this.item,
    required this.nextItem,
    required this.headers,
    required this.networkConfig,
  });

  final MediaItem item;
  final MediaItem? nextItem;
  final Map<String, String> headers;
  final NetworkSourceConfig? networkConfig;

  @override
  ConsumerState<_PlaybackFrame> createState() => _PlaybackFrameState();
}

class _PlaybackFrameState extends ConsumerState<_PlaybackFrame> {
  _ResolvedPlaybackImage? _displayedImage;
  final Map<String, _ResolvedPlaybackImage> _smbPrefetchedImages = {};
  ImageStream? _pendingImageStream;
  ImageStreamListener? _pendingImageListener;
  int _loadGeneration = 0;
  bool _didLoadInitialImage = false;
  bool _didResolveDependencies = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _didResolveDependencies = true;
    if (!_didLoadInitialImage) {
      _didLoadInitialImage = true;
      _loadCurrentImage();
    }
    _schedulePrefetchNextImage();
  }

  @override
  void didUpdateWidget(covariant _PlaybackFrame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id ||
        oldWidget.networkConfig?.stableId != widget.networkConfig?.stableId) {
      _loadCurrentImage();
    }
    _schedulePrefetchNextImage();
  }

  @override
  void dispose() {
    _disposePendingImageStream();
    super.dispose();
  }

  void _schedulePrefetchNextImage() {
    if (!_didResolveDependencies) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_didResolveDependencies) {
        return;
      }
      _prefetchNextImage();
    });
  }

  void _disposePendingImageStream() {
    final stream = _pendingImageStream;
    final listener = _pendingImageListener;
    if (stream != null && listener != null) {
      stream.removeListener(listener);
    }
    _pendingImageStream = null;
    _pendingImageListener = null;
  }

  String _smbResolvedCacheKey(NetworkSourceConfig config, String remotePath) {
    return 'smb:${SmbImageRequest(config: config, remotePath: remotePath).cacheKey}';
  }

  void _rememberSmbImage(_ResolvedPlaybackImage image) {
    if (!image.cacheKey.startsWith('smb:')) {
      return;
    }
    _smbPrefetchedImages[image.cacheKey] = image;
  }

  void _pruneSmbPrefetchedImages({String? displayedKey}) {
    final nextItem = widget.nextItem;
    final nextKey =
        nextItem == null ||
            nextItem.kind != MediaItemKind.remote ||
            widget.networkConfig?.protocol != NetworkSourceProtocol.smb
        ? null
        : _smbResolvedCacheKey(widget.networkConfig!, nextItem.path);
    final resolvedDisplayedKey = displayedKey ?? _displayedImage?.cacheKey;
    _smbPrefetchedImages.removeWhere(
      (key, value) => key != resolvedDisplayedKey && key != nextKey,
    );
  }

  _ResolvedPlaybackImage _buildResolvedSmbImage(
    SmbImageRequest request,
    Uint8List bytes,
  ) {
    return _ResolvedPlaybackImage(
      cacheKey: 'smb:${request.cacheKey}',
      child: _buildMemoryImage(bytes),
    );
  }

  void _setDisplayedImage(_ResolvedPlaybackImage image) {
    if (_displayedImage?.cacheKey == image.cacheKey) {
      return;
    }
    _rememberSmbImage(image);
    _pruneSmbPrefetchedImages(displayedKey: image.cacheKey);
    if (!mounted) {
      _displayedImage = image;
      return;
    }
    setState(() {
      _displayedImage = image;
    });
  }

  void _loadCurrentImage() {
    _disposePendingImageStream();
    final generation = ++_loadGeneration;
    final resolved = _resolveSynchronousImage(widget.item);
    if (resolved != null) {
      _setDisplayedImage(resolved);
      return;
    }

    final config = widget.networkConfig;
    if (widget.item.kind != MediaItemKind.remote || config == null) {
      return;
    }

    if (config.protocol == NetworkSourceProtocol.smb) {
      final request = SmbImageRequest(
        config: config,
        remotePath: widget.item.path,
      );
      ref
          .read(smbImageBytesProvider(request).future)
          .then((bytes) {
            if (!mounted || generation != _loadGeneration) {
              return;
            }
            final image = _buildResolvedSmbImage(request, bytes);
            _rememberSmbImage(image);
            _pruneSmbPrefetchedImages();
            _setDisplayedImage(image);
          })
          .catchError((_) {
            if (!mounted || generation != _loadGeneration) {
              return;
            }
            _setDisplayedImage(
              const _ResolvedPlaybackImage(
                cacheKey: 'remote-error',
                child: _RemoteErrorPlaceholder(),
              ),
            );
          });
      return;
    }

    final provider = NetworkImage(
      widget.item.path,
      headers: widget.headers.isEmpty ? null : widget.headers,
    );
    final stream = provider.resolve(createLocalImageConfiguration(context));
    late final ImageStreamListener listener;
    listener = ImageStreamListener(
      (image, synchronousCall) {
        if (!mounted || generation != _loadGeneration) {
          return;
        }
        _disposePendingImageStream();
        _setDisplayedImage(
          _ResolvedPlaybackImage(
            cacheKey: 'network:${widget.item.path}',
            child: Image(
              image: provider,
              fit: BoxFit.cover,
              gaplessPlayback: true,
              errorBuilder: (context, error, stackTrace) {
                return const _RemoteErrorPlaceholder();
              },
            ),
          ),
        );
      },
      onError: (error, stackTrace) {
        if (!mounted || generation != _loadGeneration) {
          return;
        }
        _disposePendingImageStream();
        _setDisplayedImage(
          const _ResolvedPlaybackImage(
            cacheKey: 'remote-error',
            child: _RemoteErrorPlaceholder(),
          ),
        );
      },
    );
    _pendingImageStream = stream;
    _pendingImageListener = listener;
    stream.addListener(listener);
  }

  _ResolvedPlaybackImage? _resolveSynchronousImage(MediaItem item) {
    if (item.kind == MediaItemKind.file) {
      return _ResolvedPlaybackImage(
        cacheKey: 'file:${item.path}',
        child: buildLocalImage(item.path),
      );
    }

    if (item.kind == MediaItemKind.mediaAsset) {
      return _ResolvedPlaybackImage(
        cacheKey: 'asset:${item.path}',
        child: buildMediaAssetImage(item.path, isOriginal: true),
      );
    }

    if (item.kind == MediaItemKind.asset) {
      return _ResolvedPlaybackImage(
        cacheKey: 'bundle:${item.assetPath}',
        child: Image.asset(item.assetPath, fit: BoxFit.cover),
      );
    }

    if (item.kind != MediaItemKind.remote) {
      return null;
    }

    final config = widget.networkConfig;
    if (config?.protocol == NetworkSourceProtocol.smb) {
      return _smbPrefetchedImages[_smbResolvedCacheKey(config!, item.path)];
    }

    final memoryBytes = item.tryDecodeBase64Path();
    if (memoryBytes == null) {
      return null;
    }
    return _ResolvedPlaybackImage(
      cacheKey: 'memory:${item.id}',
      child: _buildMemoryImage(memoryBytes),
    );
  }

  Widget _buildMemoryImage(Uint8List bytes) {
    return Image.memory(
      bytes,
      fit: BoxFit.cover,
      gaplessPlayback: true,
      errorBuilder: (context, error, stackTrace) {
        return const _RemoteErrorPlaceholder();
      },
    );
  }

  Future<void> _prefetchNextImage() async {
    final nextItem = widget.nextItem;
    if (!mounted || nextItem == null || nextItem.kind != MediaItemKind.remote) {
      return;
    }

    final config = widget.networkConfig;
    if (config?.protocol == NetworkSourceProtocol.smb) {
      _pruneSmbPrefetchedImages();
      final request = SmbImageRequest(
        config: config!,
        remotePath: nextItem.path,
      );
      if (_smbPrefetchedImages.containsKey('smb:${request.cacheKey}')) {
        return;
      }
      try {
        final bytes = await ref.read(smbImageBytesProvider(request).future);
        if (!mounted) {
          return;
        }
        _rememberSmbImage(_buildResolvedSmbImage(request, bytes));
        _pruneSmbPrefetchedImages();
      } catch (_) {}
      return;
    }

    final memoryBytes = nextItem.tryDecodeBase64Path();
    if (memoryBytes != null) {
      return;
    }

    final provider = NetworkImage(
      nextItem.path,
      headers: widget.headers.isEmpty ? null : widget.headers,
    );
    try {
      await precacheImage(provider, context, onError: (error, stackTrace) {});
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final displayedImage = _displayedImage;
    if (displayedImage == null) {
      return ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return AnimatedSwitcher(
      duration: AppMotion.emphasis,
      switchInCurve: AppMotion.curve,
      switchOutCurve: AppMotion.curve,
      transitionBuilder: (child, animation) {
        final scaleIn = Tween<double>(begin: 1.05, end: 1.0).animate(animation);
        final scaleOut = Tween<double>(begin: 1.0, end: 0.95).animate(animation);
        final isIncoming = child.key == ValueKey(displayedImage.cacheKey);
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: isIncoming ? scaleIn : scaleOut,
            child: child,
          ),
        );
      },
      child: KeyedSubtree(
        key: ValueKey(displayedImage.cacheKey),
        child: displayedImage.child,
      ),
    );
  }
}

class _ResolvedPlaybackImage {
  const _ResolvedPlaybackImage({required this.cacheKey, required this.child});

  final String cacheKey;
  final Widget child;
}

class _RemoteErrorPlaceholder extends StatelessWidget {
  const _RemoteErrorPlaceholder();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Center(child: Icon(Icons.cloud_off_outlined, size: 64)),
    );
  }
}

class _GlassButton extends StatelessWidget {
  const _GlassButton({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            color: Colors.white.withValues(alpha: 0.12),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _GlassBadge extends StatelessWidget {
  const _GlassBadge({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: Colors.white.withValues(alpha: 0.12),
          child: Text(
            value,
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
