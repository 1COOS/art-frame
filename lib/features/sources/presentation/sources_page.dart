import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/adaptive/adaptive_layout.dart';
import '../../../app/adaptive/app_breakpoints.dart';
import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/router/app_destination.dart';
import '../../../core/widgets/local_image.dart';
import '../../../core/widgets/media_asset_image.dart';
import '../application/local_sources_controller.dart';
import '../application/selected_source_controller.dart';
import '../application/source_import_actions.dart';
import '../domain/media_item.dart';
import '../domain/media_source.dart';
import '../domain/network_source_config.dart';
import '../application/network/smb_image_provider.dart';

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
    final actions = SourceImportActions(ref, context, l10n);

    return Scaffold(
      body: AdaptiveLayout(
        builder: (context, type) {
          final crossAxisCount = switch (type) {
            AdaptiveWindowType.phone => 2,
            AdaptiveWindowType.tablet => 3,
            AdaptiveWindowType.wide => 4,
          };

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 32, 16, 8),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    l10n.libraryTitle,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final source = sources[index];
                    return _SourceGridItem(
                      source: source,
                      isSelected: source.id == selectedId,
                      onTap: () {
                        ref
                            .read(selectedSourceControllerProvider.notifier)
                            .select(source.id);
                        if (context.mounted) {
                          context.go(AppDestination.playback.path);
                        }
                      },
                      onEdit: source.kind != MediaSourceKind.network
                          ? null
                          : () => actions.editNetworkSource(
                              source,
                              selectedId: selectedId,
                            ),
                      onRemove: source.kind == MediaSourceKind.bundled
                          ? null
                          : () async {
                              final removingSelected = source.id == selectedId;
                              await ref
                                  .read(localSourcesControllerProvider.notifier)
                                  .remove(source.id);
                              if (removingSelected) {
                                await ref
                                    .read(
                                      selectedSourceControllerProvider.notifier,
                                    )
                                    .clear();
                              }
                            },
                    );
                  }, childCount: sources.length),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SourceCoverImage extends ConsumerWidget {
  const _SourceCoverImage({required this.source});

  final MediaSource source;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final item = source.items.first;
    final colorScheme = Theme.of(context).colorScheme;

    if (item.kind == MediaItemKind.file) {
      return SizedBox.expand(
        child: buildLocalImage(item.path, fit: BoxFit.cover),
      );
    }

    if (item.kind == MediaItemKind.mediaAsset) {
      return SizedBox.expand(
        child: buildMediaAssetImage(item.path, fit: BoxFit.cover),
      );
    }

    if (item.kind == MediaItemKind.remote) {
      final config = source.networkConfig;
      if (config?.protocol == NetworkSourceProtocol.smb) {
        final smbBytes = ref.watch(
          smbImageBytesProvider(
            SmbImageRequest(config: config!, remotePath: item.path),
          ),
        );
        return smbBytes.when(
          data: (bytes) =>
              SizedBox.expand(child: Image.memory(bytes, fit: BoxFit.cover)),
          error: (_, _) => _CoverPlaceholder(colorScheme: colorScheme),
          loading: () =>
              _CoverPlaceholder(colorScheme: colorScheme, isLoading: true),
        );
      }

      final bytes = item.tryDecodeBase64Path();
      if (bytes != null) {
        return SizedBox.expand(child: Image.memory(bytes, fit: BoxFit.cover));
      }

      return SizedBox.expand(
        child: Image.network(
          item.path,
          headers: source.networkConfig?.authorizationHeaders,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) =>
              _CoverPlaceholder(colorScheme: colorScheme),
        ),
      );
    }

    return SizedBox.expand(
      child: Image.asset(item.assetPath, fit: BoxFit.cover),
    );
  }
}

class _SourceGridItem extends ConsumerStatefulWidget {
  const _SourceGridItem({
    required this.source,
    required this.isSelected,
    required this.onTap,
    this.onEdit,
    this.onRemove,
  });

  final MediaSource source;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onRemove;

  @override
  ConsumerState<_SourceGridItem> createState() => _SourceGridItemState();
}

class _SourceGridItemState extends ConsumerState<_SourceGridItem> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        onLongPress: (widget.onEdit != null || widget.onRemove != null)
            ? () => _showActionsMenu(context, l10n)
            : null,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Cover image
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _SourceCoverImage(source: widget.source),
            ),
            // Gradient overlay
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black87],
                    stops: [0.4, 1.0],
                  ),
                ),
              ),
            ),
            // Selected indicator
            if (widget.isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    size: 14,
                    color: colorScheme.onPrimary,
                  ),
                ),
              ),
            // Info overlay at bottom
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.source.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${widget.source.items.length} ${widget.source.badge}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            // Hover actions (desktop)
            if (_hovering && (widget.onEdit != null || widget.onRemove != null))
              Positioned(
                top: 8,
                left: 8,
                child: _GlassIconButton(
                  icon: Icons.more_horiz,
                  onTap: () => _showActionsMenu(context, l10n),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showActionsMenu(BuildContext context, AppLocalizations l10n) {
    final items = <PopupMenuEntry<String>>[
      if (widget.onEdit != null)
        PopupMenuItem(value: 'edit', child: Text(l10n.editSource)),
      if (widget.onRemove != null)
        PopupMenuItem(value: 'remove', child: Text(l10n.removeSource)),
    ];

    final renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy,
        offset.dx + renderBox.size.width,
        offset.dy + renderBox.size.height,
      ),
      items: items,
    ).then((value) {
      if (value == 'edit') widget.onEdit?.call();
      if (value == 'remove') widget.onRemove?.call();
    });
  }
}

class _CoverPlaceholder extends StatelessWidget {
  const _CoverPlaceholder({required this.colorScheme, this.isLoading = false});

  final ColorScheme colorScheme;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: colorScheme.surfaceContainerHighest,
      child: Center(
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(
                Icons.image_outlined,
                size: 32,
                color: colorScheme.onSurfaceVariant,
              ),
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(6),
            color: Colors.black.withValues(alpha: 0.3),
            child: Icon(icon, size: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
