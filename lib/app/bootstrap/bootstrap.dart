import 'package:flutter/widgets.dart';

Future<void> bootstrap(Widget app) async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(app);
}
