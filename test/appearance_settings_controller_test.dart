import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:art_frame/features/settings/application/appearance_settings_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('主题模式偏好会持久化并恢复', () async {
    SharedPreferences.setMockInitialValues({
      'appearance_theme_mode': 'dark',
    });

    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      (await container.read(appearanceSettingsControllerProvider.future))
          .themeMode,
      ThemeMode.dark,
    );

    await container
        .read(appearanceSettingsControllerProvider.notifier)
        .setThemeMode(ThemeMode.light);

    expect(
      container.read(appearanceSettingsControllerProvider).asData?.value.themeMode,
      ThemeMode.light,
    );

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('appearance_theme_mode'), 'light');
  });
}
