import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Art Frame'**
  String get appTitle;

  /// No description provided for @shellHeadline.
  ///
  /// In en, this message translates to:
  /// **'Showcase rewrite foundation is ready'**
  String get shellHeadline;

  /// No description provided for @shellDescription.
  ///
  /// In en, this message translates to:
  /// **'This baseline now supports a bundled local source, persisted playback settings, and a minimal playback loop.'**
  String get shellDescription;

  /// No description provided for @sourcesTab.
  ///
  /// In en, this message translates to:
  /// **'Sources'**
  String get sourcesTab;

  /// No description provided for @libraryTab.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get libraryTab;

  /// No description provided for @connectTab.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connectTab;

  /// No description provided for @playbackTab.
  ///
  /// In en, this message translates to:
  /// **'Playback'**
  String get playbackTab;

  /// No description provided for @settingsTab.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTab;

  /// No description provided for @currentRouteLabel.
  ///
  /// In en, this message translates to:
  /// **'Current route'**
  String get currentRouteLabel;

  /// No description provided for @currentDeviceLabel.
  ///
  /// In en, this message translates to:
  /// **'Current layout'**
  String get currentDeviceLabel;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageChinese.
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get languageChinese;

  /// No description provided for @sourcesTitle.
  ///
  /// In en, this message translates to:
  /// **'Sources'**
  String get sourcesTitle;

  /// No description provided for @libraryTitle.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get libraryTitle;

  /// No description provided for @connectTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connectTitle;

  /// No description provided for @connectBody.
  ///
  /// In en, this message translates to:
  /// **'Add new sources from local files, directories, media library, or network.'**
  String get connectBody;

  /// No description provided for @sourcesBody.
  ///
  /// In en, this message translates to:
  /// **'Manage bundled, local file, local directory, media library, and network sources for playback.'**
  String get sourcesBody;

  /// No description provided for @playbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Playback'**
  String get playbackTitle;

  /// No description provided for @playbackBody.
  ///
  /// In en, this message translates to:
  /// **'The selected source rotates automatically and can be manually browsed.'**
  String get playbackBody;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsBody.
  ///
  /// In en, this message translates to:
  /// **'Manage language, appearance, playback behavior, and key app information from one place.'**
  String get settingsBody;

  /// No description provided for @settingsGeneralTitle.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settingsGeneralTitle;

  /// No description provided for @settingsGeneralBody.
  ///
  /// In en, this message translates to:
  /// **'Choose the app language, theme mode, and screen orientation used across the entire experience.'**
  String get settingsGeneralBody;

  /// No description provided for @settingsPlaybackTitle.
  ///
  /// In en, this message translates to:
  /// **'Playback'**
  String get settingsPlaybackTitle;

  /// No description provided for @settingsPlaybackBody.
  ///
  /// In en, this message translates to:
  /// **'Adjust autoplay behavior and image rotation timing for the current viewing loop.'**
  String get settingsPlaybackBody;

  /// No description provided for @settingsAboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAboutTitle;

  /// No description provided for @settingsAboutBody.
  ///
  /// In en, this message translates to:
  /// **'Check the installed version and open the main project, privacy, and feedback entry points.'**
  String get settingsAboutBody;

  /// No description provided for @themeModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Theme mode'**
  String get themeModeLabel;

  /// No description provided for @themeModeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeModeSystem;

  /// No description provided for @themeModeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeModeLight;

  /// No description provided for @themeModeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeModeDark;

  /// No description provided for @orientationPreferenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Screen orientation'**
  String get orientationPreferenceLabel;

  /// No description provided for @orientationPreferenceSystem.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get orientationPreferenceSystem;

  /// No description provided for @orientationPreferencePortrait.
  ///
  /// In en, this message translates to:
  /// **'Portrait'**
  String get orientationPreferencePortrait;

  /// No description provided for @orientationPreferenceLandscape.
  ///
  /// In en, this message translates to:
  /// **'Landscape'**
  String get orientationPreferenceLandscape;

  /// No description provided for @appVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get appVersionLabel;

  /// No description provided for @settingsRepositoryLink.
  ///
  /// In en, this message translates to:
  /// **'Project repository'**
  String get settingsRepositoryLink;

  /// No description provided for @settingsPrivacyPolicyLink.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get settingsPrivacyPolicyLink;

  /// No description provided for @settingsFeedbackLink.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get settingsFeedbackLink;

  /// No description provided for @settingsLinkOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open the link right now.'**
  String get settingsLinkOpenFailed;

  /// No description provided for @phoneLayout.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneLayout;

  /// No description provided for @tabletLayout.
  ///
  /// In en, this message translates to:
  /// **'Tablet'**
  String get tabletLayout;

  /// No description provided for @wideLayout.
  ///
  /// In en, this message translates to:
  /// **'Wide'**
  String get wideLayout;

  /// No description provided for @routeSources.
  ///
  /// In en, this message translates to:
  /// **'/sources'**
  String get routeSources;

  /// No description provided for @routePlayback.
  ///
  /// In en, this message translates to:
  /// **'/playback'**
  String get routePlayback;

  /// No description provided for @routeSettings.
  ///
  /// In en, this message translates to:
  /// **'/settings'**
  String get routeSettings;

  /// No description provided for @selectedSourceLabel.
  ///
  /// In en, this message translates to:
  /// **'Selected source'**
  String get selectedSourceLabel;

  /// No description provided for @itemsCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get itemsCountLabel;

  /// No description provided for @openPlayback.
  ///
  /// In en, this message translates to:
  /// **'Open playback'**
  String get openPlayback;

  /// No description provided for @selectSource.
  ///
  /// In en, this message translates to:
  /// **'Select source'**
  String get selectSource;

  /// No description provided for @noSourceSelected.
  ///
  /// In en, this message translates to:
  /// **'No source selected yet'**
  String get noSourceSelected;

  /// No description provided for @chooseSourceHint.
  ///
  /// In en, this message translates to:
  /// **'Choose a source first, then switch to playback.'**
  String get chooseSourceHint;

  /// No description provided for @autoplayLabel.
  ///
  /// In en, this message translates to:
  /// **'Autoplay'**
  String get autoplayLabel;

  /// No description provided for @intervalLabel.
  ///
  /// In en, this message translates to:
  /// **'Interval'**
  String get intervalLabel;

  /// No description provided for @secondsUnit.
  ///
  /// In en, this message translates to:
  /// **'s'**
  String get secondsUnit;

  /// No description provided for @sourceReady.
  ///
  /// In en, this message translates to:
  /// **'Ready to play'**
  String get sourceReady;

  /// No description provided for @builtInSourceBadge.
  ///
  /// In en, this message translates to:
  /// **'Bundled local'**
  String get builtInSourceBadge;

  /// No description provided for @playbackEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a source to start'**
  String get playbackEmptyTitle;

  /// No description provided for @playbackEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Open the library tab, choose a bundled local collection, then return here to preview the loop.'**
  String get playbackEmptyBody;

  /// No description provided for @goToSources.
  ///
  /// In en, this message translates to:
  /// **'Go to sources'**
  String get goToSources;

  /// No description provided for @goToLibrary.
  ///
  /// In en, this message translates to:
  /// **'Go to library'**
  String get goToLibrary;

  /// No description provided for @nextFrame.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextFrame;

  /// No description provided for @previousFrame.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previousFrame;

  /// No description provided for @addLocalFilesSource.
  ///
  /// In en, this message translates to:
  /// **'Add local files'**
  String get addLocalFilesSource;

  /// No description provided for @addLocalDirectorySource.
  ///
  /// In en, this message translates to:
  /// **'Add local directory'**
  String get addLocalDirectorySource;

  /// No description provided for @addMediaLibrarySource.
  ///
  /// In en, this message translates to:
  /// **'Add media library'**
  String get addMediaLibrarySource;

  /// No description provided for @addNetworkSource.
  ///
  /// In en, this message translates to:
  /// **'Add network source'**
  String get addNetworkSource;

  /// No description provided for @localFilesSourceTitle.
  ///
  /// In en, this message translates to:
  /// **'Local files'**
  String get localFilesSourceTitle;

  /// No description provided for @localFilesSourceDescription.
  ///
  /// In en, this message translates to:
  /// **'Images picked from this device and stored as a reusable local source.'**
  String get localFilesSourceDescription;

  /// No description provided for @localFilesSourceBadge.
  ///
  /// In en, this message translates to:
  /// **'Local files'**
  String get localFilesSourceBadge;

  /// No description provided for @localDirectorySourceBadge.
  ///
  /// In en, this message translates to:
  /// **'Local directory'**
  String get localDirectorySourceBadge;

  /// No description provided for @mediaLibrarySourceTitle.
  ///
  /// In en, this message translates to:
  /// **'Media library'**
  String get mediaLibrarySourceTitle;

  /// No description provided for @mediaLibrarySourceDescription.
  ///
  /// In en, this message translates to:
  /// **'Images selected from the system photo library and stored as a reusable local source.'**
  String get mediaLibrarySourceDescription;

  /// No description provided for @mediaLibrarySourceBadge.
  ///
  /// In en, this message translates to:
  /// **'Media library'**
  String get mediaLibrarySourceBadge;

  /// No description provided for @networkSourceTitle.
  ///
  /// In en, this message translates to:
  /// **'Network source'**
  String get networkSourceTitle;

  /// No description provided for @networkSourceDescription.
  ///
  /// In en, this message translates to:
  /// **'A reusable placeholder source backed by a remote protocol configuration.'**
  String get networkSourceDescription;

  /// No description provided for @networkSourceBadge.
  ///
  /// In en, this message translates to:
  /// **'Network source'**
  String get networkSourceBadge;

  /// No description provided for @networkSourceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Network source import is not available on this platform'**
  String get networkSourceUnavailable;

  /// No description provided for @removeSource.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeSource;

  /// No description provided for @editSource.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editSource;

  /// No description provided for @sourceSummaryReady.
  ///
  /// In en, this message translates to:
  /// **'{count} items ready'**
  String sourceSummaryReady(int count);

  /// No description provided for @playbackCounter.
  ///
  /// In en, this message translates to:
  /// **'{current} / {total}'**
  String playbackCounter(int current, int total);

  /// No description provided for @networkSourceUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated network source with {count} images'**
  String networkSourceUpdated(int count);

  /// No description provided for @localFilesImported.
  ///
  /// In en, this message translates to:
  /// **'Imported {count} local files'**
  String localFilesImported(int count);

  /// No description provided for @localDirectoryImported.
  ///
  /// In en, this message translates to:
  /// **'Imported {count} images from the directory'**
  String localDirectoryImported(int count);

  /// No description provided for @mediaLibraryImported.
  ///
  /// In en, this message translates to:
  /// **'Imported {count} images from the media library'**
  String mediaLibraryImported(int count);

  /// No description provided for @networkSourceImported.
  ///
  /// In en, this message translates to:
  /// **'Imported {count} images from the network source'**
  String networkSourceImported(int count);

  /// No description provided for @mediaLibraryPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Media library access was not granted'**
  String get mediaLibraryPermissionDenied;

  /// No description provided for @mediaLibraryUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Media library import is not available on this platform'**
  String get mediaLibraryUnavailable;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
