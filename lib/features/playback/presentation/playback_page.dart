import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/router/app_destination.dart';
import '../../../core/widgets/local_image.dart';
import '../../../core/widgets/media_asset_image.dart';
import '../../settings/application/playback_settings.dart';
import '../../settings/application/playback_settings_controller.dart';
import '../../sources/application/selected_source_controller.dart';
import '../../sources/domain/media_item.dart';
import '../../sources/domain/media_source.dart';

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
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final source = ref.watch(selectedSourceProvider);
    final settings =
        ref.watch(playbackSettingsControllerProvider).asData?.value ??
        const PlaybackSettings.defaults();

    _configureTimer(source: source, settings: settings);

    if (source == null || source.items.isEmpty) {
      _timer?.cancel();
      _timer = null;
      _timerKey = null;

      return Center(
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
      );
    }

    final normalizedIndex = _normalizeIndex(source.items.length);
    final currentItem = source.items[normalizedIndex];

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          l10n.playbackTitle,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 12),
        Text(l10n.playbackBody, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 24),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _PlaybackFrame(item: currentItem),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.62),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentItem.title,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            currentItem.description,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _PlaybackMeta(
                      label: l10n.selectedSourceLabel,
                      value: source.title,
                    ),
                    _PlaybackMeta(
                      label: l10n.itemsCountLabel,
                      value: '${source.items.length}',
                    ),
                    _PlaybackMeta(
                      label: l10n.intervalLabel,
                      value: '${settings.intervalSeconds}${l10n.secondsUnit}',
                    ),
                    FilledButton.tonalIcon(
                      onPressed: _showPrevious,
                      icon: const Icon(Icons.chevron_left),
                      label: Text(l10n.previousFrame),
                    ),
                    FilledButton.icon(
                      onPressed: _showNext,
                      icon: const Icon(Icons.chevron_right),
                      label: Text(l10n.nextFrame),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
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

class _PlaybackFrame extends StatelessWidget {
  const _PlaybackFrame({required this.item});

  final MediaItem item;

  @override
  Widget build(BuildContext context) {
    if (item.kind == MediaItemKind.file) {
      return buildLocalImage(item.path);
    }

    if (item.kind == MediaItemKind.mediaAsset) {
      return buildMediaAssetImage(item.path, isOriginal: true);
    }

    return Image.asset(item.assetPath, fit: BoxFit.cover);
  }
}

class _PlaybackMeta extends StatelessWidget {
  const _PlaybackMeta({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 4),
            Text(value, style: Theme.of(context).textTheme.titleSmall),
          ],
        ),
      ),
    );
  }
}
