## Why

最近一轮 Material 3 美化后，Sources 列表和 Playback 页面虽然更完整，但信息密度仍然偏高：Source 卡片展示了过多非决策性元数据，Playback 也持续暴露较多文字与按钮，削弱了“快速选源”和“沉浸看图”这两个主目标。现在收敛这两个高频入口，可以在不改动导入、选中、播放主链路的前提下，把界面重新压回更简洁、可扫读的状态。

## What Changes

- 精简 Sources 列表卡片的默认信息层级，只保留用户在列表扫描时真正需要的摘要信息。
- 为 Sources 列表补充编辑既有 source 的入口，把“概览”和“维护”操作从冗长静态信息里分离出来。
- 收敛 Playback 页面常驻文案、标签与控制暴露方式，让图片内容重新成为主视觉焦点。
- 保持现有导入、删除、选中、进入播放、远程图片渲染与路由闭环不变，只调整呈现与交互表达。

## Capabilities

### New Capabilities
- `sources-management-ui`: 约束 Sources 列表如何以精简摘要展示 source，并提供编辑既有 source 的管理入口。
- `immersive-playback-ui`: 约束 Playback 页如何减少常驻辅助信息与控制，突出沉浸式图片浏览体验。

### Modified Capabilities
- `app-navigation-foundation`: Playback 仍由既有播放入口触发，但其页面呈现将进一步收敛为更轻量的沉浸式浏览界面。

## Impact

- Affected code: `lib/features/sources/presentation/sources_page.dart`, `lib/features/playback/presentation/playback_page.dart`
- Potential supporting code: source editing flow used by Sources management, existing router wiring for entering Playback
- No new backend/API dependencies; scope stays in Flutter presentation and existing navigation flow
- Regression focus: source selection clarity, edit discoverability, playback controls discoverability, fullscreen image emphasis
