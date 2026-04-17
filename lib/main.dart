import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/bootstrap/app.dart';
import 'app/bootstrap/bootstrap.dart';

Future<void> main() async {
  await bootstrap(
    const ProviderScope(
      child: ArtFrameBootstrapApp(),
    ),
  );
}
