class AppBreakpoints {
  static const double tablet = 600;
  static const double wide = 1024;
}

enum AdaptiveWindowType { phone, tablet, wide }

AdaptiveWindowType adaptiveWindowTypeForWidth(double width) {
  if (width >= AppBreakpoints.wide) {
    return AdaptiveWindowType.wide;
  }
  if (width >= AppBreakpoints.tablet) {
    return AdaptiveWindowType.tablet;
  }
  return AdaptiveWindowType.phone;
}

extension AdaptiveWindowTypeX on AdaptiveWindowType {
  bool get usesBottomNavigation => this == AdaptiveWindowType.phone;
  bool get usesRail => this == AdaptiveWindowType.tablet;
  bool get usesSidebar => this == AdaptiveWindowType.wide;
}
