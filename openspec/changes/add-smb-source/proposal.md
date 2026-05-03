## Why

`add-network-source-foundation` 已经定义了统一的 network source 抽象，并且项目已经用 WebDAV 验证了“配置 -> 验证 -> 浏览 -> 生成图源 -> Playback”的基本闭环，但 SMB 仍只停留在协议枚举层，尚未形成真实可用的来源能力。对于家庭 NAS、局域网共享目录等数字相框常见场景，SMB 是必须补齐的协议，因此现在需要为 SMB 建立独立的 OpenSpec change，明确范围、能力边界与实现路径。

## What Changes

- 新增独立的 `smb-source` capability，定义 SMB 作为既有 `network` source 协议扩展时的来源配置、连接验证、目录浏览 / 图片枚举、图源生成、恢复与删除回收要求。
- 约束 SMB 首版继续复用现有 Sources -> selected source -> Playback 主链路，而不是引入新的顶层 source 类型或独立播放流程。
- 明确 SMB 首版必须覆盖导入与播放闭环，包括配置填写、连接验证、目录选择、图源生成、重启恢复、删除回收，以及播放失败时的非崩溃降级语义。
- 明确 SMB 与现有 WebDAV 实现的共性与差异，尤其是认证字段、共享入口、路径语义，以及 Playback 不能直接依赖 HTTP URL + headers 语义的问题。
- 将首发支持范围扩展到 `macOS`、`iOS` 与 `Android`，`Windows`、`Linux` 与 `Web` 作为后续扩展能力，不在首版提案中强承诺。

## Capabilities

### New Capabilities
- `smb-source`: 定义 SMB 图源的配置、验证、浏览、播放闭环、恢复与删除回收要求

### Modified Capabilities

## Impact

- 预计影响 `lib/features/sources/domain/network_source_config.dart` 所代表的统一 network source 配置模型，以及 SMB 协议字段与稳定标识规则。
- 预计影响现有网络图源导入与编辑链路，包括 `lib/features/sources/application/network_source_io.dart`、`lib/features/sources/presentation/sources_page.dart`、`lib/features/sources/application/local_sources_controller.dart`。
- 预计影响敏感信息分层持久化与恢复链路，包括 `lib/features/sources/application/network_source_secrets_store.dart` 与 `lib/features/sources/application/local_sources_repository.dart`。
- 预计影响 Playback 对远程图片条目的显示桥接策略，因为 SMB 不能直接复用当前基于 `Image.network` 的 HTTP 显示语义。
- 预计需要评估并引入 SMB 客户端依赖，同时补齐对应的自动化测试与 `macOS`、`iOS`、`Android` 的首发验证路径。
