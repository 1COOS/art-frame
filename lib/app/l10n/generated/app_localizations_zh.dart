// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Art Frame';

  @override
  String get shellHeadline => '多平台基础框架已就绪';

  @override
  String get shellDescription => '该基础壳层用于在接入业务功能前验证路由、自适配布局与本地化能力。';

  @override
  String get homeTab => '首页';

  @override
  String get galleryTab => '画廊';

  @override
  String get settingsTab => '设置';

  @override
  String get currentRouteLabel => '当前路由';

  @override
  String get currentDeviceLabel => '当前布局';

  @override
  String get languageLabel => '语言';

  @override
  String get languageEnglish => '英文';

  @override
  String get languageChinese => '中文';

  @override
  String get homeTitle => '基础首页';

  @override
  String get homeBody => '使用此壳层验证启动、顶层导航以及语言切换。';

  @override
  String get galleryTitle => '自适应画廊';

  @override
  String get galleryBody => '调整窗口尺寸以验证手机、平板与宽屏布局复用同一组目的地。';

  @override
  String get settingsTitle => '基础设置';

  @override
  String get settingsBody => '运行时语言切换由应用层的 Riverpod 状态统一管理。';

  @override
  String get phoneLayout => '手机';

  @override
  String get tabletLayout => '平板';

  @override
  String get wideLayout => '宽屏';

  @override
  String get routeHome => '/home';

  @override
  String get routeGallery => '/gallery';

  @override
  String get routeSettings => '/settings';
}
