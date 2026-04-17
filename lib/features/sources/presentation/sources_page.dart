import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/router/app_destination.dart';
import '../../../core/widgets/local_image.dart';
import '../../settings/application/playback_settings.dart';
import '../../settings/application/playback_settings_controller.dart';
import '../application/local_file_picker.dart';
import '../application/local_sources_controller.dart';
import '../application/selected_source_controller.dart';
import '../domain/media_item.dart';
import '../domain/media_source.dart';

class SourcesPage extends ConsumerWidget {
  const SourcesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final sources = ref.watch(allSourcesProvider);
    final selectedId =
        ref.watch(selectedSourceControllerProvider).asData?.value;
    final settings =
        ref.watch(playbackSettingsControllerProvider).asData?.value ??
        const PlaybackSettings.defaults();

    Future<void> pickLocalFiles() async {
      final items = await ref.read(localFilePickerProvider).pickImages();
      final source = await ref
          .read(localSourcesControllerProvider.notifier)
          .importItems(
            items,
            title: l10n.localFilesSourceTitle,
            description: l10n.localFilesSourceDescription,
            badge: l10n.localFilesSourceBadge,
          );

      if (source == null || !context.mounted) {
        return;
      }

      await ref.read(selectedSourceControllerProvider.notifier).select(source.id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.localFilesImported(items.length))),
        );
        context.go(AppDestination.playback.path);
      }
    }

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.sourcesTitle,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.sourcesBody,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            FilledButton.icon(
              onPressed: pickLocalFiles,
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: Text(l10n.addLocalFilesSource),
            ),
          ],
        ),
        const SizedBox(height: 24),
        for (final source in sources)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _SourceCard(
              source: source,
              isSelected: source.id == selectedId,
              intervalSeconds: settings.intervalSeconds,
              onSelect: () {
                ref
                    .read(selectedSourceControllerProvider.notifier)
                    .select(source.id);
              },
              onOpenPlayback: () {
                ref
                    .read(selectedSourceControllerProvider.notifier)
                    .select(source.id);
                if (context.mounted) {
                  context.go(AppDestination.playback.path);
                }
              },
              onRemove: source.kind == MediaSourceKind.bundled
                  ? null
                  : () async {
                      final removingSelected = source.id == selectedId;
                      await ref
                          .read(localSourcesControllerProvider.notifier)
                          .remove(source.id);
                      if (removingSelected) {
                        await ref
                            .read(selectedSourceControllerProvider.notifier)
                            .clear();
                      }
                    },
            ),
          ),
      ],
    );
  }
}

class _SourceCard extends StatelessWidget {
  const _SourceCard({
    required this.source,
    required this.isSelected,
    required this.intervalSeconds,
    required this.onSelect,
    required this.onOpenPlayback,
    this.onRemove,
  });

  final MediaSource source;
  final bool isSelected;
  final int intervalSeconds;
  final VoidCallback onSelect;
  final VoidCallback onOpenPlayback;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final preview = source.items.first;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: _SourcePreview(item: preview),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(source.title, style: theme.textTheme.titleLarge),
                          Chip(
                            label: Text(
                              source.kind == MediaSourceKind.bundled
                                  ? l10n.builtInSourceBadge
                                  : source.badge,
                            ),
                            visualDensity: VisualDensity.compact,
                          ),
                          if (isSelected)
                            Chip(
                              label: Text(l10n.selectedSourceLabel),
                              visualDensity: VisualDensity.compact,
                            ),
                          if (onRemove != null)
                            ActionChip(
                              avatar: const Icon(Icons.delete_outline, size: 18),
                              label: Text(l10n.removeSource),
                              onPressed: onRemove,
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(source.description),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _MetaBadge(
                            label: l10n.itemsCountLabel,
                            value: '${source.items.length}',
                          ),
                          _MetaBadge(
                            label: l10n.intervalLabel,
                            value: '$intervalSeconds ${l10n.secondsUnit}',
                          ),
                          _MetaBadge(
                            label: l10n.sourceReady,
                            value: preview.title,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton.tonal(
                  onPressed: onSelect,
                  child: Text(l10n.selectSource),
                ),
                FilledButton(
                  onPressed: onOpenPlayback,
                  child: Text(l10n.openPlayback),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SourcePreview extends StatelessWidget {
  const _SourcePreview({required this.item});

  final MediaItem item;

  @override
  Widget build(BuildContext context) {
    if (item.kind == MediaItemKind.file) {
      return buildLocalImage(item.path, width: 132, height: 92);
    }

    return Image.asset(
      item.assetPath,
      width: 132,
      height: 92,
      fit: BoxFit.cover,
    );
  }
}

class _MetaBadge extends StatelessWidget {
  const _MetaBadge({required this.label, required this.value});

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
