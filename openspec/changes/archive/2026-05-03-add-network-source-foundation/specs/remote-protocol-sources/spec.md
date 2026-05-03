## ADDED Requirements

### Requirement: 远程协议图源必须遵循统一的协议抽象边界
系统 SHALL 为 WebDAV、SMB、SFTP 三类协议提供统一的抽象边界，使协议实现能够共享来源配置、连接验证、目录浏览 / 文件枚举、图源生成与恢复主链路，同时允许保留协议特有字段与错误语义。

#### Scenario: 新协议接入统一网络图源模型
- **WHEN** 系统为某个远程协议实现具体适配器
- **THEN** 该协议 SHALL 复用统一网络图源基础模型，而不是重新定义一套独立的 Sources -> Playback 链路

### Requirement: 远程协议差异必须被显式建模
系统 SHALL 允许 WebDAV、SMB、SFTP 在统一抽象之上声明协议差异，包括认证方式、路径格式、共享入口、目录浏览能力、文件元数据与错误类型，而不是将这些差异隐式塞入通用字符串字段。

#### Scenario: 协议需要特有认证字段
- **WHEN** 某个协议需要超出公共模型的认证或连接字段
- **THEN** 系统 SHALL 允许在该协议配置中扩展附加字段，并保持公共模型接口不失真

### Requirement: 协议实现必须支持优先级与后续拆分策略
系统 SHALL 明确定义远程协议的实现优先级与拆分策略，使 foundation 阶段完成后，WebDAV、SMB、SFTP 可作为独立 change 分阶段落地，而不会破坏已有 capability 结构。

#### Scenario: 先实现单一协议
- **WHEN** 团队决定优先实现某一个远程协议（例如 WebDAV）
- **THEN** 系统 SHALL 允许该协议在不等待其他协议完成的前提下单独落地，并继续复用统一 network-source-foundation 能力

#### Scenario: 暂缓某个高风险协议
- **WHEN** 某个协议因依赖、认证或平台风险被推迟
- **THEN** 系统 SHALL 允许该协议延后实现，而不影响其他已落地协议与统一图源基础模型
