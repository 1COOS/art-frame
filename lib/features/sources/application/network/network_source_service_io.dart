import 'package:flutter/material.dart';

import '../../domain/network_source_config.dart';
import 'network_directory_browser.dart';
import 'network_endpoint_parser.dart';
import '../../domain/network_source_result.dart';
import 'smb_client.dart';
import 'webdav_client.dart';

const bool isSupported = true;

Future<NetworkSourceValidationResult> createSource(
  BuildContext context, {
  required String title,
  required String description,
  required String badge,
  NetworkSourceDraft? initialDraft,
}) async {
  final initialConfig = initialDraft?.config;
  final titleController = TextEditingController(
    text: initialDraft?.title ?? title,
  );
  final hostController = TextEditingController(
    text: initialConfig?.host ?? 'demo.local',
  );
  final portController = TextEditingController(
    text: initialConfig?.port?.toString() ?? '445',
  );
  final pathController = TextEditingController(
    text: initialConfig?.remotePath ?? '/gallery',
  );
  final userController = TextEditingController(
    text: initialConfig?.username ?? 'demo',
  );
  final passwordController = TextEditingController(
    text: initialConfig?.password ?? 'demo',
  );
  final domainController = TextEditingController(
    text: initialConfig?.domain ?? '',
  );
  var protocol = initialConfig?.protocol ?? NetworkSourceProtocol.smb;
  var secure = initialConfig?.secure ?? false;
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

            final resolvedTitle = titleController.text.trim().isEmpty
                ? title
                : titleController.text.trim();
            final trimmedUsername = userController.text.trim();
            final trimmedDomain = domainController.text.trim();

            final config = switch (protocol) {
              NetworkSourceProtocol.webdav => () {
                final parsed = parseWebDavEndpoint(
                  hostInput: hostController.text,
                  portInput: portController.text,
                  pathInput: pathController.text,
                  secure: secure,
                );
                return NetworkSourceConfig(
                  protocol: NetworkSourceProtocol.webdav,
                  host: parsed.host,
                  remotePath: parsed.remotePath,
                  username: trimmedUsername.isEmpty ? null : trimmedUsername,
                  password: passwordController.text,
                  secure: parsed.secure,
                  port: parsed.port,
                  displayName: resolvedTitle,
                );
              }(),
              NetworkSourceProtocol.smb => () {
                final parsed = parseSmbEndpoint(
                  hostInput: hostController.text,
                  portInput: portController.text,
                  pathInput: pathController.text,
                );
                return NetworkSourceConfig(
                  protocol: NetworkSourceProtocol.smb,
                  host: parsed.host,
                  remotePath: parsed.remotePath,
                  username: trimmedUsername.isEmpty ? null : trimmedUsername,
                  password: passwordController.text,
                  secure: false,
                  port: parsed.port,
                  displayName: resolvedTitle,
                  domain: trimmedDomain.isEmpty ? null : trimmedDomain,
                );
              }(),
              NetworkSourceProtocol.sftp => const NetworkSourceConfig(
                protocol: NetworkSourceProtocol.sftp,
                host: '',
                remotePath: '/',
              ),
            };

            if (config.host.isEmpty || config.remotePath.isEmpty) {
              setState(() {
                errorText = switch (protocol) {
                  NetworkSourceProtocol.webdav => 'WebDAV 配置不完整',
                  NetworkSourceProtocol.smb => 'SMB 配置不完整',
                  NetworkSourceProtocol.sftp => '暂不支持 SFTP',
                };
              });
              return;
            }

            setState(() {
              submitting = true;
              errorText = null;
            });

            try {
              if (!dialogContext.mounted) {
                return;
              }

              final openContext = dialogContext;
              if (!openContext.mounted) {
                return;
              }
              final webDavImportContext = openContext;
              final smbImportContext = openContext;
              final draft = switch (protocol) {
                NetworkSourceProtocol.webdav => await _importWebDavSource(
                  // ignore: use_build_context_synchronously
                  webDavImportContext,
                  config: config,
                  title: resolvedTitle,
                  badge: badge,
                ),
                NetworkSourceProtocol.smb => await _importSmbSource(
                  // ignore: use_build_context_synchronously
                  smbImportContext,
                  config: config,
                  title: resolvedTitle,
                  badge: badge,
                ),
                NetworkSourceProtocol.sftp => throw Exception('暂不支持 SFTP'),
              };

              if (!dialogContext.mounted) {
                return;
              }
              if (draft == null) {
                setState(() {
                  submitting = false;
                });
                return;
              }

              Navigator.of(dialogContext).pop(
                NetworkSourceValidationSuccess(draft),
              );
            } on WebDavException catch (error) {
              setState(() {
                submitting = false;
                errorText = error.message;
              });
            } on SmbException catch (error) {
              setState(() {
                submitting = false;
                errorText = error.message;
              });
            } catch (error) {
              setState(() {
                submitting = false;
                errorText = switch (protocol) {
                  NetworkSourceProtocol.webdav => unexpectedWebDavMessage(
                    error,
                    fallback: 'WebDAV 验证失败，请检查协议、地址、端口和路径',
                  ),
                  NetworkSourceProtocol.smb => unexpectedSmbMessage(
                    error,
                    fallback: 'SMB 验证失败，请检查地址、共享目录、账号和密码',
                  ),
                  NetworkSourceProtocol.sftp => '暂不支持 SFTP',
                };
              });
            }
          }

          final isWebDav = protocol == NetworkSourceProtocol.webdav;
          final isSmb = protocol == NetworkSourceProtocol.smb;

          return AlertDialog(
            title: Text(isSmb ? '添加 SMB 图源' : '添加 WebDAV 图源'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<NetworkSourceProtocol>(
                    initialValue: protocol,
                    decoration: const InputDecoration(labelText: 'Protocol'),
                    items: const [
                      DropdownMenuItem(
                        value: NetworkSourceProtocol.smb,
                        child: Text('SMB'),
                      ),
                      DropdownMenuItem(
                        value: NetworkSourceProtocol.webdav,
                        child: Text('WebDAV'),
                      ),
                    ],
                    onChanged: submitting
                        ? null
                        : (value) {
                            if (value == null) {
                              return;
                            }
                            setState(() {
                              protocol = value;
                              if (value == NetworkSourceProtocol.smb) {
                                secure = false;
                                if (portController.text.trim().isEmpty ||
                                    portController.text.trim() == '80' ||
                                    portController.text.trim() == '443') {
                                  portController.text = '445';
                                }
                              } else if (portController.text.trim().isEmpty ||
                                  portController.text.trim() == '445') {
                                portController.text = secure ? '443' : '80';
                              }
                            });
                          },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: hostController,
                    decoration: InputDecoration(
                      labelText: 'Host',
                      hintText: isSmb
                          ? '192.168.2.100 或 demo.local'
                          : '192.168.2.100、demo.local:5005 或 http://192.168.2.100:5005/gallery',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: portController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Port',
                      hintText: isSmb
                          ? '445（首版默认使用 SMB 标准端口）'
                          : '80 / 443 / 5005（可留空，自动从 Host 推断）',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: pathController,
                    decoration: InputDecoration(
                      labelText: isSmb ? 'Share path' : 'Remote path',
                      hintText: isSmb
                          ? '/public/gallery'
                          : '/gallery（可留空，自动从 Host URL 提取）',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: userController,
                    decoration: const InputDecoration(labelText: 'Username'),
                  ),
                  if (isSmb) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: domainController,
                      decoration: const InputDecoration(
                        labelText: 'Domain / Workgroup',
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                  ),
                  if (isWebDav) ...[
                    const SizedBox(height: 12),
                    SwitchListTile(
                      value: secure,
                      title: const Text('Use HTTPS'),
                      onChanged: submitting
                          ? null
                          : (value) {
                              setState(() {
                                secure = value;
                                if (portController.text.trim().isEmpty ||
                                    portController.text.trim() == '80' ||
                                    portController.text.trim() == '443') {
                                  portController.text = value ? '443' : '80';
                                }
                              });
                            },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
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

Future<NetworkSourceDraft?> _importWebDavSource(
  BuildContext context, {
  required NetworkSourceConfig config,
  required String title,
  required String badge,
}) async {
  final client = WebDavClient();
  await client.validate(config);
  if (!context.mounted) {
    return null;
  }
  return showWebDavDirectoryBrowser(
    context,
    client: client,
    initialConfig: config,
    title: title,
    badge: badge,
  );
}

Future<NetworkSourceDraft?> _importSmbSource(
  BuildContext context, {
  required NetworkSourceConfig config,
  required String title,
  required String badge,
}) async {
  final client = SmbClient();
  await client.validate(config);
  if (!context.mounted) {
    return null;
  }
  return showSmbDirectoryBrowser(
    context,
    client: client,
    initialConfig: config,
    title: title,
    badge: badge,
  );
}
