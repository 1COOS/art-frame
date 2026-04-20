import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:art_frame/app/bootstrap/app.dart';

void main() {
  testWidgets('启动最小图源与播放闭环', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const ProviderScope(child: ArtFrameBootstrapApp()));
    await tester.pumpAndSettle();

    expect(find.text('Sources'), findsWidgets);
    expect(find.text('Add local files'), findsOneWidget);
    expect(find.text('Add local directory'), findsOneWidget);
    expect(find.text('Add media library'), findsOneWidget);
    expect(find.text('Add network source'), findsOneWidget);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Playback settings'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Chinese'), findsOneWidget);

    await tester.tap(find.text('Chinese'));
    await tester.pumpAndSettle();

    expect(find.text('播放设置'), findsOneWidget);

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
    expect(find.text('设置'), findsNothing);
    expect(find.text('播放设置'), findsNothing);
  });
}
