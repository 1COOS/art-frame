import 'package:flutter/material.dart';

import '../../domain/network_source_config.dart';
import 'network_endpoint_parser.dart';
import '../../domain/network_source_result.dart';
import 'smb_client.dart';
import 'webdav_client.dart';

class WebDavBrowseState {
  const WebDavBrowseState({required this.config, required this.result});

  final NetworkSourceConfig config;
  final WebDavBrowseResult result;
}

class SmbBrowseState {
  const SmbBrowseState({required this.config, required this.result});

  final NetworkSourceConfig config;
  final SmbBrowseResult result;
}

class DirectoryEntryViewModel {
  const DirectoryEntryViewModel({
    required this.name,
    required this.path,
    required this.onTap,
  });

  final String name;
  final String path;
  final VoidCallback onTap;
}

Future<NetworkSourceDraft?> showWebDavDirectoryBrowser(
  BuildContext context, {
  required WebDavClient client,
  required NetworkSourceConfig initialConfig,
  required String title,
  required String badge,
}) async {
  var currentConfig = initialConfig;
  var currentResult = await client.browseDirectory(initialConfig);
  if (!context.mounted) {
    return null;
  }
  final trail = <WebDavBrowseState>[];
  var loading = false;
  String? errorText;
  final resolvedTitle =
      initialConfig.displayName?.trim().isNotEmpty == true
      ? initialConfig.displayName!.trim()
      : title;

  return showDialog<NetworkSourceDraft>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (dialogContext, setState) {
          Future<void> openDirectory(WebDavDirectoryEntry entry) async {
            if (loading) {
              return;
            }

            setState(() {
              loading = true;
              errorText = null;
            });
            final nextConfig = currentConfig.copyWith(remotePath: entry.path);
            try {
              final nextResult = await client.browseDirectory(nextConfig);
              setState(() {
                trail.add(
                  WebDavBrowseState(
                    config: currentConfig,
                    result: currentResult,
                  ),
                );
                currentConfig = nextConfig;
                currentResult = nextResult;
                loading = false;
              });
            } on WebDavException catch (error) {
              setState(() {
                loading = false;
                errorText = error.message;
              });
            } catch (error) {
              setState(() {
                loading = false;
                errorText = unexpectedWebDavMessage(
                  error,
                  fallback: '读取目录失败，请重试',
                );
              });
            }
          }

          void goBack() {
            if (loading || trail.isEmpty) {
              return;
            }
            final previous = trail.removeLast();
            setState(() {
              currentConfig = previous.config;
              currentResult = previous.result;
              errorText = null;
            });
          }

          void importCurrentDirectory() {
            if (currentResult.items.isEmpty) {
              setState(() {
                errorText = '当前目录下没有可用图片';
              });
              return;
            }

            Navigator.of(dialogContext).pop(
              NetworkSourceDraft(
                title: resolvedTitle,
                description: currentConfig.endpointLabel,
                badge: badge,
                config: currentConfig.copyWith(displayName: resolvedTitle),
                items: currentResult.items,
              ),
            );
          }

          final imagePreview = currentResult.items
              .take(3)
              .map((item) => item.title)
              .join('\n');

          return DirectoryDialogShell(
            title: '选择 WebDAV 目录',
            normalizedPath: currentResult.normalizedPath,
            itemCount: currentResult.items.length,
            imagePreview: imagePreview,
            directoryCount: currentResult.directories.length,
            directories: currentResult.directories
                .map(
                  (entry) => DirectoryEntryViewModel(
                    name: entry.name,
                    path: entry.path,
                    onTap: () => openDirectory(entry),
                  ),
                )
                .toList(growable: false),
            canGoBack: trail.isNotEmpty,
            isLoading: loading,
            emptyDirectoriesLabel: '当前目录下没有子文件夹',
            backLabel: '返回上一级',
            cancelLabel: '返回配置',
            importLabel: '导入当前目录',
            errorText: errorText,
            onGoBack: goBack,
            onCancel: () => Navigator.of(dialogContext).pop(),
            onImport: currentResult.items.isEmpty ? null : importCurrentDirectory,
          );
        },
      );
    },
  );
}



