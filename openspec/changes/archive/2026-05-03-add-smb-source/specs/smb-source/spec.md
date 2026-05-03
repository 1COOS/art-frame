## ADDED Requirements

### Requirement: 用户可以创建可验证的 SMB 来源配置
系统 SHALL 允许用户创建 SMB 来源配置，至少包含主机地址、共享名、认证信息与目标目录路径，并在生成图源前执行连接验证。

#### Scenario: SMB 配置验证成功
- **WHEN** 用户填写合法的 SMB 主机、共享名、认证信息与目录路径并触发验证
- **THEN** 系统 SHALL 明确告知连接验证成功，并允许用户继续浏览共享目录或枚举图片

#### Scenario: SMB 配置验证失败
- **WHEN** SMB 服务不可达、共享名无效、认证失败或目录路径不存在
- **THEN** 系统 SHALL 显示明确错误信息，并且 MUST 阻止用户在未修正配置前生成图源

### Requirement: 用户可以从 SMB 浏览或枚举图片生成可播放图源
系统 SHALL 支持用户在验证成功后浏览 SMB 远程目录或枚举图片文件，并将所选图片生成可复用的 `network` source。

#### Scenario: 从 SMB 目录创建图源
- **WHEN** 用户在 SMB 共享中选择一个目录或一组图片文件
- **THEN** 系统 SHALL 生成包含所选图片条目的 `network` source，并保留 SMB 来源配置引用以便后续恢复或重新编辑

#### Scenario: 用户取消 SMB 浏览流程
- **WHEN** 用户退出 SMB 浏览或最终未确认任何图片条目
- **THEN** 系统 SHALL 不创建新的 SMB 图源，也 MUST 不污染现有来源列表与持久化数据

### Requirement: SMB 图源必须在重启后可恢复
系统 SHALL 持久化 SMB 图源的最小来源配置引用与条目快照，并在应用重启后将其恢复到 Sources 列表中。

#### Scenario: 重启后恢复 SMB 图源
- **WHEN** 用户已经成功创建一个或多个 SMB 图源并重新启动应用
- **THEN** 系统 SHALL 恢复这些图源的标题、SMB 配置引用与最小条目集合

#### Scenario: 恢复后 SMB 服务暂时不可达
- **WHEN** 已持久化的 SMB 图源在恢复后暂时无法连接远程服务
- **THEN** 系统 SHALL 保留该图源并允许用户看到明确的失败或占位状态，而不是直接丢弃图源记录

### Requirement: SMB 图源必须进入现有 Sources -> Playback 闭环
系统 SHALL 将 SMB 图源纳入现有 Sources 列表、选择态与 Playback destination，而不是要求用户进入独立远程播放流程。

#### Scenario: SMB 图源导入后立即预览
- **WHEN** 用户成功创建一个新的 SMB 图源
- **THEN** 该图源 SHALL 出现在 Sources 列表中，并能够成为当前选中图源以供 Playback 预览使用

### Requirement: Playback 必须对 SMB 条目提供非崩溃的远程显示语义
当当前图源来自 SMB 且包含远程图片条目时，播放页 SHALL 通过受控桥接方式显示对应图片；若解析失败，系统 MUST 回退到明确占位态，而不是崩溃或无限等待。

#### Scenario: 成功显示 SMB 图片
- **WHEN** 当前选中图源为 SMB 图源且远程图片可正常获取
- **THEN** Playback SHALL 显示该远程图片，并继续支持自动轮播与手动切换

#### Scenario: SMB 图片解析失败
- **WHEN** 当前 SMB 条目因网络、认证、共享权限或路径问题无法解析
- **THEN** Playback SHALL 显示明确占位态或错误态，且应用 MUST 保持可继续操作

### Requirement: 删除 SMB 图源后状态必须被回收
系统 SHALL 允许用户删除 SMB 图源，并在删除后同步回收持久化数据与失效的选中状态。

#### Scenario: 删除已选中的 SMB 图源
- **WHEN** 用户删除当前已选中的 SMB 图源
- **THEN** 系统 SHALL 使该图源从 Sources 列表和持久化存储中消失，且 Playback MUST 不再继续引用该失效图源
