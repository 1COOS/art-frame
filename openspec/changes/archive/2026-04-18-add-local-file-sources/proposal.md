## Why

当前 `art-frame` 已具备基于内置资源图源的最小播放闭环，但还不能接入真实用户本地图片。仅靠 `bundled` 图源只能验证应用壳层与播放逻辑，无法支撑后续真正的数字相框使用场景。

为了让 Flutter 版开始具备真实可用的图源能力，本阶段优先接入“本地图片文件多选”，在尽量复用现有 `MediaSource / MediaItem / localSourcesController / selectedSourceController` 结构的前提下，打通 `localFiles` 图源的导入、持久化、显示与播放。

## What Changes

- 新增本地图片文件多选接入能力，生成 `MediaSourceKind.localFiles` 图源。
- 在 Sources 页增加本地图源导入入口，沿用现有图源列表与播放跳转交互。
- 复用 `localSourcesRepository` 和 `localSourcesController` 持久化本地图源。
- 在 Playback 页将 `MediaItemKind.file` 从占位态升级为真实图片渲染。
- 补充对应测试与手工验证，确保重启恢复与删除回收正确。

## Capabilities

### New Capabilities
- `local-file-sources`: 定义本地图片文件多选、`localFiles` 图源生成、持久化与播放展示能力。

### Modified Capabilities
- `app-navigation-foundation`: 复用既有导航壳层，增加本地图源导入后的播放跳转路径。

## Impact

- 将新增 `openspec/changes/add-local-file-sources/` 下的 proposal、tasks 等 artifacts。
- 将修改 `sources` 与 `playback` 相关页面与本地图源应用层。
- 预计会在 `pubspec.yaml` 中引入文件选择相关依赖。
- 当前阶段明确不覆盖目录递归、媒体库、远程协议源、缓存与高级播放模式。
