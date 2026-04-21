## Why

art-frame 当前已经把 Settings 作为顶层导航分支接入，但 `lib/features/settings/presentation/settings_page.dart` 仍然只覆盖语言、自动播放和播放间隔，本质上还是“播放偏好页”，还没有形成完整的设置中心。参考 ShowcaseApp 的 settings 信息架构，可以在不改动顶层导航的前提下，补齐对当前产品真正必要的设置项，让设置页与现有 Sources / Playback 主链路更加匹配。

## What Changes

- 将现有 `/settings` 页面扩展为完整的 settings hub，并按 `General`、`Playback`、`About` 三个分组组织内容。
- 保留现有语言切换、自动播放和播放间隔能力，但将播放相关控制收拢到独立的 `Playback` 分组。
- 新增可持久化的主题模式设置，至少支持浅色、深色和跟随系统三种选择，并在应用根节点全局生效。
- 新增 `About` 分组，提供版本信息以及仓库、隐私政策、问题反馈等必要入口。
- 明确本次不引入 ShowcaseApp 中与 art-frame 当前能力不匹配的缓存、匿名统计、自动更新、评分、捐赠等设置项。

## Capabilities

### New Capabilities
- `settings-hub`: 定义 Settings 顶层页面如何作为设置中心呈现，并约束其 General、Playback、About 三组必要设置内容。
- `appearance-preferences`: 定义主题模式偏好如何在设置页中暴露、持久化，并在应用根节点全局应用。

### Modified Capabilities
无

## Impact

- Affected code: `lib/features/settings/presentation/settings_page.dart`, `lib/features/settings/application/playback_settings.dart`, `lib/features/settings/application/playback_settings_controller.dart`, `lib/app/bootstrap/app.dart`, `lib/app/theme/app_theme.dart`, `lib/app/l10n/arb/app_en.arb`, `lib/app/l10n/arb/app_zh.arb`
- Likely new code: `lib/features/settings/application/appearance_settings.dart`, `lib/features/settings/application/appearance_settings_controller.dart`
- Likely dependencies: `package_info_plus`（版本信息）, `url_launcher`（外链打开）
- Regression focus: 顶层 Settings 导航保持不变、语言切换即时生效、主题模式持久化与全局应用、既有播放偏好逻辑不回退、About 外链入口可用
