import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../sources/application/local/media_library_picker.dart';
import '../../sources/application/network/network_source_service.dart';
import '../../sources/application/source_import_actions.dart';

class ConnectPage extends ConsumerWidget {
  const ConnectPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final actions = SourceImportActions(ref, context, l10n);

    final canImportDirectory = _supportsDirectoryImport();
    final canImportMediaLibrary =
        ref.read(mediaLibraryPickerProvider).isSupported;
    final canImportNetworkSource =
        ref.read(networkSourceServiceProvider).isSupported;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          children: [
            Text(
              l10n.connectTitle,
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.connectBody,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            _ConnectOptionTile(
              icon: Icons.add_photo_alternate_outlined,
              title: l10n.addLocalFilesSource,
              onTap: actions.pickLocalFiles,
            ),
            if (canImportDirectory)
              _ConnectOptionTile(
                icon: Icons.folder_open_outlined,
                title: l10n.addLocalDirectorySource,
                onTap: actions.pickLocalDirectory,
              ),
            if (canImportMediaLibrary)
              _ConnectOptionTile(
                icon: Icons.photo_library_outlined,
                title: l10n.addMediaLibrarySource,
                onTap: actions.pickMediaLibrary,
              ),
            if (canImportNetworkSource)
              _ConnectOptionTile(
                icon: Icons.cloud_outlined,
                title: l10n.addNetworkSource,
                onTap: actions.pickNetworkSource,
              ),
          ],
        ),
      ),
    );
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

class _ConnectOptionTile extends StatelessWidget {
  const _ConnectOptionTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}
