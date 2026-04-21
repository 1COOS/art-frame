import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

@immutable
class AppearanceSettings {
  const AppearanceSettings({
    required this.themeMode,
    required this.orientationPreference,
  });

  const AppearanceSettings.defaults()
    : themeMode = ThemeMode.system,
      orientationPreference = AppOrientationPreference.system;

  factory AppearanceSettings.fromJson(Map<String, Object?> json) {
    return AppearanceSettings(
      themeMode: themeModeFromName(json['themeMode'] as String?),
      orientationPreference: orientationPreferenceFromName(
        json['orientationPreference'] as String?,
      ),
    );
  }

  final ThemeMode themeMode;
  final AppOrientationPreference orientationPreference;

  AppearanceSettings copyWith({
    ThemeMode? themeMode,
    AppOrientationPreference? orientationPreference,
  }) {
    return AppearanceSettings(
      themeMode: themeMode ?? this.themeMode,
      orientationPreference:
          orientationPreference ?? this.orientationPreference,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'themeMode': themeMode.name,
      'orientationPreference': orientationPreference.name,
    };
  }
}

enum AppOrientationPreference { system, portrait, landscape }

ThemeMode themeModeFromName(String? value) {
  return switch (value) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };
}

AppOrientationPreference orientationPreferenceFromName(String? value) {
  return switch (value) {
    'portrait' => AppOrientationPreference.portrait,
    'landscape' => AppOrientationPreference.landscape,
    _ => AppOrientationPreference.system,
  };
}

Future<void> applyOrientationPreference(
  AppOrientationPreference preference,
) async {
  if (kIsWeb) {
    return;
  }

  final platform = defaultTargetPlatform;
  if (platform != TargetPlatform.android && platform != TargetPlatform.iOS) {
    return;
  }

  final orientations = switch (preference) {
    AppOrientationPreference.system => <DeviceOrientation>[],
    AppOrientationPreference.portrait => <DeviceOrientation>[
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ],
    AppOrientationPreference.landscape => <DeviceOrientation>[
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ],
  };

  await SystemChrome.setPreferredOrientations(orientations);
}
