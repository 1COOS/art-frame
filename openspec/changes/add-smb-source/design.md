## Context

`add-network-source-foundation` 已经为远程图源建立了统一的 `network` source 抽象，项目也已经通过 WebDAV 打通了配置、连接验证、目录浏览、图源生成、Sources 列表接入、Playback 预览、重启恢复与删除回收的主链路。当前代码中 `NetworkSourceProtocol` 已经包含 `smb`，说明协议扩展方向已经被预留，但实际导入流程、协议 client、图片显示与错误语义仍然完全围绕 WebDAV / HTTP 设计。

这意味着 SMB 并不是“再复制一套 WebDAV 表单”这么简单。最大的约束在于 Playback 现有远程图片显示依赖 `Image.network` 与 HTTP headers 语义，而 SMB 条目通常无法直接作为公开 HTTP URL 消费；如果不在设计阶段明确桥接策略，首版实现很容易只完成“导入成功”，却无法形成真实可播放闭环。此外，当前仓库已有 macOS、iOS、Android 与 Web 目标，但没有 Windows / Linux 壳层，因此首版提案更适合聚焦 `macOS`、`iOS`、`Android` 的最小可用能力，并显式保留其他平台后续扩展空间。

## Goals / Non-Goals

**Goals:**
- 在既有 `network` source foundation 之上，为 SMB 建立独立协议 change，明确最小可用的端到端闭环。
- 沿用现有 Sources 交互心智，支持用户填写 SMB 配置、验证连接、浏览共享目录或图片、生成可持久化图源，并进入现有 Playback。
- 明确 SMB 首版所需的配置字段、共享入口语义、认证与 secrets 分层持久化要求。
- 明确 Playback 对 SMB 条目的显示桥接策略，保证真实图片可显示，失败时有非崩溃降级行为。
- 将手工验证范围扩展到 `macOS`、`iOS`、`Android` 首发路径，并为后续其他平台扩展保留空间。

**Non-Goals:**
- 不新增独立的顶层 source kind，SMB 继续作为 `network` source 的一种协议实现。
- 不在本 change 中实现 WebDAV / SFTP 行为调整，也不重构整个 network source foundation。
- 不承诺首版支持 Windows、Linux、Web 的一致实现或验证覆盖。
- 不实现 SMB 写入、双向同步、离线缓存数据库、缩略图预热或后台刷新。
- 不在首版中覆盖复杂企业认证变体，如域集成、Kerberos、NTLM 高级协商等超出基础用户名 / 密码的能力。

## Decisions

### 1. SMB 继续复用统一 network source 模型，而不是新增 source 类型
- 决策：SMB 作为既有 `MediaSourceKind.network` 下的协议扩展建模，继续使用统一的配置、持久化、选择态与删除回收链路。
- 原因：`NetworkSourceProtocol.smb` 已存在于当前 domain 层，foundation 也已经明确远程协议应在统一抽象下演进；若单独新增 source kind，会破坏已建立的复用边界。
- 备选方案：
  - 为 SMB 建立独立 source kind：实现上表面更直接，但会复制 controller、repository、Playback 接缝与删除回收逻辑，不利于后续 SFTP 扩展。

### 2. SMB 首版沿用“验证连接 -> 浏览目录 -> 生成静态图源”的导入流程
- 决策：继续复用 WebDAV 已验证的导入心智，让用户先填写 SMB 配置，再验证连接、浏览共享目录或图片，最后选择结果生成静态 `network` source。
- 原因：当前 Sources 页已经围绕统一导入后生成 source 的模式工作，这样能最大限度复用现有 UI、controller 和测试模式，并降低首版心智负担。
- 备选方案：
  - 只填写路径后直接生成动态 SMB source：看起来步骤更少，但会把连接失败、权限问题与浏览失败推迟到 Playback 阶段，降低可诊断性。

### 3. SMB 配置必须显式表达“主机 + 共享入口 + 路径 + 认证”
- 决策：首版设计要求 SMB 配置至少覆盖主机地址、共享名、可选端口、用户名、密码、根目录 / 子路径与显示名称，不把共享入口隐式拼进普通路径字符串。
- 原因：foundation 已明确远程协议差异应显式建模。SMB 的共享名是协议层关键概念，若仅靠路径字符串承载，后续验证、恢复、错误提示与 stable id 都会变得含糊。
- 备选方案：
  - 用单一 endpoint/path 字符串表达全部 SMB 目标：字段最少，但会降低可验证性与错误提示质量，也不利于后续 UI 编辑与恢复。

