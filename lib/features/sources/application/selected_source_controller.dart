import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/media_source.dart';
import 'local_sources_controller.dart';

part 'selected_source_controller.g.dart';

const _selectedSourceStorageKey = 'selected_source_id';

@riverpod
class SelectedSourceController extends _$SelectedSourceController {
  @override
  Future<String?> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedSourceStorageKey);
  }

  Future<void> select(String sourceId) async {
    state = AsyncData(sourceId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedSourceStorageKey, sourceId);
  }

  Future<void> clear() async {
    state = const AsyncData(null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_selectedSourceStorageKey);
  }
}

final selectedSourceProvider = Provider<MediaSource?>((ref) {
  final sources = ref.watch(allSourcesProvider);
  final selectedId = ref.watch(selectedSourceControllerProvider).asData?.value;

  if (selectedId == null) {
    return null;
  }

  for (final source in sources) {
    if (source.id == selectedId) {
      return source;
    }
  }

  return null;
});

