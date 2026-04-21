import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

final settingsAboutInfoProvider = FutureProvider<SettingsAboutInfo>((ref) async {
  final packageInfo = await PackageInfo.fromPlatform();

  return SettingsAboutInfo(
    versionLabel: '${packageInfo.version} (${packageInfo.buildNumber})',
  );
});

typedef ExternalLinkOpener = Future<bool> Function(Uri uri);

final externalLinkOpenerProvider = Provider<ExternalLinkOpener>((ref) {
  return (uri) => launchUrl(uri, mode: LaunchMode.externalApplication);
});

class SettingsAboutInfo {
  const SettingsAboutInfo({required this.versionLabel});

  final String versionLabel;

  static final Uri repositoryUri = Uri.parse('https://github.com/1COOS/art-frame');
  static final Uri privacyPolicyUri = Uri.parse(
    'https://github.com/1COOS/art-frame',
  );
  static final Uri feedbackUri = Uri.parse('https://github.com/1COOS/art-frame/issues');
}
