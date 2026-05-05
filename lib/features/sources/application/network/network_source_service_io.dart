import 'package:flutter/material.dart';

import '../../domain/network_source_config.dart';
import 'network_directory_browser.dart';
import '../../domain/network_source_result.dart';
import 'smb_client.dart';
import 'webdav_client.dart';

const bool isSupported = true;

Future<void> testConnection(NetworkSourceConfig config) async {
  switch (config.protocol) {
    case NetworkSourceProtocol.smb:
      final client = SmbClient();
      await client.validate(config);
    case NetworkSourceProtocol.webdav:
      final client = WebDavClient();
      await client.validate(config);
    case NetworkSourceProtocol.sftp:
      throw Exception('SFTP is not yet supported');
  }
}

Future<NetworkSourceDraft?> validateAndBrowse(
  BuildContext context, {
  required NetworkSourceConfig config,
  required String title,
  required String badge,
}) async {
  switch (config.protocol) {
    case NetworkSourceProtocol.smb:
      final client = SmbClient();
      await client.validate(config);
      if (!context.mounted) return null;
      return showSmbDirectoryBrowser(
        context,
        client: client,
        initialConfig: config,
        title: title,
        badge: badge,
      );
    case NetworkSourceProtocol.webdav:
      final client = WebDavClient();
      await client.validate(config);
      if (!context.mounted) return null;
      return showWebDavDirectoryBrowser(
        context,
        client: client,
        initialConfig: config,
        title: title,
        badge: badge,
      );
    case NetworkSourceProtocol.sftp:
      throw Exception('SFTP is not yet supported');
  }
}
