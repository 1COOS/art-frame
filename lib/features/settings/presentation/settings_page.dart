import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../core/providers/locale_controller.dart';
import '../../../core/widgets/foundation_page_scaffold.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final currentLocale = ref.watch(localeControllerProvider);

    return FoundationPageScaffold(
      title: l10n.settingsTitle,
      description: l10n.settingsBody,
      footer: SegmentedButton<Locale>(
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
          ref.read(localeControllerProvider.notifier).update(selection.first);
        },
      ),
    );
  }
}
