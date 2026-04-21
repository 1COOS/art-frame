import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/locale_controller.dart';
import '../../features/settings/application/appearance_settings.dart';
import '../../features/settings/application/appearance_settings_controller.dart';
import '../l10n/generated/app_localizations.dart';
import '../router/app_router.dart';
import '../theme/app_theme.dart';

class ArtFrameBootstrapApp extends ConsumerWidget {
  const ArtFrameBootstrapApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(localeControllerProvider);
    final appearanceSettings =
        ref.watch(appearanceSettingsControllerProvider).asData?.value ??
        const AppearanceSettings.defaults();

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
}