Future<NetworkSourceDraft?> showSmbDirectoryBrowser(
  BuildContext context, {
  required SmbClient client,
  required NetworkSourceConfig initialConfig,
  required String title,
  required String badge,
}) async {
  var currentConfig = initialConfig;
  var currentResult = await client.browseDirectory(initialConfig);
  if (!context.mounted) {
    return null;
  }
  final trail = <SmbBrowseState>[];
  var loading = false;
  String? errorText;
  final resolvedTitle =
      initialConfig.displayName?.trim().isNotEmpty == true
      ? initialConfig.displayName!.trim()
      : title;

  return showDialog<NetworkSourceDraft>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (dialogContext, setState) {
          Future<void> openDirectory(SmbDirectoryEntry entry) async {
            if (loading) {
              return;
            }

            setState(() {
              loading = true;
              errorText = null;
            });
            final nextConfig = currentConfig.copyWith(remotePath: entry.path);
            try {
              final nextResult = await client.browseDirectory(nextConfig);
              setState(() {
                trail.add(
                  SmbBrowseState(
                    config: currentConfig,
                    result: currentResult,
                  ),
                );

                currentConfig = nextConfig;
                currentResult = nextResult;
                loading = false;
              });
            } on SmbException catch (error) {
              setState(() {
                loading = false;
                errorText = error.message;
              });
            } catch (error) {
              setState(() {
                loading = false;
                errorText = unexpectedSmbMessage(
                  error,
                  fallback: '读取 SMB 目录失败，请重试',
                );
              });
            }
          }

          void goBack() {
            if (loading || trail.isEmpty) {
              return;
            }
            final previous = trail.removeLast();
            setState(() {
              currentConfig = previous.config;
              currentResult = previous.result;
              errorText = null;
            });
          }

          void importCurrentDirectory() {
            if (currentResult.items.isEmpty) {
              setState(() {
                errorText = '当前目录下没有可用图片';
              });
              return;
            }

            Navigator.of(dialogContext).pop(
              NetworkSourceDraft(
                title: resolvedTitle,
                description: currentConfig.endpointLabel,
                badge: badge,
                config: currentConfig.copyWith(displayName: resolvedTitle),
                items: currentResult.items,
              ),
            );
          }


          final imagePreview = currentResult.items
              .take(3)
              .map((item) => item.title)
              .join('\n');

          return DirectoryDialogShell(
            title: '选择 SMB 目录',
            normalizedPath: currentResult.normalizedPath,
            itemCount: currentResult.items.length,
            imagePreview: imagePreview,
            directoryCount: currentResult.directories.length,
            directories: currentResult.directories
                .map(
                  (entry) => DirectoryEntryViewModel(
                    name: entry.name,
                    path: entry.path,
                    onTap: () => openDirectory(entry),
                  ),
                )
                .toList(growable: false),
            canGoBack: trail.isNotEmpty,
            isLoading: loading,
            emptyDirectoriesLabel: '当前 SMB 目录下没有子文件夹',
            backLabel: '返回上一级',
            cancelLabel: '返回配置',
            importLabel: '导入当前目录',
            errorText: errorText,
            onGoBack: goBack,
            onCancel: () => Navigator.of(dialogContext).pop(),
            onImport: currentResult.items.isEmpty ? null : importCurrentDirectory,
          );
        },
      );
    },
  );
}



class DirectoryDialogShell extends StatelessWidget {
  const DirectoryDialogShell({
    super.key,
    required this.title,
    required this.normalizedPath,
    required this.itemCount,
    required this.imagePreview,
    required this.directoryCount,
    required this.directories,
    required this.canGoBack,
    required this.isLoading,
    required this.emptyDirectoriesLabel,
    required this.backLabel,
    required this.cancelLabel,
    required this.importLabel,
    required this.onCancel,
    required this.onImport,
    this.errorText,
    this.onGoBack,
  });

  final String title;
  final String normalizedPath;
  final int itemCount;
  final String imagePreview;
  final int directoryCount;
  final List<DirectoryEntryViewModel> directories;
  final bool canGoBack;
  final bool isLoading;
  final String emptyDirectoriesLabel;
  final String backLabel;
  final String cancelLabel;
  final String importLabel;
  final String? errorText;
  final VoidCallback? onGoBack;
  final VoidCallback onCancel;
  final VoidCallback? onImport;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 520),

        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              Text(
                normalizedPath,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Text('当前目录包含 $itemCount 张图片'),
              if (imagePreview.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  imagePreview,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  if (canGoBack)
                    TextButton.icon(
                      onPressed: isLoading ? null : onGoBack,
                      icon: const Icon(Icons.arrow_back),
                      label: Text(backLabel),
                    ),
                  const Spacer(),
                  Text('子文件夹 $directoryCount 个'),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : directories.isEmpty
                    ? Center(child: Text(emptyDirectoriesLabel))
                    : ListView.builder(
                        itemCount: directories.length,
                        itemBuilder: (context, index) {
                          final entry = directories[index];

                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.folder_outlined),
                            title: Text(entry.name),
                            subtitle: Text(
                              entry.path,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: entry.onTap,
                          );
                        },
                      ),
              ),
              if (errorText != null) ...[
                const SizedBox(height: 12),
                Text(
                  errorText!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: isLoading ? null : onCancel,
                    child: Text(cancelLabel),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: isLoading ? null : onImport,
                    child: Text(importLabel),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
