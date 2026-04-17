import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:art_frame/app/bootstrap/app.dart';

void main() {
  testWidgets('启动基础壳层并支持语言切换入口', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: ArtFrameBootstrapApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Foundation home'), findsOneWidget);
    expect(find.text('/home'), findsOneWidget);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Foundation settings'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Chinese'), findsOneWidget);

    await tester.tap(find.text('Chinese'));
    await tester.pumpAndSettle();

    expect(find.text('基础设置'), findsOneWidget);
    expect(find.text('/settings'), findsOneWidget);
  });
}
