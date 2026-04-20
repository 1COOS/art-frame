import 'package:flutter/material.dart';

import '../domain/network_source_config.dart';
import 'network_source_result.dart';
import 'webdav_client.dart';

const bool isSupported = true;

Future<NetworkSourceValidationResult> createSource(
  BuildContext context, {
  required String title,
  required String description,
  required String badge,
}) async {
  final hostController = TextEditingController(text: 'demo.local');
  final portController = TextEditingController(text: '80');
  final pathController = TextEditingController(text: '/gallery');
  final userController = TextEditingController(text: 'demo');
  final passwordController = TextEditingController(text: 'demo');
  var secure = false;
  var submitting = false;
  String? errorText;

  final result = await showDialog<NetworkSourceValidationResult>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (dialogContext, setState) {
          Future<void> submit() async {
            if (submitting) {
              return;
            }

            final parsed = _parseWebDavEndpoint(
              hostInput: hostController.text,
              portInput: portController.text,
              pathInput: pathController.text,
              secure: secure,
            );
            final config = NetworkSourceConfig(
              protocol: NetworkSourceProtocol.webdav,
              host: parsed.host,
              remotePath: parsed.remotePath,
              username: userController.text.trim().isEmpty
                  ? null
                  : userController.text.trim(),
              password: passwordController.text,
              secure: parsed.secure,
              port: parsed.port,
              displayName: parsed.host,
            );

            if (config.host.isEmpty || config.remotePath.isEmpty) {
              setState(() {
                errorText = 'WebDAV 配置不完整';
              });
              return;
            }

            final client = WebDavClient();
            setState(() {
              submitting = true;
              errorText = null;
            });
            try {
              await client.validate(config);
              if (!dialogContext.mounted) {
                return;
              }
              final draft = await _showDirectoryBrowser(
                dialogContext,
                client: client,
                initialConfig: config,
                title: title,
                badge: badge,
              );
              if (draft == null) {
                setState(() {
                  submitting = false;
                });
                return;
              }

              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop(
                  NetworkSourceValidationSuccess(draft),
                );
              }
            } on WebDavException catch (error) {
              setState(() {
                submitting = false;
                errorText = error.message;
              });
            } catch (error) {
              setState(() {
                submitting = false;
                errorText = _unexpectedWebDavMessage(
                  error,
                  fallback: 'WebDAV 验证失败，请检查协议、地址、端口和路径',
                );
              });
            }
          }

          return AlertDialog(
            title: const Text('添加 WebDAV 图源'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: hostController,
                    decoration: const InputDecoration(
                      labelText: 'Host',
                      hintText:
                          '192.168.2.100、demo.local:5005 或 http://192.168.2.100:5005/gallery',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: portController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Port',
                      hintText: '80 / 443 / 5005（可留空，自动从 Host 推断）',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: pathController,
                    decoration: const InputDecoration(
                      labelText: 'Remote path',
                      hintText: '/gallery（可留空，自动从 Host URL 提取）',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: userController,
                    decoration: const InputDecoration(labelText: 'Username'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    value: secure,
                    title: const Text('Use HTTPS'),
                    onChanged: submitting
                        ? null
                        : (value) {
                            setState(() {
                              secure = value;
                              if (portController.text.trim().isEmpty) {
                                portController.text = value ? '443' : '80';
                              }
                            });
                          },
                    contentPadding: EdgeInsets.zero,
                  ),
                  if (errorText != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      errorText!,
                      style: Theme.of(dialogContext).textTheme.bodyMedium
                          ?.copyWith(
                            color: Theme.of(dialogContext).colorScheme.error,
                          ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: submitting
                    ? null
                    : () => Navigator.of(dialogContext).pop(
                          const NetworkSourceValidationCancelled(),
                        ),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: submitting ? null : submit,
                child: Text(submitting ? 'Loading…' : 'Validate'),
              ),
            ],
          );
        },
      );
    },
  );

  return result ?? const NetworkSourceValidationCancelled();
}

