import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:art_frame/app/bootstrap/app.dart';
import 'package:art_frame/features/settings/application/settings_about.dart';

void main() {
  testWidgets('启动最小图源与设置中心闭环', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          externalLinkOpenerProvider.overrideWithValue((_) async => true),
        ],
        child: const ArtFrameBootstrapApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sources'), findsWidgets);
    expect(find.text('Add local files'), findsOneWidget);
    expect(find.text('Add local directory'), findsOneWidget);
    expect(find.text('Add media library'), findsOneWidget);
    expect(find.text('Add network source'), findsOneWidget);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsWidgets);
    expect(find.text('General'), findsOneWidget);
    expect(find.text('System'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Project repository'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Playback'), findsOneWidget);
    expect(find.text('About'), findsOneWidget);
    expect(find.text('Project repository'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Chinese'),
      -300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chinese'));
    await tester.pumpAndSettle();

    expect(find.text('图源'), findsWidgets);
    expect(find.text('通用'), findsOneWidget);
    expect(find.text('跟随系统'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('项目仓库'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('播放'), findsOneWidget);
    expect(find.text('关于'), findsOneWidget);
    expect(find.text('项目仓库'), findsOneWidget);

    await tester.tap(find.text('图源').first);
    await tester.pumpAndSettle();

    expect(find.text('添加本地文件'), findsOneWidget);
    expect(find.text('添加本地目录'), findsOneWidget);
    expect(find.text('添加媒体库'), findsOneWidget);
    expect(find.text('添加网络图源'), findsOneWidget);

    final openPlaybackButton = find.widgetWithText(FilledButton, '打开播放');
    await tester.ensureVisible(openPlaybackButton.first);
    await tester.pumpAndSettle();
    await tester.tap(openPlaybackButton.first);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) => widget is Text && (widget.data?.contains('/') ?? false),
      ),
      findsWidgets,
    );
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.byType(NavigationRail), findsNothing);
    expect(find.text('设置中心'), findsNothing);
  });
}
