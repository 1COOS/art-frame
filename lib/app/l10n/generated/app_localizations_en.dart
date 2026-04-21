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
  String get sourcesTitle => 'Sources';

  @override
  String get sourcesBody =>
      'Manage bundled, local file, local directory, media library, and network sources for playback.';

  @override
  String get playbackTitle => 'Playback';

  @override
  String get playbackBody =>
      'The selected source rotates automatically and can be manually browsed.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsBody =>
      'Manage language, appearance, playback behavior, and key app information from one place.';

  @override
  String get settingsGeneralTitle => 'General';

  @override
  String get settingsGeneralBody =>
      'Choose the app language and theme mode used across the entire experience.';

  @override
  String get settingsPlaybackTitle => 'Playback';

  @override
  String get settingsPlaybackBody =>
      'Adjust autoplay behavior and image rotation timing for the current viewing loop.';

  @override
  String get settingsAboutTitle => 'About';

  @override
  String get settingsAboutBody =>
      'Check the installed version and open the main project, privacy, and feedback entry points.';

  @override
  String get themeModeLabel => 'Theme mode';

  @override
  String get themeModeSystem => 'System';

  @override
  String get themeModeLight => 'Light';

  @override
  String get themeModeDark => 'Dark';

  @override
  String get appVersionLabel => 'Version';

  @override
  String get settingsRepositoryLink => 'Project repository';

  @override
  String get settingsPrivacyPolicyLink => 'Privacy policy';

  @override
  String get settingsFeedbackLink => 'Feedback';

  @override
  String get settingsLinkOpenFailed => 'Could not open the link right now.';

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
  String get addLocalDirectorySource => 'Add local directory';

  @override
  String get addMediaLibrarySource => 'Add media library';

  @override
  String get addNetworkSource => 'Add network source';

  @override
  String get localFilesSourceTitle => 'Local files';

  @override
  String get localFilesSourceDescription =>
      'Images picked from this device and stored as a reusable local source.';

  @override
  String get localFilesSourceBadge => 'Local files';

  @override
  String get localDirectorySourceBadge => 'Local directory';

  @override
  String get mediaLibrarySourceTitle => 'Media library';

  @override
  String get mediaLibrarySourceDescription =>
      'Images selected from the system photo library and stored as a reusable local source.';

  @override
  String get mediaLibrarySourceBadge => 'Media library';

  @override
  String get networkSourceTitle => 'Network source';

  @override
  String get networkSourceDescription =>
      'A reusable placeholder source backed by a remote protocol configuration.';

  @override
  String get networkSourceBadge => 'Network source';

  @override
  String get networkSourceUnavailable =>
      'Network source import is not available on this platform';

  @override
  String get removeSource => 'Remove';

  @override
  String get editSource => 'Edit';

  @override
  String sourceSummaryReady(int count) {
    return '$count items ready';
  }

  @override
  String playbackCounter(int current, int total) {
    return '$current / $total';
  }

  @override
  String networkSourceUpdated(int count) {
    return 'Updated network source with $count images';
  }

  @override
  String localFilesImported(int count) {
    return 'Imported $count local files';
  }

  @override
  String localDirectoryImported(int count) {
    return 'Imported $count images from the directory';
  }

  @override
  String mediaLibraryImported(int count) {
    return 'Imported $count images from the media library';
  }

  @override
  String networkSourceImported(int count) {
    return 'Imported $count images from the network source';
  }

  @override
  String get mediaLibraryPermissionDenied =>
      'Media library access was not granted';

  @override
  String get mediaLibraryUnavailable =>
      'Media library import is not available on this platform';
}
