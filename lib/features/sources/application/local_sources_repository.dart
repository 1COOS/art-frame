import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/media_source.dart';

const _localSourcesStorageKey = 'local_media_sources';

class LocalSourcesRepository {
  const LocalSourcesRepository();

  Future<List<MediaSource>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final payload = prefs.getStringList(_localSourcesStorageKey) ?? const [];

    return payload
        .map(
          (entry) => MediaSource.fromJson(
            Map<String, Object?>.from(jsonDecode(entry) as Map),
          ),
        )
        .toList(growable: false);
  }

  Future<void> save(List<MediaSource> sources) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = sources
        .map((source) => jsonEncode(source.toJson()))
        .toList(growable: false);
    await prefs.setStringList(_localSourcesStorageKey, payload);
  }
}

final localSourcesRepositoryProvider = Provider<LocalSourcesRepository>((ref) {
  return const LocalSourcesRepository();
});
