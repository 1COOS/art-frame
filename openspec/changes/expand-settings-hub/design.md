## Context

当前 art-frame 已经具备稳定的顶层路由和 Settings 分支，但设置能力仍停留在单页、少量控制项的阶段。`SettingsPage` 当前把语言切换与播放偏好混排在同一个卡片流中，`ArtFrameBootstrapApp` 也只固定注入 `AppTheme.light`，说明设置体系还没有覆盖应用级外观偏好和关于信息。与此同时，ShowcaseApp 的 settings 页面已经验证了“常规 / 播放 / 关于”这类分组式信息架构更适合承载逐步扩展的设置中心。

这次变更的目标不是把 ShowcaseApp 的全部设置机械搬运过来，而是在现有 Flutter / Riverpod / SharedPreferences 基础上，为 art-frame 补齐最必要且能形成产品闭环的设置项：语言、主题模式、播放偏好、关于信息。实现上需要避免为了未来假想需求引入通用设置框架，同时也要给后续继续扩展设置页保留清晰结构。

## Goals / Non-Goals

**Goals:**
- 将现有 `/settings` 页面扩展为真正的 settings hub，并保持现有顶层导航与路由结构不变。
- 把当前语言与播放偏好拆分到更清晰的分组结构中，并补齐 `About` 分组所需的必要入口。
- 新增应用级主题模式偏好，并通过 Riverpod + SharedPreferences 在应用根节点统一生效。
- 保持既有本地化、播放设置和 Settings tab 导航行为不回退。

**Non-Goals:**
- 不引入新的顶层导航、二级设置路由或通用设置 DSL / schema。
- 不在本次内实现缓存清理、匿名统计、自动更新、评分、分享、捐赠等扩展型设置功能。
- 不把 ShowcaseApp 的主题风格系统、平台专属设置或 source 专属高级选项纳入本次范围。
- 不修改 Sources / Playback 主业务流程或现有 source 持久化模型。

## Decisions

### 1. 继续在现有 Settings tab 内扩展，不新增导航结构
- `app_router.dart` 已将 Settings 作为主导航分支接入，当前最稳妥的路线是在既有 `/settings` 页内扩展为分组式设置中心。
- 这样可以复用现有 shell、路由状态和 tab 语义，避免为了设置页扩容引入新的导航复杂度。
- 备选方案：新增二级设置路由或独立设置栈。未选原因是当前范围仅是补齐必要设置项，没有证据表明需要更复杂的导航层级。

### 2. 设置页采用 General / Playback / About 三段式分组
- `General` 放应用级偏好：语言、主题模式。
- `Playback` 收拢当前已有的自动播放与播放间隔设置。
- `About` 提供版本信息、仓库、隐私政策、问题反馈入口。
- 备选方案：继续沿用当前“单页混排卡片”模式。未选原因是随着设置项增长，混排结构会迅速降低可扫读性，也不利于后续增量扩展。

### 3. 新增独立的 appearance settings 状态，而不是把主题模式塞进 playback settings
- 当前 `PlaybackSettings` 已清晰聚焦播放领域；主题模式属于应用级外观偏好，应使用独立的数据模型与 controller。
- 推荐新增 `AppearanceSettings` / `AppearanceSettingsController`，沿用 Riverpod + SharedPreferences 模式，与现有播放设置保持一致的持久化体验。
- 备选方案：直接把 ThemeMode 写死在 UI 层或并入播放设置。未选原因是会混淆领域边界，并让应用根节点难以清晰订阅外观状态。

### 4. 主题模式在应用根节点统一注入，使用 Flutter 原生 themeMode 机制
- `ArtFrameBootstrapApp` 当前只设置 `theme: AppTheme.light`；实现主题切换时，应补齐 `darkTheme` 与 `themeMode`，让根节点统一决定全局主题。
- 这样可最大化复用 Flutter MaterialApp 的原生能力，而不是在页面级别做局部外观切换。
- 备选方案：手工切换颜色 token 或仅在设置页局部展示主题状态。未选原因是无法形成真正的应用级主题偏好。

### 5. About 分组优先使用静态信息与外链，不引入复杂服务集成
- 当前仓库地址可从 git remote 推断为 `git@github.com:1COOS/art-frame.git`，可对应项目主页入口；隐私政策与反馈入口建议使用项目已有公开文档或仓库 issue 页面。
- 版本信息和外链是“必要设置项”里最容易闭环、也最具用户价值的一组，不需要引入后台或发布服务。
- 备选方案：同时实现自动更新、评分、分享。未选原因是这类能力依赖平台渠道、发布策略或额外服务，不适合本次聚焦型补全。

## Risks / Trade-offs

- [新增主题模式需要引入 dark theme 定义] → 先基于现有 `AppTheme` 补齐最小 dark theme，保持 token 风格一致，不同时引入更复杂主题风格系统。
- [About 外链依赖新包或公开 URL 约定] → 在实现前明确使用 `url_launcher` 和可公开访问的项目链接；若隐私政策正式地址暂未确定，可在任务中明确需要补齐最终 URL。
- [设置项扩展后页面复杂度上升] → 通过固定三段式分组、限制首批范围，避免设置中心一次性膨胀。
- [主题与语言都属于全局状态，回归面扩大] → 复用 Riverpod provider 模式，并在验证中覆盖切换后即时生效与重启保持两类场景。
