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
  String get shellHeadline => 'Showcase Flutter 重写基础已就绪';

  @override
  String get shellDescription => '当前基线已打通内置本地图源、播放设置持久化，以及最小播放闭环。';

  @override
  String get sourcesTab => '图源';

  @override
  String get playbackTab => '播放';

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
  String get sourcesTitle => '内置本地图源';

  @override
  String get sourcesBody => '先用应用内置本地图片验证图源选择、持久化与播放流程，后续再接入设备文件选择。';

  @override
  String get playbackTitle => '播放页';

  @override
  String get playbackBody => '当前选中的图源会自动轮播，也支持手动切换。';

  @override
  String get settingsTitle => '播放设置';

  @override
  String get settingsBody => '语言与播放间隔会本地保存，确保最小闭环重启后仍可恢复。';

  @override
  String get phoneLayout => '手机';

  @override
  String get tabletLayout => '平板';

  @override
  String get wideLayout => '宽屏';

  @override
  String get routeSources => '/sources';

  @override
  String get routePlayback => '/playback';

  @override
  String get routeSettings => '/settings';

  @override
  String get selectedSourceLabel => '当前图源';

  @override
  String get itemsCountLabel => '内容数';

  @override
  String get openPlayback => '打开播放';

  @override
  String get selectSource => '选择图源';

  @override
  String get noSourceSelected => '尚未选择图源';

  @override
  String get chooseSourceHint => '请先在图源页选择一个图源，再切到播放页。';

  @override
  String get autoplayLabel => '自动播放';

  @override
  String get intervalLabel => '播放间隔';

  @override
  String get secondsUnit => '秒';

  @override
  String get sourceReady => '可立即播放';

  @override
  String get builtInSourceBadge => '内置本地';

  @override
  String get playbackEmptyTitle => '先选择一个图源';

  @override
  String get playbackEmptyBody => '前往图源页选择一个内置本地集合，然后回到这里预览轮播效果。';

  @override
  String get goToSources => '前往图源页';

  @override
  String get nextFrame => '下一张';

  @override
  String get previousFrame => '上一张';

  @override
  String get addLocalFilesSource => '添加本地文件';

  @override
  String get localFilesSourceTitle => '本地文件';

  @override
  String get localFilesSourceDescription => '从当前设备选择图片，并保存为可复用的本地图源。';

  @override
  String get localFilesSourceBadge => '本地文件';

  @override
  String get removeSource => '移除';

  @override
  String localFilesImported(int count) {
    return '已导入 $count 个本地文件';
  }
}
