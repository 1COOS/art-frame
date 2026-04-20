import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/media_source.dart';

const _networkSourceSecretsStorageKey = 'network_source_secrets';

class NetworkSourceSecretsStore {
  const NetworkSourceSecretsStore();

  Future<void> save(MediaSource source) async {
    final config = source.networkConfig;
    if (source.kind != MediaSourceKind.network || config == null) {
      return;
    }

    final password = config.password;
    if (password == null || password.isEmpty) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final current = _decode(prefs.getString(_networkSourceSecretsStorageKey));
    current[config.stableId] = password;
    await prefs.setString(_networkSourceSecretsStorageKey, jsonEncode(current));
  }

  Future<void> remove(MediaSource source) async {
    final config = source.networkConfig;
    if (source.kind != MediaSourceKind.network || config == null) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final current = _decode(prefs.getString(_networkSourceSecretsStorageKey));
    current.remove(config.stableId);
    await prefs.setString(_networkSourceSecretsStorageKey, jsonEncode(current));
  }

  Future<List<MediaSource>> attachSecrets(List<MediaSource> sources) async {
    final prefs = await SharedPreferences.getInstance();
    final current = _decode(prefs.getString(_networkSourceSecretsStorageKey));

    return sources.map((source) {
      final config = source.networkConfig;
      if (source.kind != MediaSourceKind.network || config == null) {
        return source;
      }

      final password = current[config.stableId];
      if (password == null || password.isEmpty) {
        return source;
      }

      return source.copyWith(networkConfig: config.copyWith(password: password));
    }).toList(growable: false);
  }

  Map<String, String> _decode(String? raw) {
    if (raw == null || raw.isEmpty) {
      return <String, String>{};
    }

    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map(
      (key, value) => MapEntry(key, value as String),
    );
  }
}

final networkSourceSecretsStoreProvider = Provider<NetworkSourceSecretsStore>((
  ref,
) {
  return const NetworkSourceSecretsStore();
});
