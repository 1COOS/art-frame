## ADDED Requirements

### Requirement: Settings 页面必须作为分组化设置中心呈现
系统 SHALL 将 `/settings` 页面呈现为面向最终用户的 settings hub，而不是仅包含少量播放偏好的单一设置页。该页面 MUST 至少提供 `General`、`Playback`、`About` 三个分组，并让用户能够在一个顶层设置入口内完成应用级偏好查看与修改。

#### Scenario: 打开设置页时看到分组化结构
- **WHEN** 用户从现有顶层导航进入 Settings 页面
- **THEN** 页面 SHALL 以清晰的分组结构展示 `General`、`Playback`、`About` 三类内容，而不是把所有设置项无层次混排在单一内容块中

### Requirement: Settings 页面必须保留并分组呈现既有必要设置项
系统 SHALL 在 `General` 与 `Playback` 分组中继续提供语言切换、自动播放和播放间隔这三项当前已存在的必要能力，并保证这些设置项在页面重构后仍可被直接发现和修改。

#### Scenario: 在重构后的设置页中修改现有设置
- **WHEN** 用户进入新的 Settings 页面并查看现有设置项
- **THEN** 系统 SHALL 仍允许用户修改语言、自动播放和播放间隔，且这些控制 MUST 分别落在语义清晰的分组中

### Requirement: Settings 页面必须提供必要的 About 信息与入口
系统 SHALL 在 `About` 分组中提供应用版本信息以及仓库、隐私政策、问题反馈等必要入口，以支持用户获取产品信息和反馈路径。

#### Scenario: 查看 About 分组内容
- **WHEN** 用户浏览 Settings 页面的 `About` 分组
- **THEN** 系统 SHALL 显示当前应用版本信息，并提供可触发的仓库、隐私政策和问题反馈入口
