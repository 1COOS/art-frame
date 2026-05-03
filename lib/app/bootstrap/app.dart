import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/locale_controller.dart';
import '../../features/settings/domain/appearance_settings.dart';
import '../../features/settings/application/appearance_settings_controller.dart';
import '../l10n/generated/app_localizations.dart';
import '../router/app_router.dart';
import '../theme/app_theme.dart';

class ArtFrameBootstrapApp extends ConsumerStatefulWidget {
  const ArtFrameBootstrapApp({super.key});

  @override
  ConsumerState<ArtFrameBootstrapApp> createState() =>
      _ArtFrameBootstrapAppState();
}

class _ArtFrameBootstrapAppState extends ConsumerState<ArtFrameBootstrapApp> {
  AppOrientationPreference? _lastAppliedOrientation;

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(localeControllerProvider);
    final appearanceSettings =
        ref.watch(appearanceSettingsControllerProvider).asData?.value ??
        const AppearanceSettings.defaults();

    _syncOrientationPreference(appearanceSettings.orientationPreference);

    return MaterialApp.router(
      title: 'Art Frame',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: appearanceSettings.themeMode,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    );
  }

  void _syncOrientationPreference(
    AppOrientationPreference preference,
  ) {
    if (_lastAppliedOrientation == preference) {
      return;
    }
    _lastAppliedOrientation = preference;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      applyOrientationPreference(preference);
    });
  }
}
