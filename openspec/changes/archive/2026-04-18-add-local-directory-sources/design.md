## Context

Phase 1 已经把 `localFiles` 路径打通：用户可以通过文件多选导入本地图片，生成 `MediaSourceKind.localFiles` 图源，并在 Sources / Playback 中使用。当前领域模型还预留了 `MediaSourceKind.localDirectory` 与 `directoryPath` 字段，但尚未真正发挥作用。

Phase 2 的目标不是重做本地图源架构，而是在现有 `MediaSource / MediaItem / localSourcesController / selectedSourceController / localSourcesRepository` 结构上，补齐“选择一个目录并把它视为目录型图源”的能力。

## Goals / Non-Goals

**Goals:**
- 提供目录选择入口，生成 `MediaSourceKind.localDirectory` 图源。
- 保存目录路径与当次扫描得到的图片条目。
- 让目录型图源进入现有 Sources -> Playback 主链路。
- 为后续目录刷新、排序与去重保留扩展空间。

**Non-Goals:**
- 不实现目录监听、后台同步、增量刷新。
- 不实现复杂排序、EXIF、去重策略。
- 不接入相册 / 媒体库。
- 不处理远程图源、缓存数据库或图片复制到私有沙盒。

## Decisions

### 1. 目录选择是 Phase 2 的核心入口
- 决策：通过支持目录选择的平台能力选择一个本地目录，并将其建模为 `MediaSourceKind.localDirectory`。
- 原因：现有模型已经有 `directoryPath`，目录型图源是对 Phase 1 的自然延展。

### 2. 目录型图源保存“目录路径 + 当次扫描结果”
- 决策：沿用既有 JSON 持久化结构，目录源保存 `directoryPath` 与扫描出的 `MediaItem(kind=file)` 列表。
- 原因：能够复用现有持久化与播放渲染链路，避免引入额外数据库。

### 3. Phase 2 先做“静态快照式目录图源”，不做监听
- 决策：用户选择目录时立即扫描一次并生成当前图片列表，后续不自动监听目录变化。
- 原因：这是最小可用方案，能避免目录监听和平台差异过早进入实现。

### 4. Playback 继续复用 Phase 1 的 file 渲染逻辑
- 决策：目录图源中的条目仍是 `MediaItem(kind=file)`，因此 Playback 无需额外分叉页面。
- 原因：减少复杂度，维持统一播放引擎。

## Risks / Trade-offs

- [目录内容变更后列表过期] → Phase 2 接受静态快照语义，后续再考虑刷新机制。
- [不同平台目录选择能力不一致] → 仅承诺在支持目录选择的平台开启入口。
- [目录内文件过多导致首轮扫描开销] → Phase 2 先允许最小实现，后续按需要优化分页或惰性加载。
- [无效目录路径恢复失败] → Playback 与 Sources 需接受路径失效后的空态或删除修复路径。

## Open Questions

- Phase 2 是否需要立即提供“重新扫描目录”动作，还是只在首次导入时扫描？
- 目录型图源是否要在 UI 上和 `localFiles` 图源显示不同 badge / 描述？
- 不支持目录选择的平台是隐藏入口，还是展示禁用态说明？
