## Why

`add-network-source-foundation` 已经为远程图源建立了统一的来源配置、最小持久化恢复与 Sources -> Playback 主链路抽象，但还没有一个真实协议被接通，因此这些抽象尚未被端到端验证。WebDAV 作为数字相框和家庭 NAS / 私有云场景中最容易优先落地的协议，适合作为 Phase 4 的第一个真实网络图源实现，用来验证 foundation 的可用性并建立后续 SMB / SFTP 的实施范式。

## What Changes

- 在已有 `network-source-foundation` 的统一抽象之上，优先落地 WebDAV 协议作为首个真实远程图源。
- 增加 WebDAV 来源配置、连接验证、目录浏览 / 图片枚举、生成可播放 `network` source、删除回收与最小持久化恢复。
- 让 WebDAV 图源复用现有 Sources / selectedSource / Playback 主链路，而不是创建独立远程播放流程。
- 约束 WebDAV 实现只补充协议特有字段与交互，不重复定义 foundation 已覆盖的公共模型与流程。
- 为后续 SMB / SFTP change 提供可复制的实现路径、测试模式与手工验证基线。

## Capabilities

### New Capabilities
- `webdav-source`: 定义 WebDAV 协议下的来源配置、连接验证、目录浏览 / 图片枚举、可播放图源创建、恢复与删除回收能力。

### Modified Capabilities
<!-- None -->

## Impact

- 预计影响 sources domain / application / persistence 结构中与 network source 相关的具体字段、adapter 与 service 实现。
- 预计引入或确定 WebDAV 客户端依赖、认证信息处理和目录枚举逻辑。
- 预计影响 Sources 页的网络来源创建流、Playback 对远程条目的实际解析，以及网络图源相关测试。
