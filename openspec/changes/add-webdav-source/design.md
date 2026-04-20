## Context

`add-network-source-foundation` 已经完成统一网络图源基础抽象的第一轮脚手架：存在 `network` source kind、来源配置模型、最小持久化结构、Sources 统一入口以及 Playback 非崩溃占位。这为具体协议实现提供了宿主链路，但目前网络图源仍只是占位 draft，没有真实连接验证、目录浏览或远程图片解析能力。

WebDAV 之所以适合作为首个协议落地点，主要因为它在 NAS、私有云和家庭文件服务场景中普遍可用，路径与目录浏览语义相对直观，也更容易与当前“选择目录 / 枚举图片 -> 生成静态图源”的产品心智对齐。这个 change 的目标不是重写 foundation，而是在 foundation 约束下，把 WebDAV 所需的协议字段、连接验证、目录浏览、图片枚举、持久化恢复与 Sources -> Playback 闭环真正打通。

## Goals / Non-Goals

**Goals:**
- 在统一 network source foundation 之上实现 WebDAV 真实协议接入。
- 支持用户填写 WebDAV 来源配置，并完成连接验证。
- 支持浏览远程目录或枚举图片文件，并生成可播放的 `network` source。
- 让 WebDAV 图源进入现有 Sources、selectedSource、Playback 与删除回收链路。
- 提供最小可恢复语义：重启后保留 WebDAV source 配置与条目快照，并允许后续重新进入播放或重新验证。
- 补充自动化测试与至少一个支持平台的手工验证路径。

**Non-Goals:**
- 不在本 change 中实现 SMB / SFTP。
- 不实现离线缓存数据库、缩略图预热、增量同步或后台刷新。
- 不在首版中支持所有复杂认证变体（如 OAuth、客户端证书链、双因素流）。
- 不为 WebDAV 单独设计新的顶层页面体系，继续复用现有 Sources / Playback 壳层。
- 不一次性解决所有远程图片性能问题，只要求最小可用闭环与非崩溃行为。

## Decisions

### 1. WebDAV 直接复用 network foundation 的配置与 source 模型
- 决策：WebDAV 只补充协议特有字段（如 base URL、用户名、密码 / token、远程目录路径），不重新定义一套独立 source 模型。
- 原因：foundation 已经为 network source 提供统一入口与持久化壳层，重复建模会破坏后续 SMB / SFTP 的复用价值。
- 备选方案：
  - 为 WebDAV 单独定义 `webdavSource`：表达更直接，但会让后续协议难以共享 controller / repository。

### 2. WebDAV 首版遵循“验证连接 -> 浏览或枚举 -> 生成静态图源”流程
- 决策：用户先验证 WebDAV 配置，再浏览目录或枚举图片，最终选择一批图片生成静态 `network` source。
- 原因：这与本地文件、目录和媒体库的导入心智一致，也更利于首版控制恢复与错误处理复杂度。
- 备选方案：
  - 直接把 WebDAV 目录绑定为动态播放来源：恢复时强依赖网络，且会引入增量刷新复杂度。

### 3. 敏感信息与图源快照分层持久化
- 决策：WebDAV 来源配置与播放所需快照都需要持久化，但敏感字段应与普通 source 元数据区分对待，并为后续 keychain / keystore 方案留口。
- 原因：如果将密码等字段与普通图源 JSON 完全等同对待，会使后续安全策略升级代价更高。
- 备选方案：
  - 首版完全不保存敏感字段：更安全，但会让重启恢复的最小闭环无法成立。

### 4. Playback 首版只要求真实远程图片能显示，失败时必须明确降级
- 决策：Playback 对 WebDAV 条目应尽可能显示真实远程图片；若网络失败、路径失效或认证过期，必须回退到明确占位态，而不是崩溃或无限加载。
- 原因：foundation 阶段已经有 remote 占位逻辑，WebDAV 实现可以在此基础上做协议级增强。
- 备选方案：
  - 强依赖在线成功才允许进入 Playback：用户路径过于脆弱。

## Risks / Trade-offs

- [WebDAV 客户端依赖在多平台行为不一致] → 先限定支持平台并建立最小验证矩阵，避免一开始承诺所有桌面 / 移动平台完全一致。
- [敏感字段持久化方案不完善] → 首版通过分层模型预留升级接口，并在 docs 中明确后续需要强化安全存储。
- [远程目录过大导致浏览性能差] → 首版只要求最小浏览 / 枚举闭环，不做全量预加载与复杂排序。
- [Playback 受网络波动影响] → 允许失败降级到明确占位态，避免崩溃和卡死。
- [与 foundation 重复实现] → 严格复用既有 network source 模型，只在 WebDAV adapter / flow 上补协议细节。

## Migration Plan

1. 基于现有 network foundation 引入 WebDAV adapter 与来源配置结构。
2. 打通 WebDAV 连接验证、目录浏览 / 图片枚举与 source 创建流。
3. 将 WebDAV source 纳入现有 localSourcesRepository / selectedSource / Playback 主链路。
4. 补齐自动化测试与至少一个支持平台的手工验证路径。
5. 如果协议依赖或认证实现遇到高风险，可先保留 WebDAV source 创建壳层并回退真实目录浏览，不影响 foundation 结构。

## Open Questions

- WebDAV 首版是否优先支持目录型图源，还是同时支持离散文件型图源？
- 密码 / token 在当前项目里是否需要立即接入系统安全存储，还是先保留普通持久化占位并加文档限制？
- 首版图片加载是否直接使用 WebDAV URL + header，还是需要先走 adapter 拉取临时文件路径？
- WebDAV 浏览流程是否需要最小目录层级导航，还是先只支持单目录输入后自动枚举？
