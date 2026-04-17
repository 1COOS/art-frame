# Phase 0 - 最小闭环基础

## 背景
项目最初只有 OpenSpec 工作流骨架，尚未具备 Flutter 多平台工程能力。Phase 0 的目标是先建立统一启动、路由、自适配和本地化基础，让后续业务迁移建立在稳定的 Flutter 应用壳层上。

## 目标
- 初始化 Flutter Android / iOS / Web 工程
- 建立 `sources / playback / settings` 三页基础结构
- 接入 `go_router`、`flutter_riverpod` 与本地化能力
- 打通最小播放闭环与基础验证

## 已完成内容
- Flutter 多平台工程初始化
- `go_router` 路由壳层与自适配导航
- `zh / en` 本地化与运行时切换
- `PlaybackSettings` 持久化
- `bundled` 内置图源、图源选择与播放页轮播
- `flutter analyze`
- `flutter test`
- 基础 Web 验证

## 关键文件
- `lib/app/router/app_router.dart`
- `lib/core/widgets/adaptive_shell.dart`
- `lib/features/sources/presentation/sources_page.dart`
- `lib/features/playback/presentation/playback_page.dart`
- `lib/features/settings/presentation/settings_page.dart`
- `test/widget_test.dart`

## OpenSpec 对应关系
- 主 change：`build-flutter-multi-platform-foundation`

## 完成状态
- 状态：Done
- 说明：OpenSpec 基础 change 已完成 17/18 项，剩余的是多模拟器/多终端冒烟补测，不影响当前进入下一阶段业务迁移。

## 对下一阶段的影响
Phase 0 结束后，项目已经具备稳定的 `source -> playback -> settings` 主链路，因此 Phase 1 可以直接围绕真实本地文件图源展开，而不需要再次调整顶层架构。
