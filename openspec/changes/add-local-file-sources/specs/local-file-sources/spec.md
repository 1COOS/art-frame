## ADDED Requirements

### Requirement: 用户可以从本地图片文件创建可复用图源
系统 SHALL 允许用户在支持的平台上通过文件选择器一次选择多张本地图片，并将其创建为 `MediaSourceKind.localFiles` 图源。创建出的图源 MUST 包含稳定的 source id、标题、说明、`kind=localFiles`，以及一组 `MediaItem(kind=file)` 条目。

#### Scenario: 成功导入多张本地图片
- **WHEN** 用户在 Sources 页触发“添加本地文件”并选择了一张或多张受支持的图片文件
- **THEN** 系统 SHALL 创建一个新的 `localFiles` 图源并将所选文件按 `MediaItem(kind=file)` 保存到该图源中

#### Scenario: 用户取消选择或未选中受支持图片
- **WHEN** 用户关闭文件选择器，或返回的文件集合为空
- **THEN** 系统 SHALL 不创建新的本地图源，且现有图源列表 MUST 保持不变

### Requirement: 导入的本地图源必须可持久化恢复
系统 SHALL 通过现有本地图源存储机制持久化 `localFiles` 图源元数据与文件条目，并在应用重启后恢复到 Sources 列表中。

#### Scenario: 重启后恢复本地图源
- **WHEN** 用户已成功导入一个或多个 `localFiles` 图源并重新启动应用
- **THEN** 系统 SHALL 从持久化存储中恢复这些图源，并保持其标题、kind 与文件条目不变

### Requirement: 导入完成后图源必须进入当前选择闭环
系统 SHALL 在成功导入本地图源后将其纳入现有 `allSourcesProvider` 数据集，并支持通过既有选择状态进入播放闭环。

#### Scenario: 导入成功后可立即用于播放
- **WHEN** 用户成功导入一个新的 `localFiles` 图源
- **THEN** 该图源 SHALL 出现在 Sources 列表中，并能够成为当前选中图源以供 Playback destination 使用

### Requirement: Playback 必须真实渲染本地文件图片
当当前图源包含 `MediaItem(kind=file)` 时，播放页 SHALL 使用真实本地文件路径渲染图片，而不是显示占位文本或占位卡片。

#### Scenario: 播放本地图源中的图片
- **WHEN** 用户在 Playback 页预览一个 `localFiles` 图源中的 `MediaItem(kind=file)`
- **THEN** 系统 SHALL 按文件图片渲染该条目，并继续支持自动轮播、上一张与下一张切换

### Requirement: 删除本地图源后状态必须被回收
系统 SHALL 允许用户删除 `localFiles` 图源，并在删除后回收持久化数据与失效的选中状态。

#### Scenario: 删除已选中的本地图源
- **WHEN** 用户删除当前已选中的 `localFiles` 图源
- **THEN** 系统 SHALL 使该图源从 Sources 列表和持久化存储中消失，且 Playback MUST 不再继续引用该失效图源
