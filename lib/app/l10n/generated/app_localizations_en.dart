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
  String get shellHeadline => 'Showcase rewrite foundation is ready';

  @override
  String get shellDescription =>
      'This baseline now supports a bundled local source, persisted playback settings, and a minimal playback loop.';

  @override
  String get sourcesTab => 'Sources';

  @override
  String get playbackTab => 'Playback';

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
  String get sourcesTitle => 'Local bundled sources';

  @override
  String get sourcesBody =>
      'Start with bundled local images to validate source selection, persistence, and playback flow before adding device pickers.';

  @override
  String get playbackTitle => 'Playback';

  @override
  String get playbackBody =>
      'The selected source rotates automatically and can be manually browsed.';

  @override
  String get settingsTitle => 'Playback settings';

  @override
  String get settingsBody =>
      'Locale and playback interval are stored locally so the minimal loop survives restarts.';

  @override
  String get phoneLayout => 'Phone';

  @override
  String get tabletLayout => 'Tablet';

  @override
  String get wideLayout => 'Wide';

  @override
  String get routeSources => '/sources';

  @override
  String get routePlayback => '/playback';

  @override
  String get routeSettings => '/settings';

  @override
  String get selectedSourceLabel => 'Selected source';

  @override
  String get itemsCountLabel => 'Items';

  @override
  String get openPlayback => 'Open playback';

  @override
  String get selectSource => 'Select source';

  @override
  String get noSourceSelected => 'No source selected yet';

  @override
  String get chooseSourceHint =>
      'Choose a source first, then switch to playback.';

  @override
  String get autoplayLabel => 'Autoplay';

  @override
  String get intervalLabel => 'Interval';

  @override
  String get secondsUnit => 's';

  @override
  String get sourceReady => 'Ready to play';

  @override
  String get builtInSourceBadge => 'Bundled local';

  @override
  String get playbackEmptyTitle => 'Pick a source to start';

  @override
  String get playbackEmptyBody =>
      'Open the sources tab, choose a bundled local collection, then return here to preview the loop.';

  @override
  String get goToSources => 'Go to sources';

  @override
  String get nextFrame => 'Next';

  @override
  String get previousFrame => 'Previous';

  @override
  String get addLocalFilesSource => 'Add local files';

  @override
  String get localFilesSourceTitle => 'Local files';

  @override
  String get localFilesSourceDescription =>
      'Images picked from this device and stored as a reusable local source.';

  @override
  String get localFilesSourceBadge => 'Local files';

  @override
  String get removeSource => 'Remove';

  @override
  String localFilesImported(int count) {
    return 'Imported $count local files';
  }
}
