## ADDED Requirements

### Requirement: 用户可以创建可验证的 WebDAV 来源配置
系统 SHALL 允许用户创建 WebDAV 来源配置，至少包含服务地址、认证信息与目标目录路径，并在生成图源前执行连接验证。

#### Scenario: WebDAV 配置验证成功
- **WHEN** 用户填写合法的 WebDAV 地址、认证信息与目录路径并触发验证
- **THEN** 系统 SHALL 返回明确的验证成功结果，并允许继续浏览或枚举远程图片

#### Scenario: WebDAV 配置验证失败
- **WHEN** WebDAV 服务不可达、认证失败或目录路径无效
- **THEN** 系统 SHALL 阻止创建新的网络图源，并向用户返回明确失败结果

### Requirement: 用户可以从 WebDAV 浏览或枚举图片生成可播放图源
系统 SHALL 支持用户在验证成功后浏览 WebDAV 远程目录或枚举图片文件，并将所选图片生成可复用的 `network` source。

#### Scenario: 从 WebDAV 目录创建图源
- **WHEN** 用户在 WebDAV 来源中选择一个目录或一组图片文件
- **THEN** 系统 SHALL 创建一个新的 `network` source，并将这些远程图片条目保存为其播放集合

#### Scenario: 用户取消 WebDAV 浏览流程
- **WHEN** 用户退出 WebDAV 浏览或最终未确认任何图片条目
- **THEN** 系统 SHALL 不创建新的网络图源，且现有 Sources 列表 MUST 保持不变

### Requirement: WebDAV 图源必须在重启后可恢复
系统 SHALL 持久化 WebDAV 图源的最小来源配置与条目快照，并在应用重启后将其恢复到 Sources 列表中。

#### Scenario: 重启后恢复 WebDAV 图源
- **WHEN** 用户已经成功创建一个或多个 WebDAV 图源并重新启动应用
- **THEN** 系统 SHALL 恢复这些图源的标题、WebDAV 配置引用与最小条目集合

#### Scenario: 恢复后 WebDAV 服务暂时不可达
- **WHEN** 已持久化的 WebDAV 图源在恢复后暂时无法连接远程服务
- **THEN** 系统 SHALL 保留该图源并进入明确错误态或占位态，而不是静默丢失图源

### Requirement: WebDAV 图源必须进入现有 Sources -> Playback 闭环
系统 SHALL 将 WebDAV 图源纳入现有 Sources 列表、选择态与 Playback destination，而不是要求用户进入独立远程播放流程。

#### Scenario: WebDAV 图源导入后立即预览
- **WHEN** 用户成功创建一个新的 WebDAV 图源
- **THEN** 该图源 SHALL 出现在 Sources 列表中，并能够成为当前选中图源以供 Playback 预览使用

### Requirement: Playback 必须对 WebDAV 条目提供非崩溃的远程显示语义
当当前图源来自 WebDAV 且包含远程图片条目时，播放页 SHALL 显示对应远程图片；若解析失败，系统 MUST 回退到明确占位态，而不是崩溃或无限等待。

#### Scenario: 成功显示 WebDAV 图片
- **WHEN** 当前选中图源为 WebDAV 图源且远程图片可正常获取
- **THEN** Playback SHALL 显示该远程图片，并继续支持自动轮播与手动切换

#### Scenario: WebDAV 图片解析失败
- **WHEN** 当前 WebDAV 条目因网络、认证或路径问题无法解析
- **THEN** Playback SHALL 显示明确占位态或错误态，且应用 MUST 保持可继续操作

### Requirement: 删除 WebDAV 图源后状态必须被回收
系统 SHALL 允许用户删除 WebDAV 图源，并在删除后同步回收持久化数据与失效的选中状态。

#### Scenario: 删除已选中的 WebDAV 图源
- **WHEN** 用户删除当前已选中的 WebDAV 图源
- **THEN** 系统 SHALL 使该图源从 Sources 列表和持久化存储中消失，且 Playback MUST 不再继续引用该失效图源
