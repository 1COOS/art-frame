# local-directory-sources Specification

## Purpose
TBD - created by archiving change add-local-directory-sources. Update Purpose after archive.
## Requirements
### Requirement: 用户可以从本地目录创建目录型图源
系统 SHALL 允许用户在支持目录选择的平台上选择一个本地目录，并将其创建为 `MediaSourceKind.localDirectory` 图源。图源 MUST 包含稳定的 source id、目录路径、标题、说明和由目录扫描得到的 `MediaItem(kind=file)` 条目。

#### Scenario: 成功导入一个本地目录
- **WHEN** 用户在 Sources 页触发目录导入并选择了一个包含图片的目录
- **THEN** 系统 SHALL 创建一个新的 `localDirectory` 图源并保存该目录路径与扫描出的图片条目

#### Scenario: 用户取消目录选择
- **WHEN** 用户关闭目录选择器或未返回有效目录路径
- **THEN** 系统 SHALL 不创建新的目录型图源，且现有图源列表 MUST 保持不变

### Requirement: 目录型图源必须可持久化恢复
系统 SHALL 通过现有本地图源持久化机制保存 `localDirectory` 图源的目录路径和扫描结果，并在应用重启后恢复到 Sources 列表中。

#### Scenario: 重启后恢复目录型图源
- **WHEN** 用户已导入一个 `localDirectory` 图源并重新启动应用
- **THEN** 系统 SHALL 恢复该图源的标题、kind、directoryPath 与已保存的图片条目

### Requirement: 目录型图源必须进入当前选择与播放闭环
系统 SHALL 将目录型图源纳入现有 `allSourcesProvider`，并支持通过既有 `selectedSourceController` 和 Playback destination 进行播放。

#### Scenario: 目录图源可被选中并播放
- **WHEN** 用户选择一个目录型图源并进入 Playback
- **THEN** 系统 SHALL 使用该目录图源中的 `MediaItem(kind=file)` 列表进行播放

### Requirement: 删除目录型图源后状态必须被回收
系统 SHALL 允许用户删除 `localDirectory` 图源，并在删除后回收对应的持久化数据与失效的选中状态。

#### Scenario: 删除已选中的目录型图源
- **WHEN** 用户删除当前已选中的 `localDirectory` 图源
- **THEN** 该图源 SHALL 从 Sources 列表和持久化存储中消失，且 Playback MUST 不再继续引用该失效图源

