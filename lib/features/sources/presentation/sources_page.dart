import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/router/app_destination.dart';
import '../../../core/widgets/local_image.dart';
import '../../../core/widgets/media_asset_image.dart';
import '../../settings/application/playback_settings.dart';
import '../../settings/application/playback_settings_controller.dart';
import '../application/local_file_picker.dart';
import '../application/local_sources_controller.dart';
import '../application/media_library_picker.dart';
import '../application/media_library_picker_result.dart';
import '../application/network_source_result.dart';
import '../application/network_source_service.dart';
import '../application/selected_source_controller.dart';
import '../domain/media_item.dart';
import '../domain/media_source.dart';

class SourcesPage extends ConsumerWidget {
  const SourcesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final sources = ref.watch(allSourcesProvider);
    final selectedId = ref
        .watch(selectedSourceControllerProvider)
        .asData
        ?.value;
    final settings =
        ref.watch(playbackSettingsControllerProvider).asData?.value ??
        const PlaybackSettings.defaults();
    final canImportDirectory = _supportsDirectoryImport();
    final canImportMediaLibrary = ref
        .read(mediaLibraryPickerProvider)
        .isSupported;
    final canImportNetworkSource = ref
        .read(networkSourceServiceProvider)
        .isSupported;

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

      await ref
          .read(selectedSourceControllerProvider.notifier)
          .select(source.id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.localFilesImported(items.length))),
        );
        context.go(AppDestination.playback.path);
      }
    }

    Future<void> pickLocalDirectory() async {
      final directoryPath = await ref
          .read(localFilePickerProvider)
          .pickDirectoryPath();
      if (directoryPath == null || directoryPath.isEmpty) {
        return;
      }

      final source = await ref
          .read(localSourcesControllerProvider.notifier)
          .importDirectory(
            directoryPath,
            badge: l10n.localDirectorySourceBadge,
          );
      if (source == null || !context.mounted) {
        return;
      }

      await ref
          .read(selectedSourceControllerProvider.notifier)
          .select(source.id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.localDirectoryImported(source.items.length)),
          ),
        );
        context.go(AppDestination.playback.path);
      }
    }

    Future<void> pickMediaLibrary() async {
      final result = await ref
          .read(mediaLibraryPickerProvider)
          .pickImages(context);
      if (!context.mounted) {
        return;
      }

      switch (result.status) {
        case MediaLibraryPickStatus.success:
          final source = await ref
              .read(localSourcesControllerProvider.notifier)
              .importMediaLibraryItems(
                result.items,
                title: l10n.mediaLibrarySourceTitle,
                description: l10n.mediaLibrarySourceDescription,
                badge: l10n.mediaLibrarySourceBadge,
              );
          if (source == null || !context.mounted) {
            return;
          }

          await ref
              .read(selectedSourceControllerProvider.notifier)
              .select(source.id);

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.mediaLibraryImported(result.items.length)),
              ),
            );
            context.go(AppDestination.playback.path);
          }
        case MediaLibraryPickStatus.permissionDenied:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.mediaLibraryPermissionDenied)),
          );
        case MediaLibraryPickStatus.unsupported:
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.mediaLibraryUnavailable)));
        case MediaLibraryPickStatus.cancelled || MediaLibraryPickStatus.empty:
          return;
      }
    }

    Future<void> pickNetworkSource() async {
      final result = await ref
          .read(networkSourceServiceProvider)
          .createSource(
            context,
            title: l10n.networkSourceTitle,
            description: l10n.networkSourceDescription,
            badge: l10n.networkSourceBadge,
          );
      if (!context.mounted) {
        return;
      }

      switch (result) {
        case NetworkSourceValidationSuccess(:final draft):
          final source = await ref
              .read(localSourcesControllerProvider.notifier)
              .importNetworkSource(draft);
          if (source == null || !context.mounted) {
            return;
          }

          await ref
              .read(selectedSourceControllerProvider.notifier)
              .select(source.id);

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.networkSourceImported(source.items.length)),
              ),
            );
            context.go(AppDestination.playback.path);
          }
        case NetworkSourceValidationFailure(:final message):
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        case NetworkSourceValidationUnsupported():
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.networkSourceUnavailable)),
          );
        case NetworkSourceValidationCancelled():
          return;
      }
    }

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 980),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              Icons.photo_library_outlined,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSecondaryContainer,
                            ),
                          ),
                          const SizedBox(height: 20),
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
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.end,
                      children: [
                        FilledButton.icon(
                          onPressed: pickLocalFiles,
                          icon: const Icon(Icons.add_photo_alternate_outlined),
                          label: Text(l10n.addLocalFilesSource),
                        ),
                        if (canImportDirectory)
                          OutlinedButton.icon(
                            onPressed: pickLocalDirectory,
                            icon: const Icon(Icons.folder_open_outlined),
                            label: Text(l10n.addLocalDirectorySource),
                          ),
                        if (canImportMediaLibrary)
                          OutlinedButton.icon(
                            onPressed: pickMediaLibrary,
                            icon: const Icon(Icons.photo_library_outlined),
                            label: Text(l10n.addMediaLibrarySource),
                          ),
                        if (canImportNetworkSource)
                          OutlinedButton.icon(
                            onPressed: pickNetworkSource,
                            icon: const Icon(Icons.cloud_outlined),
                            label: Text(l10n.addNetworkSource),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
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
                  onEdit: source.kind != MediaSourceKind.network
                      ? null
                      : () async {
                          final draft = NetworkSourceDraft(
                            title: source.title,
                            description: source.description,
                            badge: source.badge,
                            config: source.networkConfig!,
                            items: source.items,
                          );
                          final result = await ref
                              .read(networkSourceServiceProvider)
                              .createSource(
                                context,
                                title: l10n.networkSourceTitle,
                                description: l10n.networkSourceDescription,
                                badge: l10n.networkSourceBadge,
                                initialDraft: draft,
                              );
                          if (!context.mounted) {
                            return;
                          }

                          switch (result) {
                            case NetworkSourceValidationSuccess(:final draft):
                              final previousStableId =
                                  source.networkConfig?.stableId;
                              final updated = await ref
                                  .read(localSourcesControllerProvider.notifier)
                                  .updateNetworkSource(
                                    source.id,
                                    draft,
                                    previousStableId: previousStableId,
                                  );
                              if (updated == null || !context.mounted) {
                                return;
                              }
                              await ref
                                  .read(selectedSourceControllerProvider.notifier)
                                  .select(updated.id);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      l10n.networkSourceUpdated(
                                        updated.items.length,
                                      ),
                                    ),
                                  ),
                                );
                              }
                            case NetworkSourceValidationFailure(:final message):
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(SnackBar(content: Text(message)));
                            case NetworkSourceValidationUnsupported():
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l10n.networkSourceUnavailable),
                                ),
                              );
                            case NetworkSourceValidationCancelled():
                              return;
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
        ),
      ),
    );
  }

  bool _supportsDirectoryImport() {
    if (kIsWeb) {
      return false;
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.android ||
      TargetPlatform.linux ||
      TargetPlatform.macOS ||
      TargetPlatform.windows => true,
      TargetPlatform.iOS || TargetPlatform.fuchsia => false,
    };
  }
}

