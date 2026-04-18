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
  /// **'Local bundled sources'**
  String get sourcesTitle;

  /// No description provided for @sourcesBody.
  ///
  /// In en, this message translates to:
  /// **'Start with bundled local images to validate source selection, persistence, and playback flow before adding device pickers.'**
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
  /// **'Playback settings'**
  String get settingsTitle;

  /// No description provided for @settingsBody.
  ///
  /// In en, this message translates to:
  /// **'Locale and playback interval are stored locally so the minimal loop survives restarts.'**
  String get settingsBody;

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
  /// **'Open the sources tab, choose a bundled local collection, then return here to preview the loop.'**
  String get playbackEmptyBody;

  /// No description provided for @goToSources.
  ///
  /// In en, this message translates to:
  /// **'Go to sources'**
  String get goToSources;

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

  /// No description provided for @removeSource.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeSource;

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
