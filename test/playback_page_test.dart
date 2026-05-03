import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:art_frame/app/l10n/generated/app_localizations.dart';
import 'package:art_frame/features/playback/presentation/playback_page.dart';
import 'package:art_frame/features/settings/application/playback_settings_controller.dart';
import 'package:art_frame/features/settings/domain/playback_settings.dart';
import 'package:art_frame/features/sources/application/selected_source_controller.dart';
import 'package:art_frame/features/sources/domain/media_item.dart';
import 'package:art_frame/features/sources/domain/media_source.dart';
import 'package:art_frame/features/sources/domain/network_source_config.dart';

void main() {
  testWidgets('播放页首次挂载不会过早访问 inherited widgets', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    const source = MediaSource(
      id: 'network-webdav-demo',
      title: 'WebDAV Demo',
      description: 'demo source',
      badge: 'Network source',
      kind: MediaSourceKind.network,
      networkConfig: NetworkSourceConfig(
        protocol: NetworkSourceProtocol.webdav,
        host: 'demo.local',
        remotePath: '/gallery',
        secure: true,
        displayName: 'WebDAV Demo',
      ),
      items: [
        MediaItem(
          id: 'remote-1',
          title: 'frame-1.jpg',
          path: 'https://demo.local/gallery/frame-1.jpg',
          description: '/gallery/frame-1.jpg',
          kind: MediaItemKind.remote,
        ),
        MediaItem(
          id: 'remote-2',
          title: 'frame-2.jpg',
          path: 'https://demo.local/gallery/frame-2.jpg',
          description: '/gallery/frame-2.jpg',
          kind: MediaItemKind.remote,
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          selectedSourceProvider.overrideWith((ref) => source),
          playbackSettingsControllerProvider.overrideWith(
            () => _TestPlaybackSettingsController(),
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: PlaybackPage(),
        ),
      ),
    );

    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byType(PlaybackPage), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
  });
}

class _TestPlaybackSettingsController extends PlaybackSettingsController {
  @override
  Future<PlaybackSettings> build() async {
    return const PlaybackSettings(autoplay: false, intervalSeconds: 5);
  }
}
