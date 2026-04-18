## 1. 工程初始化与依赖基线

- [x] 1.1 使用标准 Flutter 多平台模板初始化工程，生成 `pubspec.yaml`、`lib/`、`android/`、`ios/`、`web/`、`test/` 目录
- [x] 1.2 在 `pubspec.yaml` 中接入基础依赖：`go_router`、`flutter_riverpod`、`riverpod_annotation`、`flutter_localizations`、`intl`
- [x] 1.3 在 `dev_dependencies` 中接入 `riverpod_generator`、`build_runner` 以及所需代码生成工具
- [x] 1.4 配置 Flutter 官方本地化生成链路，启用 `flutter.generate: true`

## 2. 基础目录与启动骨架

- [x] 2.1 建立 `lib/app/`、`lib/core/`、`lib/features/` 的分层目录结构
- [x] 2.2 在 `lib/app/bootstrap/` 中实现应用启动入口与全局初始化流程
- [x] 2.3 在应用根接入 `ProviderScope`，建立基础状态管理入口
- [x] 2.4 创建可运行的基础应用壳层，确保在未接入业务功能前即可启动

## 3. 路由、适配与多语言能力

- [x] 3.1 在 `lib/app/router/` 中配置基于 `go_router` 的声明式路由表
- [x] 3.2 设计并实现支持手机、平板、宽屏 Web 的自适配壳层导航
- [x] 3.3 在 `lib/app/adaptive/` 中定义断点、设备分类与布局切换策略
- [x] 3.4 在 `lib/app/l10n/` 中创建 `zh`、`en` 的 ARB 资源与语言配置
- [x] 3.5 在应用根配置 `localizationsDelegates`、`supportedLocales` 与运行时语言切换能力
- [x] 3.6 在壳层示例页面中验证路由切换、断点切换与本地化文案联动

## 4. 质量保障与跨端验证

- [x] 4.1 补齐基础 Widget 测试或单元测试，覆盖启动壳层、路由与语言切换关键路径
- [x] 4.2 执行 `flutter pub get`、`flutter analyze`、`flutter test`，修复基础问题
- [ ] 4.3 在 Android 手机、Android 平板、iPhone、iPad 与 Chrome 上完成基础冒烟验证（当前会话已完成 Chrome 与响应式断点/URL 验证；其余设备需额外启动/配置模拟器后补测）
- [x] 4.4 验证 Web URL 刷新恢复、壳层导航保持与多语言切换行为符合预期