class _SourceCard extends StatelessWidget {
  const _SourceCard({
    required this.source,
    required this.isSelected,
    required this.intervalSeconds,
    required this.onSelect,
    required this.onOpenPlayback,
    this.onEdit,
    this.onRemove,
  });

  final MediaSource source;
  final bool isSelected;
  final int intervalSeconds;
  final VoidCallback onSelect;
  final VoidCallback onOpenPlayback;
  final VoidCallback? onEdit;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
                  borderRadius: BorderRadius.circular(20),
                  child: _SourcePreview(source: source),
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
                              avatar: Icon(
                                Icons.check_circle_outlined,
                                size: 18,
                                color: colorScheme.onSecondaryContainer,
                              ),
                              label: Text(l10n.selectedSourceLabel),
                              visualDensity: VisualDensity.compact,
                              backgroundColor: colorScheme.secondaryContainer,
                              labelStyle: theme.textTheme.labelMedium?.copyWith(
                                color: colorScheme.onSecondaryContainer,
                              ),
                              side: BorderSide.none,
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        l10n.sourceSummaryReady(source.items.length),
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        source.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton(
                  onPressed: onOpenPlayback,
                  child: Text(l10n.openPlayback),
                ),
                OutlinedButton(
                  onPressed: onSelect,
                  child: Text(l10n.selectSource),
                ),
                if (onEdit != null)
                  OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined),
                    label: Text(l10n.editSource),
                  ),
                if (onRemove != null)
                  TextButton.icon(
                    onPressed: onRemove,
                    icon: const Icon(Icons.delete_outline),
                    label: Text(l10n.removeSource),
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
  const _SourcePreview({required this.source});

  final MediaSource source;

  @override
  Widget build(BuildContext context) {
    final item = source.items.first;

    if (item.kind == MediaItemKind.file) {
      return buildLocalImage(item.path, width: 132, height: 92);
    }

    if (item.kind == MediaItemKind.mediaAsset) {
      return buildMediaAssetImage(item.path, width: 132, height: 92);
    }

    if (item.kind == MediaItemKind.remote) {
      final colorScheme = Theme.of(context).colorScheme;
      final textTheme = Theme.of(context).textTheme;

      return Image.network(
        item.path,
        headers: source.networkConfig?.authorizationHeaders,
        width: 132,
        height: 92,
        fit: BoxFit.cover,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          final isLoaded = wasSynchronouslyLoaded || frame != null;
          if (isLoaded) {
            return child;
          }
          return ColoredBox(
            color: colorScheme.surfaceContainerHighest,
            child: SizedBox(
              width: 132,
              height: 92,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.2),
                  ),
                  const SizedBox(height: 8),
                  Text('正在加载缩略图', style: textTheme.bodySmall),
                ],
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return ColoredBox(
            color: colorScheme.surfaceContainerHighest,
            child: SizedBox(
              width: 132,
              height: 92,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_off_outlined, size: 28),
                  const SizedBox(height: 6),
                  Text('缩略图加载失败', style: textTheme.bodySmall),
                ],
              ),
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) => child,
      );
    }

    return Image.asset(
      item.assetPath,
      width: 132,
      height: 92,
      fit: BoxFit.cover,
    );
  }
}

