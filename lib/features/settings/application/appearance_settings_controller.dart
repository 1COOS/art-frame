import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'appearance_settings.dart';

part 'appearance_settings_controller.g.dart';

const _themeModeStorageKey = 'appearance_theme_mode';

@riverpod
class AppearanceSettingsController extends _$AppearanceSettingsController {
  @override
  Future<AppearanceSettings> build() async {
    final prefs = await SharedPreferences.getInstance();

    return AppearanceSettings(
      themeMode: themeModeFromName(prefs.getString(_themeModeStorageKey)),
    );
  }

  Future<void> setThemeMode(ThemeMode value) async {
    final next = state.asData?.value.copyWith(themeMode: value) ??
        const AppearanceSettings.defaults().copyWith(themeMode: value);

    state = AsyncData(next);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeStorageKey, value.name);
  }
}
