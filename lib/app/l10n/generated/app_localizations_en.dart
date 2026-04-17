// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Art Frame';

  @override
  String get shellHeadline => 'Multi-platform foundation ready';

  @override
  String get shellDescription =>
      'This baseline validates routing, adaptive layout, and localization before business features are added.';

  @override
  String get homeTab => 'Home';

  @override
  String get galleryTab => 'Gallery';

  @override
  String get settingsTab => 'Settings';

  @override
  String get currentRouteLabel => 'Current route';

  @override
  String get currentDeviceLabel => 'Current layout';

  @override
  String get languageLabel => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChinese => 'Chinese';

  @override
  String get homeTitle => 'Foundation home';

  @override
  String get homeBody =>
      'Use this shell to verify startup, top-level navigation, and locale changes.';

  @override
  String get galleryTitle => 'Adaptive gallery';

  @override
  String get galleryBody =>
      'Resize the window to confirm phone, tablet, and wide layouts share the same destinations.';

  @override
  String get settingsTitle => 'Foundation settings';

  @override
  String get settingsBody =>
      'Runtime locale switching is managed at the app layer with Riverpod.';

  @override
  String get phoneLayout => 'Phone';

  @override
  String get tabletLayout => 'Tablet';

  @override
  String get wideLayout => 'Wide';

  @override
  String get routeHome => '/home';

  @override
  String get routeGallery => '/gallery';

  @override
  String get routeSettings => '/settings';
}
