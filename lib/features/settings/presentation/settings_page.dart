import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../core/providers/locale_controller.dart';
import '../domain/appearance_settings.dart';
import '../application/appearance_settings_controller.dart';
import '../domain/playback_settings.dart';
import '../application/playback_settings_controller.dart';
import '../application/settings_about.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentLocale = ref.watch(localeControllerProvider);
    final playbackSettings =
        ref.watch(playbackSettingsControllerProvider).asData?.value ??
        const PlaybackSettings.defaults();
    final appearanceSettings =
        ref.watch(appearanceSettingsControllerProvider).asData?.value ??
        const AppearanceSettings.defaults();
    final aboutInfo = ref.watch(settingsAboutInfoProvider).asData?.value;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          children: [
            Text(
              l10n.settingsTitle,
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.settingsBody,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            _SettingsSection(
              title: l10n.settingsGeneralTitle,
              description: l10n.settingsGeneralBody,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.languageLabel, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  SegmentedButton<Locale>(
                    segments: [
                      ButtonSegment<Locale>(
                        value: const Locale('en'),
                        label: Text(l10n.languageEnglish),
                      ),
                      ButtonSegment<Locale>(
                        value: const Locale('zh'),
                        label: Text(l10n.languageChinese),
                      ),
                    ],
                    selected: {
                      currentLocale?.languageCode == 'zh'
                          ? const Locale('zh')
                          : const Locale('en'),
                    },
                    onSelectionChanged: (selection) {
                      ref
                          .read(localeControllerProvider.notifier)
                          .update(selection.first);
                    },
                  ),
                  const Divider(),
                  Text(l10n.themeModeLabel, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  SegmentedButton<ThemeMode>(
                    segments: [
                      ButtonSegment<ThemeMode>(
                        value: ThemeMode.system,
                        label: Text(l10n.themeModeSystem),
                        icon: const Icon(Icons.brightness_auto_rounded),
                      ),
                      ButtonSegment<ThemeMode>(
                        value: ThemeMode.light,
                        label: Text(l10n.themeModeLight),
                        icon: const Icon(Icons.light_mode_rounded),
                      ),
                      ButtonSegment<ThemeMode>(
                        value: ThemeMode.dark,
                        label: Text(l10n.themeModeDark),
                        icon: const Icon(Icons.dark_mode_rounded),
                      ),
                    ],
                    selected: {appearanceSettings.themeMode},
                    onSelectionChanged: (selection) {
                      ref
                          .read(appearanceSettingsControllerProvider.notifier)
                          .setThemeMode(selection.first);
                    },
                  ),
                  const Divider(),
                  Text(
                    l10n.orientationPreferenceLabel,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<AppOrientationPreference>(
                    segments: [
                      ButtonSegment<AppOrientationPreference>(
                        value: AppOrientationPreference.system,
                        label: Text(l10n.orientationPreferenceSystem),
                        icon: const Icon(Icons.screen_rotation_alt_rounded),
                      ),
                      ButtonSegment<AppOrientationPreference>(
                        value: AppOrientationPreference.portrait,
                        label: Text(l10n.orientationPreferencePortrait),
                        icon: const Icon(Icons.stay_current_portrait_rounded),
                      ),
                      ButtonSegment<AppOrientationPreference>(
                        value: AppOrientationPreference.landscape,
                        label: Text(l10n.orientationPreferenceLandscape),
                        icon: const Icon(Icons.stay_current_landscape_rounded),
                      ),
                    ],
                    selected: {appearanceSettings.orientationPreference},
                    onSelectionChanged: (selection) {
                      ref
                          .read(appearanceSettingsControllerProvider.notifier)
                          .setOrientationPreference(selection.first);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SettingsSection(
              title: l10n.settingsPlaybackTitle,
              description: l10n.settingsPlaybackBody,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.autoplayLabel),
                    subtitle: Text(
                      '${l10n.intervalLabel}: ${playbackSettings.intervalSeconds}${l10n.secondsUnit}',
                    ),
                    value: playbackSettings.autoplay,
                    onChanged: (value) {
                      ref
                          .read(playbackSettingsControllerProvider.notifier)
                          .setAutoplay(value);
                    },
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: playbackSettings.intervalSeconds.toDouble(),
                    min: 2,
                    max: 10,
                    divisions: 4,
                    label:
                        '${playbackSettings.intervalSeconds}${l10n.secondsUnit}',
                    onChanged: (value) {
                      ref
                          .read(playbackSettingsControllerProvider.notifier)
                          .setIntervalSeconds(value.round());
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SettingsSection(
              title: l10n.settingsAboutTitle,
              description: l10n.settingsAboutBody,
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.info_outline_rounded),
                    title: Text(l10n.appVersionLabel),
                    subtitle: Text(aboutInfo?.versionLabel ?? '...'),
                  ),
                  _AboutLinkTile(
                    icon: Icons.open_in_new_rounded,
                    title: l10n.settingsRepositoryLink,
                    onTap: () => _openExternal(
                      context,
                      ref,
                      SettingsAboutInfo.repositoryUri,
                    ),
                  ),
                  _AboutLinkTile(
                    icon: Icons.privacy_tip_outlined,
                    title: l10n.settingsPrivacyPolicyLink,
                    onTap: () => _openExternal(
                      context,
                      ref,
                      SettingsAboutInfo.privacyPolicyUri,
                    ),
                  ),
                  _AboutLinkTile(
                    icon: Icons.feedback_outlined,
                    title: l10n.settingsFeedbackLink,
                    onTap: () => _openExternal(
                      context,
                      ref,
                      SettingsAboutInfo.feedbackUri,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openExternal(
    BuildContext context,
    WidgetRef ref,
    Uri uri,
  ) async {
    final l10n = AppLocalizations.of(context);
    final open = ref.read(externalLinkOpenerProvider);
    final success = await open(uri);
    if (!context.mounted || success) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.settingsLinkOpenFailed)),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.description,
    required this.child,
  });

  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(description, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    );
  }
}

class _AboutLinkTile extends StatelessWidget {
  const _AboutLinkTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}
