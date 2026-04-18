## Context

当前仓库是一个仅包含 `openspec/` 与 `.claude/` 的规范工作区，没有 Flutter 工程、平台目录、依赖配置或现有业务代码。本次设计的目标不是补全某个功能模块，而是为后续所有 Flutter 功能开发建立一个可复用、可扩展、可跨端验证的工程基础。

约束如下：
- 需要覆盖 Android、Android 平板、iOS、iPad、Web。
- 需要从一开始就纳入多语言能力，而不是后补。
- 需要尽量采用 Flutter 官方推荐能力和最新稳定生态包，降低长期维护成本。
- 当前没有既有代码可以复用，因此目录分层、状态管理、路由与适配策略必须一次性定义清楚。

## Goals / Non-Goals

**Goals:**
- 建立单一 Flutter 代码库的多平台工程基础。
- 约束 app/core/features 分层，避免后续业务代码侵入全局基础设施。
- 采用 `go_router` 提供声明式路由、Web URL 支持和壳层导航能力。
- 采用 Riverpod 作为基础状态管理与依赖注入机制。
- 采用 Flutter 官方 `flutter_localizations` + `intl` + `gen_l10n` 建立多语言链路。
- 采用断点驱动的自适应布局，覆盖手机、平板、宽屏 Web。

**Non-Goals:**
- 不在本次变更中实现具体业务功能或业务数据流。
- 不在本次变更中引入复杂后端集成、认证体系或离线缓存策略。
- 不为每个平台分别维护独立页面实现，除非交互差异必须平台特化。
- 不围绕单一缩放方案做“全局等比适配”。

## Decisions

### 1. 以标准 Flutter 工程作为项目入口
**Decision**：后续实现从标准 Flutter 工程初始化开始，生成 `pubspec.yaml`、`lib/`、`android/`、`ios/`、`web/`、`test/` 基础目录，再在其上叠加架构层。

**Rationale**：当前仓库没有 Flutter 代码，使用标准工程初始化可以最大限度复用 Flutter 官方工具链与平台支持，避免自定义脚手架破坏后续升级路径。

**Alternatives considered**：
- 手工拼装目录：灵活，但易遗漏平台配置与默认集成。
- 先只做 mobile：实现更快，但会把 Web 与大屏适配问题延后，后续返工更大。

### 2. 采用 app/core/features 三层目录
**Decision**：
- `lib/app/` 存放启动、路由、主题、国际化、自适配等全局应用层能力。
- `lib/core/` 存放与业务无关的基础抽象与通用设施。
- `lib/features/` 按 feature 划分页面、状态与数据访问。

**Rationale**：应用层与业务层拆分后，能保证基础框架在未来新增 feature 时仍保持稳定边界。

**Alternatives considered**：
- 全部平铺在 `lib/`：上手简单，但很快失控。
- 过度细分多层 DDD：对当前从 0 到 1 的工程不必要，复杂度过高。

### 3. 路由采用 go_router
**Decision**：使用 `go_router` 作为统一路由方案，基础设计中预留 `ShellRoute` / `StatefulShellRoute` 用于壳层导航。

**Rationale**：`go_router` 同时适配移动端导航和 Web URL，支持 redirect、深链和多导航树，适合作为多端基础框架。

**Alternatives considered**：
- 原生 `Navigator 2.0`：能力足够，但样板代码多。
- `auto_route`：代码生成强，但当前基础框架更需要简洁、官方生态贴合与 Web URL 语义。

### 4. 状态管理采用 Riverpod + generator
**Decision**：使用 `flutter_riverpod`、`riverpod_annotation`、`riverpod_generator`，在应用根使用 `ProviderScope`，异步状态优先采用 `AsyncNotifier`。

**Rationale**：Riverpod 提供清晰的作用域、覆盖测试能力和较强的可维护性，适合作为工程基础设施。代码生成可减少样板代码，并为后续 feature 扩展提供统一模式。

**Alternatives considered**：
- Bloc：成熟，但在当前基础脚手架中样板偏重。
- Provider：简单，但约束与可测试性不如 Riverpod。

### 5. 国际化采用 Flutter 官方 gen_l10n
**Decision**：使用 `flutter_localizations`、`intl` 与 `gen_l10n`，通过 ARB 文件管理初始 `zh`/`en` 文案。

**Rationale**：这是 Flutter 官方推荐链路，生成代码与框架集成度最高，后续新增语言时成本最低。

**Alternatives considered**：
- `easy_localization`：集成快，但当前更适合先采用官方标准方案。

### 6. 自适配采用断点驱动而不是全局缩放
**Decision**：基于 `LayoutBuilder` / `MediaQuery` 定义 handset、tablet、wide 三档断点，并在壳层层面切换导航表现。

**Rationale**：多端体验的核心是布局重组而非统一缩放。断点驱动更适合手机、平板和 Web 的差异化信息密度。

**Alternatives considered**：
- 统一缩放类方案：实现快，但在平板与 Web 上容易出现信息密度和导航结构不合理的问题。

### 7. 壳层优先，业务页面复用
**Decision**：
- 手机优先使用底部导航或单栏壳层。
- 平板/iPad 优先使用 `NavigationRail` 与可扩展内容区。
- Web 宽屏优先使用侧边导航与大内容区。
- 业务路由与状态尽量共享，仅壳层视图表现随断点变化。

**Rationale**：这样可以最大限度共享业务实现，同时提供符合设备形态的导航体验。

## Risks / Trade-offs

- **[风险] Web、平板与手机在首版壳层设计上容易出现过度抽象** → **Mitigation**：先只定义三档明确断点与有限壳层变体，不提前为更多形态建模。
- **[风险] 最新稳定依赖版本之间可能存在兼容性差异** → **Mitigation**：实现阶段用 `flutter pub get`、`flutter analyze`、`flutter test` 验证，并优先遵循 Flutter 官方兼容依赖链。
- **[风险] 过早引入代码生成会增加初始复杂度** → **Mitigation**：仅在 Riverpod 与数据模型等高复用环节使用生成，避免全局泛化。
- **[风险] 没有真实业务页面时难以验证自适配体验** → **Mitigation**：基础框架至少提供可切换的示例壳层页面与路由，用于跨端冒烟验证。

## Migration Plan

1. 创建并完善本 change 的 proposal、specs、design、tasks。
2. 在实现阶段初始化 Flutter 多平台工程。
3. 接入核心依赖：路由、Riverpod、本地化、代码生成工具。
4. 建立 `app/`、`core/`、`features/` 目录与启动骨架。
5. 实现自适配壳层、基础路由与多语言示例页面。
6. 运行 `flutter analyze`、`flutter test` 与多端设备冒烟验证。

**Rollback strategy**：
- 在提案阶段无需回滚代码；若实现阶段方案验证不通过，可保留标准 Flutter 工程结构，替换单项依赖选型，而不推翻整体分层。

## Open Questions

- 首版基础框架是否需要同时预置深色模式切换状态，还是仅提供主题结构与默认亮色主题。
- 是否需要在首版中加入环境区分（dev/staging/prod）入口，还是先保留单环境启动。
- Web 首版是否需要考虑 SEO/静态预渲染约束，还是仅以 Flutter Web 应用壳层为目标。
