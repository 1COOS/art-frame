## Why

`art-frame` 已完成内置图源、本地文件、本地目录与媒体库图源的最小闭环，但图源能力仍停留在本机内容，尚不能接入真实网络存储。对于数字相框场景，仅支持本地内容会限制跨设备共享、家庭 NAS / 私有云复用以及后续更丰富的远程媒体管理能力，因此需要先建立统一的网络图源基础模型，再按协议分阶段落地实现。

## What Changes

- 新增统一的网络图源基础 proposal，定义 `WebDAV`、`SMB`、`SFTP` 三类协议可共享的图源建模、来源配置、连接验证、目录浏览 / 文件枚举、最小持久化恢复与 Sources -> Playback 闭环约束。
- 规划以“统一抽象 + 分协议适配”的方式推进，而不是为每种协议各自复制一套来源模型、页面交互与播放链路。
- 明确 Phase 4 首阶段聚焦网络 source foundation 与最小闭环，不要求一次性实现所有协议的深度能力，如高级认证流、增量同步、缓存数据库、缩略图预热、断点恢复与复杂错误恢复。
- 定义后续拆分策略：先完成统一 foundation，再按优先级拆分 `WebDAV`、`SMB`、`SFTP` 的独立实现 change。
- 调整现有导航 / Sources / Playback 主链路的能力边界，使其能承载未来网络图源，而不破坏当前 `bundled` / `localFiles` / `localDirectory` / `mediaLibrary` 的统一入口与播放模型。

## Capabilities

### New Capabilities
- `network-source-foundation`: 定义统一的网络图源建模、来源配置、连接校验、目录浏览 / 文件枚举、最小持久化恢复与进入 Playback 主链路的能力边界。
- `remote-protocol-sources`: 定义 `WebDAV`、`SMB`、`SFTP` 三类协议在统一网络图源模型下的共同约束、协议差异、优先级与后续拆分策略。

### Modified Capabilities
- `app-navigation-foundation`: 现有 shell 导航与 Playback 闭环需要扩展到网络图源导入后的预览路径与状态恢复。

## Impact

- 预计影响 Sources 页来源创建入口、图源 domain / application / persistence 模型，以及 Playback 对远程图片条目的接入方式。
- 预计需要引入或评估远程协议访问依赖（WebDAV / SMB / SFTP 客户端能力），但首阶段以 proposal / design 抽象为主，不强制在单个 change 中完成全部协议实现。
- 预计会影响 OpenSpec capability 结构，需要新增统一网络图源 capability，并为后续分协议 change 预留扩展位置。
