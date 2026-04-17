import 'package:flutter/widgets.dart';

import 'app_breakpoints.dart';

class AdaptiveLayout extends StatelessWidget {
  const AdaptiveLayout({
    super.key,
    required this.builder,
  });

  final Widget Function(BuildContext context, AdaptiveWindowType type) builder;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final type = adaptiveWindowTypeForWidth(width);
    return builder(context, type);
  }
}
