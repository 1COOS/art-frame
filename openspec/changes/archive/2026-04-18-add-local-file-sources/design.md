## Context

当前 `art-frame` 已完成 Flutter 多端基础壳层，用户可以在 `Sources -> Playback` 的三页闭环中浏览内置 `bundled` 图源并验证自动轮播。但真实本地文件接入仍处于半成品状态：领域模型已经预留了 `MediaSourceKind.localFiles` 与 `MediaItemKind.file`，`SourcesPage` 已引入 `file_selector`，而 `PlaybackPage` 对 `file` 项仍停留在占位渲染。

本变更的目标是在不引入目录递归、媒体库索引、远程协议源与缓存复制的前提下，完成“用户选择多张本地图片 -> 生成可复用本地图源 -> 持久化恢复 -> 在播放页真实渲染”的 Phase 1 闭环。现有状态管理基于 Riverpod，持久化基于 `SharedPreferences`，因此设计应尽量复用现有 `localSourcesRepository / localSourcesController / selectedSourceController` 与 `MediaSource / MediaItem` 结构。

约束如下：
- Phase 1 只覆盖“本地图片文件多选”，不覆盖目录导入与递归扫描。
- 以文件路径持久化为主，不在应用内复制原图，也不建立单独缓存数据库。
- 仅要求在支持稳定文件路径与文件选择器的目标平台形成闭环；Flutter Web 暂不纳入本阶段承诺范围。
- 导入后的交互必须继续复用既有 shell 导航与播放页，而不是新增独立播放流程。

## Goals / Non-Goals

**Goals:**
- 在 Sources 页提供真实本地图片文件导入入口，并生成 `MediaSourceKind.localFiles` 图源。
- 将导入结果持久化到现有本地图源存储中，支持应用重启后恢复。
- 在 Playback 页将 `MediaItemKind.file` 渲染为真实本地图片，并复用现有自动轮播与切换逻辑。
- 保持既有导航壳层不变，让用户能沿用现有 Sources / Playback 闭环访问新图源。
- 为后续目录源、媒体库源、权限治理与缓存优化保留扩展空间。

**Non-Goals:**
- 不实现本地目录递归扫描、相册/媒体库读取、文件夹监听或增量同步。
- 不处理远程图源、加密存储、图片复制入沙盒或离线缓存数据库。
- 不承诺 Flutter Web 上的持久化本地文件句柄体验。
- 不改造播放模式、主题系统或全局导航结构。

## Decisions

### 1. 使用 `file_selector` 作为 Phase 1 的统一文件选择入口
- 决策：在 Sources 页通过 `file_selector` 进行多图选择，只接收图片文件并将结果转换为 `MediaItem(kind: file)`。
- 原因：仓库中已引入 `file_selector`，它与当前 Flutter 多平台方向一致，能避免过早引入平台通道或额外插件。
- 备选方案：
  - 直接使用平台通道自行封装原生 picker：灵活但实现成本更高，不适合作为 Phase 1。
  - 直接做目录选择：与当前“最小可用闭环”目标不匹配，也会带来路径扫描与权限复杂度。

### 2. 复用现有 `MediaSource` / `MediaItem` JSON 持久化，而不复制文件内容
- 决策：将本地图源以 `MediaSource(kind: localFiles)` 持久化到 `SharedPreferences`，每个条目保存文件路径、标题、描述与 `kind=file` 元数据。
- 原因：当前应用已经通过 `localSourcesRepository` 以 JSON 形式持久化本地图源，复用该结构改动最小，且能直接支撑重启恢复。
- 备选方案：
  - 将图片复制到应用私有目录：能降低外部路径失效风险，但会增加导入耗时、磁盘占用与生命周期管理复杂度。
  - 引入数据库存储：对当前 Phase 1 过重。

### 3. 导入完成后复用现有 shell 选择态与 Playback 入口
- 决策：导入成功后更新 `localSourcesController`，并通过 `selectedSourceController` 选中新图源；播放仍通过既有 Playback destination 展示，不新增独立路由分支。
- 原因：当前应用已具备 browse-select-play 基础闭环，Phase 1 应在最小改动下验证真实图源，而不是扩展导航复杂度。
- 备选方案：
  - 导入后直接 push 到新页面：会绕开既有 shell 与后续统一导航规范。
  - 仅导入不自动选中：可行，但会让用户多一次操作，降低首次闭环成功率。

### 4. Playback 对 `MediaItemKind.file` 使用文件系统图片渲染，并沿用现有轮播逻辑
- 决策：在 Playback 页按 `item.kind` 分支，`asset` 继续使用资源图加载，`file` 改为使用 `File`/文件图片组件进行真实渲染。
- 原因：当前轮播、上一张/下一张、空态与信息面板均基于 `selectedSourceProvider` 和 `source.items`，因此只需补齐渲染分支即可复用大部分逻辑。
- 备选方案：
  - 为 file source 单独做播放页：会造成逻辑分叉。
  - 在导入时把 file 转成 asset 式抽象：不符合真实本地文件语义。

### 5. Phase 1 明确限制到“支持稳定路径的平台”，Web 暂不承诺
- 决策：将本能力定义为支持文件选择与稳定文件路径恢复的目标平台能力；若平台不满足条件，应禁用、隐藏或明确告知不可用。
- 原因：Flutter Web 的本地文件通常依赖临时句柄/内存对象，难以与当前路径持久化模型兼容。
- 备选方案：
  - 为 Web 单独设计 IndexedDB/句柄持久化：超出当前变更范围。
  - 在所有平台统一开放入口：会导致 Web 或受限平台出现不可恢复的伪支持。

## Risks / Trade-offs

- [外部文件路径失效] → 通过播放页失败兜底与空态提示降低崩溃风险；Phase 1 接受“源文件被删除后图源失效”的限制。
- [不同平台文件选择能力不一致] → 在 UI 和 spec 中明确仅承诺支持稳定文件路径的平台，并对不支持平台禁用或隐藏入口。
- [SharedPreferences 存储图源元数据规模有限] → Phase 1 只承载轻量元数据而非图片内容；若后续出现大规模图源需求，再升级到数据库。
- [删除图源后残留选中态] → 在 remove 流程中联动处理 `selectedSourceController`，保证 Playback 能回到空态而非指向失效 source。
- [导入成功但预览图或播放仍使用占位态] → 明确要求 Sources 预览与 Playback 渲染都以真实本地路径为准，并在手工验证中覆盖。

## Migration Plan

1. 保持现有 `bundled` 图源能力不变，先补齐本地图源导入、持久化与真实渲染。
2. 在支持平台启用导入入口，并通过现有 controller/repository 完成本地图源存储。
3. 补齐 Playback 的 `file` 渲染与删除后的选中态回收。
4. 通过 `flutter analyze`、`flutter test` 与手工验证确认闭环后，再将该能力作为后续目录源与媒体库源的基础。
5. 若实现出现严重回归，可仅回退 Sources 导入入口与 `file` 渲染分支，保留既有 `bundled` 闭环。

## Open Questions

- Sources 页对不支持平台的入口呈现应采用“隐藏”还是“禁用并说明原因”？
- 删除已选中的本地图源时，是否需要立即清空 `selectedSourceController` 并自动回到 Sources，还是仅让 Playback 显示空态？
- 本地图源卡片预览是否只展示首张文件，还是在 Phase 1 暂时维持纯文本信息即可？
