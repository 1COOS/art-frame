## Why

`art-frame` 已完成 Phase 1/2 的本地图源闭环，用户现在可以导入离散文件或整个目录并进入 Playback，但仍无法接入系统相册 / 媒体库中的真实图片资产。对于移动设备上的数字相框场景，仅依赖文件系统选择器会让主流使用路径缺失，也无法继续向 ShowcaseApp 的媒体图源能力靠拢。

因此下一阶段需要补齐“系统媒体库图片 -> 可复用图源 -> 持久化恢复 -> Playback 预览”的最小闭环，在尽量复用现有 Sources / Playback 架构的前提下，为后续更丰富的媒体资产能力打基础。

## What Changes

- 新增系统相册 / 媒体库图片导入能力，生成新的 `MediaSourceKind.mediaLibrary`（或等价命名）图源。
- 在支持的平台提供媒体库入口，允许用户选择一批图片资产并创建可复用图源。
- 为媒体库图源持久化稳定资产标识与必要展示元数据，使其在应用重启后仍可恢复。
- 让媒体库图源进入现有 Sources 列表、选择态与 Playback 闭环，而不是引入独立播放流程。
- 补充最小自动化测试与至少一个目标平台的手工验收。

## Capabilities

### New Capabilities
- `media-library-sources`: 定义系统媒体库图片选择、媒体库图源创建、资产持久化恢复与 Playback 预览能力。

### Modified Capabilities
- `app-navigation-foundation`: 现有 shell 导航与 Playback 闭环需要覆盖媒体库图源的导入后预览路径。

## Impact

- 将新增 `openspec/changes/add-media-library-sources/` 下的 proposal、design、tasks 与 spec artifacts。
- 预计修改 Sources 页导入入口、本地图源 application/data/domain 层，以及 Playback 对媒体库资产的读取方式。
- 预计引入媒体库访问依赖与权限处理（如 `photo_manager` 或同类能力）。
- 当前阶段不覆盖视频、GIF 特殊处理、智能相册、系统相册分组浏览、复杂权限恢复策略、资源监听与自动刷新。
