## Why

当前仓库只有 OpenSpec 工作流骨架，尚未具备任何 Flutter 工程能力，无法支撑后续移动端与 Web 统一开发。现在先建立一个面向 Android、Android 平板、iOS、iPad、Web 的工程级基础框架，可以尽早收敛技术选型、目录分层、自适配策略和多语言方案，降低后续功能开发与跨端返工成本。

## What Changes

- 新增 Flutter 多平台应用基础框架提案，覆盖 Android、iOS、Web 的统一工程初始化约束。
- 新增多端自适配能力规范，明确手机、平板、宽屏 Web 的断点策略、导航壳层与布局组织方式。
- 新增国际化与多语言能力规范，采用 Flutter 官方本地化方案管理文案与语言切换。
- 新增应用导航与状态管理基础能力规范，约束 `go_router`、`flutter_riverpod` 及其在工程中的职责边界。
- 新增工程设计与实施任务，指导后续从 0 到 1 搭建可扩展基础框架。

## Capabilities

### New Capabilities
- `flutter-app-bootstrap`: 定义 Flutter 多平台工程初始化、目录分层、主题与基础启动流程。
- `adaptive-multi-device-layout`: 定义手机、平板、Web 宽屏的断点、自适配布局与导航壳层策略。
- `app-localization`: 定义多语言资源组织、生成链路、支持语言与运行时切换能力。
- `app-navigation-foundation`: 定义基于 `go_router` 的声明式路由、壳层导航、Web URL 与重定向基础能力。

### Modified Capabilities
- 无

## Impact

- 新增 `openspec/changes/build-flutter-multi-platform-foundation/` 下的 proposal、specs、design、tasks artifacts。
- 后续实现将新增 Flutter 工程文件与平台目录，包括 `pubspec.yaml`、`lib/`、`android/`、`ios/`、`web/`、`test/`。
- 将引入最新稳定版 Flutter 生态依赖，重点包括 `go_router`、`flutter_riverpod`、`riverpod_annotation`、`riverpod_generator`、`flutter_localizations`、`intl`、`build_runner`。
- 后续实现会影响应用启动方式、路由组织方式、国际化资源管理方式，以及多端布局与测试验证流程。