Future<NetworkSourceDraft?> _showDirectoryBrowser(
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
  final trail = <_WebDavBrowseState>[];
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
                  _WebDavBrowseState(
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
                errorText = _unexpectedWebDavMessage(
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

          return Dialog(
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 24,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 480,
                maxHeight: 520,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '选择 WebDAV 目录',
                      style: Theme.of(dialogContext).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      currentResult.normalizedPath,
                      style: Theme.of(dialogContext).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Text('当前目录包含 ${currentResult.items.length} 张图片'),
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
                        if (trail.isNotEmpty)
                          TextButton.icon(
                            onPressed: loading ? null : goBack,
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('返回上一级'),
                          ),
                        const Spacer(),
                        Text('子文件夹 ${currentResult.directories.length} 个'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: loading
                          ? const Center(child: CircularProgressIndicator())
                          : currentResult.directories.isEmpty
                          ? const Center(child: Text('当前目录下没有子文件夹'))
                          : ListView.builder(
                              itemCount: currentResult.directories.length,
                              itemBuilder: (context, index) {
                                final entry = currentResult.directories[index];
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const Icon(Icons.folder_outlined),
                                  title: Text(entry.name),
                                  subtitle: Text(
                                    entry.path,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  onTap: () => openDirectory(entry),
                                );
                              },
                            ),
                    ),
                    if (errorText != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        errorText!,
                        style: Theme.of(dialogContext).textTheme.bodyMedium
                            ?.copyWith(
                              color: Theme.of(dialogContext).colorScheme.error,
                            ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: loading
                              ? null
                              : () => Navigator.of(dialogContext).pop(),
                          child: const Text('返回配置'),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: loading || currentResult.items.isEmpty
                              ? null
                              : importCurrentDirectory,
                          child: const Text('导入当前目录'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

class _WebDavBrowseState {
  const _WebDavBrowseState({required this.config, required this.result});

  final NetworkSourceConfig config;
  final WebDavBrowseResult result;
}

class _ParsedWebDavEndpoint {
  const _ParsedWebDavEndpoint({
    required this.host,
    required this.remotePath,
    required this.secure,
    this.port,
  });

  final String host;
  final String remotePath;
  final bool secure;
  final int? port;
}

({String host, int? port, String remotePath, bool secure})
parseWebDavEndpointForTest({
  required String hostInput,
  required String portInput,
  required String pathInput,
  required bool secure,
}) {
  final parsed = _parseWebDavEndpoint(
    hostInput: hostInput,
    portInput: portInput,
    pathInput: pathInput,
    secure: secure,
  );
  return (
    host: parsed.host,
    port: parsed.port,
    remotePath: parsed.remotePath,
    secure: parsed.secure,
  );
}

String _unexpectedWebDavMessage(Object error, {required String fallback}) {
  var message = error.toString().trim();
  if (message.startsWith('Exception: ')) {
    message = message.substring('Exception: '.length);
  }
  if (message.isEmpty || message == 'null') {
    return fallback;
  }
  return message;
}

_ParsedWebDavEndpoint _parseWebDavEndpoint({
  required String hostInput,
  required String portInput,
  required String pathInput,
  required bool secure,
}) {
  final trimmedHost = hostInput.trim();
  final explicitPort = int.tryParse(portInput.trim());
  final trimmedPath = pathInput.trim();

  if (trimmedHost.startsWith('http://') || trimmedHost.startsWith('https://')) {
    final uri = Uri.tryParse(trimmedHost);
    if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
      return _ParsedWebDavEndpoint(
        host: trimmedHost,
        remotePath: trimmedPath,
        secure: secure,
        port: explicitPort,
      );
    }

    final normalizedPath = trimmedPath.isNotEmpty
        ? trimmedPath
        : (uri.path.isEmpty ? '/' : uri.path);
    return _ParsedWebDavEndpoint(
      host: uri.host,
      remotePath: normalizedPath,
      secure: uri.scheme == 'https',
      port: explicitPort ?? (uri.hasPort ? uri.port : null),
    );
  }

  final split = _splitHostAndPort(trimmedHost);
  return _ParsedWebDavEndpoint(
    host: split.host,
    remotePath: trimmedPath,
    secure: secure,
    port: explicitPort ?? split.port,
  );
}

({String host, int? port}) _splitHostAndPort(String input) {
  final trimmed = input.trim();
  final lastColon = trimmed.lastIndexOf(':');
  if (lastColon <= 0 || lastColon == trimmed.length - 1) {
    return (host: trimmed, port: null);
  }

  final host = trimmed.substring(0, lastColon);
  final port = int.tryParse(trimmed.substring(lastColon + 1));
  if (port == null) {
    return (host: trimmed, port: null);
  }

  return (host: host, port: port);
}
