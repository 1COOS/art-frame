import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('WebDAV 目录弹窗在有图片预览时不会溢出', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: _TestDialogBody(),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('选择 WebDAV 目录'), findsOneWidget);
    expect(find.byType(ListTile), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}

class _TestDialogBody extends StatelessWidget {
  const _TestDialogBody();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () {
          showDialog<void>(
            context: context,
            builder: (dialogContext) {
              return Dialog(
                insetPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 480,
                    maxHeight: 520,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '选择 WebDAV 目录',
                          style: Theme.of(dialogContext).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        const Text('/photo/奶奶'),
                        const SizedBox(height: 8),
                        const Text('当前目录包含 20 张图片'),
                        const SizedBox(height: 8),
                        const Text(
                          'IMG_0001.jpg\nIMG_0002.jpg\nIMG_0003.jpg',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: const [
                            Spacer(),
                            Text('子文件夹 8 个'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: ListView.builder(
                            itemCount: 8,
                            itemBuilder: (context, index) {
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.folder_outlined),
                                title: Text('目录 $index'),
                                subtitle: Text(
                                  '/photo/奶奶/目录$index',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.of(dialogContext).pop(),
                              child: const Text('返回配置'),
                            ),
                            const SizedBox(width: 8),
                            FilledButton(
                              onPressed: () {},
                              child: const Text('导入当前目录'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        child: const Text('open'),
      ),
    );
  }
}
