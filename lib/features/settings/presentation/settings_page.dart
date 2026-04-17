import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../core/providers/locale_controller.dart';
import '../application/playback_settings.dart';
import '../application/playback_settings_controller.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final currentLocale = ref.watch(localeControllerProvider);
    final settings =
        ref.watch(playbackSettingsControllerProvider).asData?.value ??
        const PlaybackSettings.defaults();

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          l10n.settingsTitle,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 12),
        Text(
          l10n.settingsBody,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.languageLabel,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
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
                const SizedBox(height: 24),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.autoplayLabel),
                  value: settings.autoplay,
                  onChanged: (value) {
                    ref
                        .read(playbackSettingsControllerProvider.notifier)
                        .setAutoplay(value);
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  '${l10n.intervalLabel}: ${settings.intervalSeconds}${l10n.secondsUnit}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Slider(
                  value: settings.intervalSeconds.toDouble(),
                  min: 2,
                  max: 10,
                  divisions: 4,
                  label: '${settings.intervalSeconds}${l10n.secondsUnit}',
                  onChanged: (value) {
                    ref
                        .read(playbackSettingsControllerProvider.notifier)
                        .setIntervalSeconds(value.round());
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
