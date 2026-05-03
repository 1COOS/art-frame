import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/router/app_destination.dart';
import 'local/local_file_picker.dart';
import 'local_sources_controller.dart';
import 'local/media_library_picker.dart';
import '../domain/media_library_pick_result.dart';
import '../domain/network_source_result.dart';
import 'network/network_source_service.dart';
import 'selected_source_controller.dart';
import '../domain/media_source.dart';

class SourceImportActions {
  const SourceImportActions(this.ref, this.context, this.l10n);

  final WidgetRef ref;
  final BuildContext context;
  final AppLocalizations l10n;

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


  Future<void> editNetworkSource(
    MediaSource source, {
    required String? selectedId,
  }) async {
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
        final previousStableId = source.networkConfig?.stableId;
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
                l10n.networkSourceUpdated(updated.items.length),
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
          SnackBar(content: Text(l10n.networkSourceUnavailable)),
        );
      case NetworkSourceValidationCancelled():
        return;
    }
  }
}