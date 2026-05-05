import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/theme/app_motion.dart';
import '../../sources/application/network/network_endpoint_parser.dart';
import '../../sources/application/network/network_source_service.dart';
import '../../sources/application/network/smb_client.dart';
import '../../sources/application/network/webdav_client.dart';
import '../../sources/domain/network_source_config.dart';
import '../../sources/domain/network_source_result.dart';

class NetworkConfigPageArgs {
  const NetworkConfigPageArgs({
    required this.title,
    required this.description,
    required this.badge,
    this.initialDraft,
  });

  final String title;
  final String description;
  final String badge;
  final NetworkSourceDraft? initialDraft;
}

class NetworkConfigPage extends ConsumerStatefulWidget {
  const NetworkConfigPage({super.key, this.args});

  final NetworkConfigPageArgs? args;

  @override
  ConsumerState<NetworkConfigPage> createState() => _NetworkConfigPageState();
}

class _NetworkConfigPageState extends ConsumerState<NetworkConfigPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _hostController;
  late final TextEditingController _portController;
  late final TextEditingController _pathController;
  late final TextEditingController _userController;
  late final TextEditingController _passwordController;
  late final TextEditingController _domainController;

  var _protocol = NetworkSourceProtocol.smb;
  var _secure = false;
  var _testing = false;
  var _saving = false;
  var _obscurePassword = true;
  String? _errorText;
  bool _testSuccess = false;

  bool get _isEditing => widget.args?.initialDraft != null;
  bool get _busy => _testing || _saving;

  @override
  void initState() {
    super.initState();
    final config = widget.args?.initialDraft?.config;
    _protocol = config?.protocol ?? NetworkSourceProtocol.smb;
    _secure = config?.secure ?? false;
    _titleController = TextEditingController(
      text: widget.args?.initialDraft?.title ?? widget.args?.title ?? '',
    );
    _hostController = TextEditingController(text: config?.host ?? '');
    _portController = TextEditingController(
      text: config?.port?.toString() ?? (_protocol == NetworkSourceProtocol.smb ? '445' : (_secure ? '443' : '80')),
    );
    _pathController = TextEditingController(text: config?.remotePath ?? '');
    _userController = TextEditingController(text: config?.username ?? '');
    _passwordController = TextEditingController(text: config?.password ?? '');
    _domainController = TextEditingController(text: config?.domain ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _hostController.dispose();
    _portController.dispose();
    _pathController.dispose();
    _userController.dispose();
    _passwordController.dispose();
    _domainController.dispose();
    super.dispose();
  }

  NetworkSourceConfig _buildConfig(AppLocalizations l10n) {
    final resolvedTitle = _titleController.text.trim().isEmpty
        ? (widget.args?.title ?? '')
        : _titleController.text.trim();
    final trimmedUsername = _userController.text.trim();
    final trimmedDomain = _domainController.text.trim();

    return switch (_protocol) {
      NetworkSourceProtocol.webdav => () {
          final parsed = parseWebDavEndpoint(
            hostInput: _hostController.text,
            portInput: _portController.text,
            pathInput: _pathController.text,
            secure: _secure,
          );
          return NetworkSourceConfig(
            protocol: NetworkSourceProtocol.webdav,
            host: parsed.host,
            remotePath: parsed.remotePath,
            username: trimmedUsername.isEmpty ? null : trimmedUsername,
            password: _passwordController.text,
            secure: parsed.secure,
            port: parsed.port,
            displayName: resolvedTitle,
          );
        }(),
      NetworkSourceProtocol.smb => () {
          final parsed = parseSmbEndpoint(
            hostInput: _hostController.text,
            portInput: _portController.text,
            pathInput: _pathController.text,
          );
          return NetworkSourceConfig(
            protocol: NetworkSourceProtocol.smb,
            host: parsed.host,
            remotePath: parsed.remotePath,
            username: trimmedUsername.isEmpty ? null : trimmedUsername,
            password: _passwordController.text,
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
  }

  String? _validateConfig(NetworkSourceConfig config, AppLocalizations l10n) {
    if (config.host.isEmpty || config.remotePath.isEmpty) {
      return switch (_protocol) {
        NetworkSourceProtocol.webdav => l10n.networkConfigErrorIncompleteWebDav,
        NetworkSourceProtocol.smb => l10n.networkConfigErrorIncompleteSmb,
        NetworkSourceProtocol.sftp => l10n.networkConfigErrorUnsupportedSftp,
      };
    }
    return null;
  }
  Future<void> _testConnection() async {
    final l10n = AppLocalizations.of(context);
    final config = _buildConfig(l10n);
    final error = _validateConfig(config, l10n);
    if (error != null) {
      setState(() {
        _errorText = error;
        _testSuccess = false;
      });
      return;
    }

    setState(() {
      _testing = true;
      _errorText = null;
      _testSuccess = false;
    });

    try {
      await ref.read(networkSourceServiceProvider).testConnection(config);
      if (!mounted) return;
      setState(() {
        _testing = false;
        _testSuccess = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.networkConfigTestSuccess)),
      );
    } on SmbException catch (e) {
      if (!mounted) return;
      setState(() {
        _testing = false;
        _errorText = e.message;
      });
    } on WebDavException catch (e) {
      if (!mounted) return;
      setState(() {
        _testing = false;
        _errorText = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _testing = false;
        _errorText = switch (_protocol) {
          NetworkSourceProtocol.smb => unexpectedSmbMessage(
              e,
              fallback: l10n.networkConfigErrorValidationSmb,
            ),
          NetworkSourceProtocol.webdav => unexpectedWebDavMessage(
              e,
              fallback: l10n.networkConfigErrorValidationWebDav,
            ),
          NetworkSourceProtocol.sftp => l10n.networkConfigErrorUnsupportedSftp,
        };
      });
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final config = _buildConfig(l10n);
    final error = _validateConfig(config, l10n);
    if (error != null) {
      setState(() {
        _errorText = error;
        _testSuccess = false;
      });
      return;
    }

    setState(() {
      _saving = true;
      _errorText = null;
      _testSuccess = false;
    });

    try {
      final draft = await ref
          .read(networkSourceServiceProvider)
          .validateAndBrowse(
            context,
            config: config,
            title: _titleController.text.trim().isEmpty
                ? (widget.args?.title ?? '')
                : _titleController.text.trim(),
            badge: widget.args?.badge ?? '',
          );
      if (!mounted) return;

      if (draft != null) {
        context.pop(NetworkSourceValidationSuccess(draft));
        return;
      }
      setState(() => _saving = false);
    } on SmbException catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _errorText = e.message;
      });
    } on WebDavException catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _errorText = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _errorText = switch (_protocol) {
          NetworkSourceProtocol.smb => unexpectedSmbMessage(
              e,
              fallback: l10n.networkConfigErrorValidationSmb,
            ),
          NetworkSourceProtocol.webdav => unexpectedWebDavMessage(
              e,
              fallback: l10n.networkConfigErrorValidationWebDav,
            ),
          NetworkSourceProtocol.sftp => l10n.networkConfigErrorUnsupportedSftp,
        };
      });
    }
  }

  void _onProtocolChanged(Set<NetworkSourceProtocol> selection) {
    final value = selection.first;
    setState(() {
      _protocol = value;
      _testSuccess = false;
      _errorText = null;
      if (value == NetworkSourceProtocol.smb) {
        _secure = false;
        if (_isDefaultWebDavPort(_portController.text.trim())) {
          _portController.text = '445';
        }
      } else {
        if (_portController.text.trim() == '445' ||
            _portController.text.trim().isEmpty) {
          _portController.text = _secure ? '443' : '80';
        }
      }
    });
  }

  void _onSecureChanged(bool value) {
    setState(() {
      _secure = value;
      _testSuccess = false;
      if (_isDefaultWebDavPort(_portController.text.trim())) {
        _portController.text = value ? '443' : '80';
      }
    });
  }

  bool _isDefaultWebDavPort(String port) {
    return port.isEmpty || port == '80' || port == '443';
  }

  String _resolveTitle(AppLocalizations l10n) {
    return _isEditing ? l10n.networkConfigEditTitle : l10n.networkConfigTitle;
  }
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSmb = _protocol == NetworkSourceProtocol.smb;

    return PopScope(
      canPop: !_busy,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_resolveTitle(l10n)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _busy ? null : () => context.pop(),
          ),
        ),
        body: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: SegmentedButton<NetworkSourceProtocol>(
                            segments: [
                              ButtonSegment(
                                value: NetworkSourceProtocol.smb,
                                label: const Text('SMB'),
                                icon: const Icon(Icons.dns_outlined),
                              ),
                              ButtonSegment(
                                value: NetworkSourceProtocol.webdav,
                                label: const Text('WebDAV'),
                                icon: const Icon(Icons.cloud_outlined),
                              ),
                            ],
                            selected: {_protocol},
                            onSelectionChanged:
                                _busy ? null : _onProtocolChanged,
                          ),
                        ),
                        AnimatedSize(
                          duration: AppMotion.standard,
                          curve: AppMotion.curve,
                          alignment: Alignment.topCenter,
                          child: !isSmb
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 16),
                                  child: SwitchListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(l10n.networkConfigUseHttps),
                                    value: _secure,
                                    onChanged: _busy ? null : _onSecureChanged,
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            labelText: l10n.networkConfigFieldTitle,
                          ),
                          enabled: !_busy,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _hostController,
                          decoration: InputDecoration(
                            labelText: l10n.networkConfigFieldHost,
                            hintText: isSmb
                                ? l10n.networkConfigHintHostSmb
                                : l10n.networkConfigHintHostWebDav,
                          ),
                          enabled: !_busy,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _portController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: l10n.networkConfigFieldPort,
                                  hintText: isSmb
                                      ? l10n.networkConfigHintPortSmb
                                      : l10n.networkConfigHintPortWebDav,
                                ),
                                enabled: !_busy,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                controller: _pathController,
                                decoration: InputDecoration(
                                  labelText: isSmb
                                      ? l10n.networkConfigFieldSharePath
                                      : l10n.networkConfigFieldRemotePath,
                                  hintText: isSmb
                                      ? l10n.networkConfigHintSharePath
                                      : l10n.networkConfigHintRemotePath,
                                ),
                                enabled: !_busy,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _userController,
                          decoration: InputDecoration(
                            labelText: l10n.networkConfigFieldUsername,
                          ),
                          enabled: !_busy,
                        ),
                        AnimatedSize(
                          duration: AppMotion.standard,
                          curve: AppMotion.curve,
                          alignment: Alignment.topCenter,
                          child: isSmb
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 16),
                                  child: TextField(
                                    controller: _domainController,
                                    decoration: InputDecoration(
                                      labelText: l10n.networkConfigFieldDomain,
                                    ),
                                    enabled: !_busy,
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: l10n.networkConfigFieldPassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                          ),
                          enabled: !_busy,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // --- Error banner ---
                AnimatedSwitcher(
                  duration: AppMotion.quick,
                  child: _errorText != null
                      ? Card(
                          key: ValueKey(_errorText),
                          color: colorScheme.errorContainer,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: colorScheme.onErrorContainer,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _errorText!,
                                    style: theme.textTheme.bodyMedium
                                        ?.copyWith(
                                          color: colorScheme.onErrorContainer,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 24),
                // --- Action buttons ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _busy ? null : _testConnection,
                      icon: _testing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : _testSuccess
                              ? Icon(
                                  Icons.check_circle_outline,
                                  color: colorScheme.primary,
                                )
                              : const Icon(Icons.wifi_tethering),
                      label: Text(
                        _testing
                            ? l10n.networkConfigTesting
                            : l10n.networkConfigTestConnection,
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: _busy ? null : _save,
                      icon: _saving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save_rounded),
                      label: Text(
                        _saving
                            ? l10n.networkConfigSaving
                            : l10n.networkConfigSave,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
