import 'package:flutter/material.dart';

@immutable
class AppearanceSettings {
  const AppearanceSettings({required this.themeMode});

  const AppearanceSettings.defaults() : themeMode = ThemeMode.system;

  factory AppearanceSettings.fromJson(Map<String, Object?> json) {
    return AppearanceSettings(
      themeMode: themeModeFromName(json['themeMode'] as String?),
    );
  }

  final ThemeMode themeMode;

  AppearanceSettings copyWith({ThemeMode? themeMode}) {
    return AppearanceSettings(themeMode: themeMode ?? this.themeMode);
  }

  Map<String, Object?> toJson() {
    return {'themeMode': themeMode.name};
  }
}

ThemeMode themeModeFromName(String? value) {
  return switch (value) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };
}
