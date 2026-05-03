import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/playback_settings.dart';

part 'playback_settings_controller.g.dart';

const _autoplayStorageKey = 'playback_autoplay';
const _intervalStorageKey = 'playback_interval_seconds';

@riverpod
class PlaybackSettingsController extends _$PlaybackSettingsController {
  @override
  Future<PlaybackSettings> build() async {
    final prefs = await SharedPreferences.getInstance();

    return PlaybackSettings(
      autoplay: prefs.getBool(_autoplayStorageKey) ?? true,
      intervalSeconds: prefs.getInt(_intervalStorageKey) ?? 5,
    );
  }

  Future<void> setAutoplay(bool value) async {
    final next = state.asData?.value.copyWith(autoplay: value) ??
        const PlaybackSettings.defaults().copyWith(autoplay: value);

    state = AsyncData(next);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoplayStorageKey, value);
  }

  Future<void> setIntervalSeconds(int value) async {
    final normalized = value.clamp(2, 10);
    final next = state.asData?.value.copyWith(intervalSeconds: normalized) ??
        const PlaybackSettings.defaults().copyWith(
          intervalSeconds: normalized,
        );

    state = AsyncData(next);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_intervalStorageKey, normalized);
  }
}