### 4. Playback 必须通过 SMB adapter 桥接显示载体，而不能直接复用 HTTP 图片语义
- 决策：首版规范应要求 SMB 条目先通过协议 adapter 转换为 Playback 可消费的显示载体，例如临时本地文件、受控字节流或等价桥接层，而不是假设 `Image.network` 可以直接加载 SMB 资源。
- 原因：现有 Playback 的远程显示建立在 URL + headers 的 HTTP 语义上，这只适用于 WebDAV 这类协议。SMB 若不先定义桥接层，导入闭环将止步于“有元数据但不能显示”。
- 备选方案：
  - 直接尝试把 SMB 资源转成自定义 URL 供 `Image.network` 使用：实现复杂且平台依赖重，不适合作为首版默认路径。
  - 首版不承诺真实显示，只做导入：范围更小，但无法满足用户要的“支持 SMB 协议”最小闭环。

### 5. 敏感信息与恢复数据继续分层持久化
- 决策：SMB 密码等敏感字段应继续走 secrets 存储层，普通来源元数据和图片条目快照继续走既有 source 持久化结构；恢复后若 SMB 服务不可达，图源仍保留但展示明确失败状态。
- 原因：WebDAV 已经建立了 secrets 与普通元数据分层的模式，SMB 作为同类网络协议应直接复用，避免把密码混入普通 JSON 存储。
- 备选方案：
  - 将全部字段直接序列化进 source JSON：实现最简单，但会削弱后续安全存储升级空间。

### 6. 首版支持范围扩展到 macOS + 移动端
- 决策：OpenSpec 将至少定义 `macOS`、`iOS`、`Android` 的首发验证路径，`Windows`、`Linux`、`Web` 仅保留后续可扩展的能力边界，不在首版强承诺。
- 原因：当前仓库已经具备 macOS、iOS、Android 目标，而用户明确希望首发含移动端；因此首版应直接覆盖桌面与移动端的最小可用闭环，而不是只在单一平台验证。
- 备选方案：
  - 只承诺 macOS：范围更小，但与当前首发目标不符。

## Risks / Trade-offs

- [SMB 客户端依赖平台支持不一致] → 首版以 `macOS`、`iOS`、`Android` 为必验平台，并在设计中保留其他平台后续扩展空间。
- [Playback 桥接实现复杂度高于 WebDAV] → 在 spec 与 tasks 中提前把“显示载体桥接”列为一等能力，避免实现阶段遗漏。
- [共享名、路径与认证字段设计不当导致恢复不稳定] → 明确要求协议关键字段显式建模，并让 stable id 基于结构化字段生成。
- [远程目录过大或权限受限影响浏览体验] → 首版仅要求最小浏览 / 枚举闭环，不承诺复杂分页、缓存与增量同步。
- [用户将 SMB 视为全平台能力] → proposal 中明确首发为 `macOS`、`iOS`、`Android`，同时说明 `Windows`、`Linux`、`Web` 仍属后续扩展，避免过度承诺。

## Migration Plan

1. 新增 `smb-source` OpenSpec 能力并达到 apply-ready。
2. 在实现阶段评估 SMB 客户端依赖与 `macOS`、`iOS`、`Android` 平台可行性，并先打通最小导入与播放闭环。
3. 复用既有 network source 数据模型、持久化与 UI 链路，仅在协议字段、adapter 与 Playback 桥接处扩展。
4. 完成自动化测试与 `macOS`、`iOS`、`Android` 手工验证后，再决定是否扩展到其他平台。
5. 如实现中发现依赖或平台不可行，可回退到“保留 spec / proposal、暂停 apply”状态，不影响既有 WebDAV 与本地图源能力。

## Open Questions

- 首版 SMB 客户端依赖在 Flutter 的 `macOS`、`iOS`、`Android` 上的可用性与维护状态是否足够稳定？
- Playback 更适合桥接到临时本地文件，还是使用内存 / 字节流式的图片提供方式？
- 首版是否需要允许用户显式输入自定义端口，还是先采用 SMB 默认端口即可？
- 首版是否需要支持匿名访问，还是先只覆盖用户名 / 密码认证？
