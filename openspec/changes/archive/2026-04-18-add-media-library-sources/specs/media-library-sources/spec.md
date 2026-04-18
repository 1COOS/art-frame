## ADDED Requirements

### Requirement: 用户可以从系统媒体库创建可复用图源
系统 SHALL 允许用户在 Android / iOS 等当前承诺支持的平台上通过系统相册 / 媒体库选择图片资产，并将所选图片创建为 `MediaSourceKind.mediaLibrary` 图源。创建出的图源 MUST 包含稳定的 source id、标题、说明、badge，以及一组可跨重启重新解析的媒体资产条目。

#### Scenario: 成功导入多张媒体库图片
- **WHEN** 用户在 Sources 页触发媒体库导入并选择了一张或多张图片资产
- **THEN** 系统 SHALL 创建一个新的 `mediaLibrary` 图源，并将所选资产作为该图源的条目保存

#### Scenario: 用户取消选择或未选中图片资产
- **WHEN** 用户关闭媒体库选择流程，或最终未返回任何图片资产
- **THEN** 系统 SHALL 不创建新的媒体库图源，且现有图源列表 MUST 保持不变

### Requirement: 媒体库图源必须在重启后可恢复
系统 SHALL 持久化媒体库图源中每个条目的稳定资产标识与最小展示元数据，并在应用重启后恢复这些图源到 Sources 列表中。

#### Scenario: 重启后恢复媒体库图源
- **WHEN** 用户已成功导入一个或多个 `mediaLibrary` 图源并重新启动应用
- **THEN** 系统 SHALL 从持久化存储中恢复这些图源，并保持其标题、kind 与媒体资产条目可用于后续解析

#### Scenario: 恢复时部分资产已失效
- **WHEN** 某个已持久化的媒体库图源在恢复时包含部分不可再访问的资产
- **THEN** 系统 SHALL 以不导致崩溃的方式处理这些失效条目，并仅恢复仍可用的图源状态或进入明确空态

### Requirement: 媒体库图源必须进入当前选择与播放闭环
系统 SHALL 将媒体库图源纳入现有 `allSourcesProvider` 数据集，并支持通过既有选择状态与 Playback destination 进行预览。

#### Scenario: 导入成功后立即进入播放预览
- **WHEN** 用户成功导入一个新的 `mediaLibrary` 图源
- **THEN** 该图源 SHALL 出现在 Sources 列表中，并能够成为当前选中图源以供 Playback destination 使用

### Requirement: Playback 必须显示媒体库图源中的图片
当当前图源包含媒体库资产条目时，播放页 SHALL 解析这些资产并显示对应图片，而不是显示占位文本或崩溃。

#### Scenario: 播放媒体库图源中的图片
- **WHEN** 用户在 Playback 页预览一个 `mediaLibrary` 图源中的图片条目
- **THEN** 系统 SHALL 显示该媒体资产对应的图片，并继续支持自动轮播、上一张与下一张切换

### Requirement: 删除媒体库图源后状态必须被回收
系统 SHALL 允许用户删除 `mediaLibrary` 图源，并在删除后回收持久化数据与失效的选中状态。

#### Scenario: 删除已选中的媒体库图源
- **WHEN** 用户删除当前已选中的 `mediaLibrary` 图源
- **THEN** 系统 SHALL 使该图源从 Sources 列表和持久化存储中消失，且 Playback MUST 不再继续引用该失效图源

### Requirement: 不支持或未授权的平台必须有明确行为
系统 SHALL 仅在 Android / iOS 等当前承诺支持媒体库访问且权限可用的平台上允许创建媒体库图源；对于不支持或未授权场景，系统 MUST 以明确方式阻止导入，而不是创建无效图源。

#### Scenario: 平台不支持媒体库导入
- **WHEN** 用户运行在当前实现未承诺支持媒体库导入的平台上（例如当前阶段的 macOS / Web）
- **THEN** Sources 页 SHALL 隐藏该入口或展示不可用状态，且用户不能创建 `mediaLibrary` 图源

#### Scenario: 用户未授予媒体库权限
- **WHEN** 用户拒绝或未授予媒体库访问权限
- **THEN** 系统 SHALL 终止导入流程且不创建新的媒体库图源
