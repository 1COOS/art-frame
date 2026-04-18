## Why

`art-frame` 已完成 Phase 1 的 `localFiles` 图源能力，用户可以通过文件多选导入本地图片并完成播放闭环。但当前图源仍是“离散文件集合”，不能表达“一个目录就是一个持续可用的图源”。

为了让 Flutter 版继续向 ShowcaseApp 的本地图源模型靠拢，下一阶段需要引入 `localDirectory` 图源：允许用户选择本地目录，将目录中的图片组织成一个可复用、可恢复的目录型图源，并为后续目录刷新、排序策略和更大规模本地图库能力打基础。

## What Changes

- 新增本地目录选择接入能力，生成 `MediaSourceKind.localDirectory` 图源。
- 在 Sources 页增加目录型图源入口，并复用既有图源卡片、选择态和 Playback 闭环。
- 基于现有 `MediaSource.directoryPath` 和 `MediaItem(kind=file)` 组织目录中已发现的图片条目。
- 为目录型图源定义最小可用的扫描与恢复行为，不在本阶段引入目录监听、后台刷新和高级排序。

## Capabilities

### New Capabilities
- `local-directory-sources`: 定义用户选择目录、生成 `localDirectory` 图源、保存目录路径与目录内图片条目的能力。

### Modified Capabilities
- `local-file-sources`: 复用既有本地图源存储与 Playback 渲染机制，使目录型图源也能进入现有主链路。

## Impact

- 将新增 `openspec/changes/add-local-directory-sources/` 下的 proposal、design、tasks 与 spec artifacts。
- 预计修改 Sources 页、本地图源 application 层以及与目录选择相关的支持代码。
- 当前阶段不覆盖目录监听、增量刷新、媒体库接入、远程协议源与缓存数据库。
