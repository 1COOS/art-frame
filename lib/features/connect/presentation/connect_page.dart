import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../application/folder_opener.dart' as folder_opener;
import '../../sources/application/local/media_library_picker.dart';
import '../../sources/application/local_sources_controller.dart';
import '../../sources/application/network/network_source_service.dart';
import '../../sources/application/source_import_actions.dart';
import '../../sources/domain/media_source.dart';

class ConnectPage extends ConsumerWidget {
  const ConnectPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final savedSources = ref.watch(localSourcesControllerProvider);
    final actions = SourceImportActions(ref, context, l10n);

    final canImportDirectory = _supportsDirectoryImport();
    final canImportMediaLibrary = ref
        .read(mediaLibraryPickerProvider)
        .isSupported;
    final canImportNetworkSource = ref
        .read(networkSourceServiceProvider)
        .isSupported;

    final importTiles = <Widget>[
      _ConnectOptionTile(
        icon: Icons.add_photo_alternate_outlined,
        title: l10n.addLocalFilesSource,
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: actions.pickLocalFiles,
      ),
      if (canImportDirectory)
        _ConnectOptionTile(
          icon: Icons.folder_open_outlined,
          title: l10n.addLocalDirectorySource,
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: actions.pickLocalDirectory,
        ),
      if (canImportMediaLibrary)
        _ConnectOptionTile(
          icon: Icons.photo_library_outlined,
          title: l10n.addMediaLibrarySource,
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: actions.pickMediaLibrary,
        ),
      if (canImportNetworkSource)
        _ConnectOptionTile(
          icon: Icons.cloud_outlined,
          title: l10n.addNetworkSource,
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: actions.pickNetworkSource,
        ),
    ];

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
          children: [
            Text(l10n.connectTitle, style: theme.textTheme.headlineMedium),
            const SizedBox(height: 24),
            _ConnectSection(
              title: l10n.connectSavedSectionTitle,
              child: _buildSavedSourcesCard(
                context,
                l10n,
                savedSources,
                onOpenFolder: (source) =>
                    _openSavedSourceFolder(context, source),
              ),
            ),
            const SizedBox(height: 24),
            _ConnectSection(
              title: l10n.connectAddFilesSectionTitle,
              child: _ConnectGroupedCard(children: importTiles),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedSourcesCard(
    BuildContext context,
    AppLocalizations l10n,
    AsyncValue<List<MediaSource>> savedSources, {
    required ValueChanged<MediaSource> onOpenFolder,
  }) {
    return savedSources.when(
      data: (sources) {
        if (sources.isEmpty) {
          return _ConnectEmptyCard(message: l10n.connectNoSavedSources);
        }

        return _ConnectGroupedCard(
          children: [
            for (final source in sources)
              _ConnectOptionTile(
                icon: _iconForSource(source.kind),
                title: source.title,
                subtitle:
                    '${source.badge} · ${l10n.sourceSummaryReady(source.items.length)}',
                trailing: !_canOpenSource(source)
                    ? null
                    : const Icon(Icons.folder_open_rounded),
                onTap: !_canOpenSource(source)
                    ? null
                    : () => onOpenFolder(source),
              ),
          ],
        );
      },
      loading: () => const _ConnectLoadingCard(),
      error: (_, _) => _ConnectEmptyCard(message: l10n.connectNoSavedSources),
    );
  }

  Future<void> _openSavedSourceFolder(
    BuildContext context,
    MediaSource source,
  ) async {
    final l10n = AppLocalizations.of(context);
    final folderPath = _savedSourceFolderPath(source);

    bool success;
    if (folderPath != null) {
      success = await folder_opener.openFolder(folderPath);
    } else if (source.kind == MediaSourceKind.mediaLibrary) {
      success = await folder_opener.openGallery();
    } else {
      return;
    }

    if (!context.mounted || success) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.connectOpenFolderFailed)));
  }

  bool _canOpenSource(MediaSource source) {
    if (_savedSourceFolderPath(source) != null) return true;
    // On Android, media-library sources can be opened in the gallery app.
    if (!kIsWeb &&
        defaultTargetPlatform == TargetPlatform.android &&
        source.kind == MediaSourceKind.mediaLibrary &&
        source.items.isNotEmpty) {
      return true;
    }
    return false;
  }

  String? _savedSourceFolderPath(MediaSource source) {
    switch (source.kind) {
      case MediaSourceKind.localDirectory:
        final path = source.directoryPath?.trim();
        return path == null || path.isEmpty ? null : path;
      case MediaSourceKind.localFiles:
        if (source.items.isEmpty) {
          return null;
        }
        return _parentDirectory(source.items.first.path);
      case MediaSourceKind.bundled:
      case MediaSourceKind.mediaLibrary:
      case MediaSourceKind.network:
        return null;
    }
  }

  String? _parentDirectory(String path) {
    final normalizedPath = path.trim();
    if (normalizedPath.isEmpty) {
      return null;
    }

    final separatorIndex = [
      normalizedPath.lastIndexOf('/'),
      normalizedPath.lastIndexOf('\\'),
    ].reduce((current, next) => current > next ? current : next);
    if (separatorIndex <= 0) {
      return null;
    }

    return normalizedPath.substring(0, separatorIndex);
  }

  IconData _iconForSource(MediaSourceKind kind) {
    return switch (kind) {
      MediaSourceKind.bundled => Icons.collections_outlined,
      MediaSourceKind.localDirectory => Icons.folder_open_outlined,
      MediaSourceKind.localFiles => Icons.add_photo_alternate_outlined,
      MediaSourceKind.mediaLibrary => Icons.photo_library_outlined,
      MediaSourceKind.network => Icons.cloud_outlined,
    };
  }

  bool _supportsDirectoryImport() {
    if (kIsWeb) return false;
    return switch (defaultTargetPlatform) {
      TargetPlatform.android ||
      TargetPlatform.linux ||
      TargetPlatform.macOS ||
      TargetPlatform.windows => true,
      TargetPlatform.iOS || TargetPlatform.fuchsia => false,
    };
  }
}

class _ConnectSection extends StatelessWidget {
  const _ConnectSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleLarge),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

class _ConnectGroupedCard extends StatelessWidget {
  const _ConnectGroupedCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Column(
        children: [
          for (var index = 0; index < children.length; index++) ...[
            children[index],
            if (index < children.length - 1)
              Padding(
                padding: const EdgeInsets.only(left: 76, right: 20),
                child: Divider(
                  height: 1,
                  thickness: 1.2,
                  color: colorScheme.primary.withValues(alpha: 0.28),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _ConnectOptionTile extends StatelessWidget {
  const _ConnectOptionTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: trailing,
      onTap: onTap,
    );
  }
}

class _ConnectEmptyCard extends StatelessWidget {
  const _ConnectEmptyCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(message, style: theme.textTheme.bodyLarge),
      ),
    );
  }
}

class _ConnectLoadingCard extends StatelessWidget {
  const _ConnectLoadingCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
