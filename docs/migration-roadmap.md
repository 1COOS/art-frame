# Flutter 重写迁移路线图

## 目标
将参考 `ShowcaseApp` 的核心图源接入与播放能力，按阶段迁移到 `art-frame` Flutter 项目中，逐步从基础壳层演进到可扩展的数字相框应用。

## 阶段总览

| Phase | 名称 | 目标 | 状态 |
| --- | --- | --- | --- |
| 0 | 最小闭环基础 | 打通 `sources / playback / settings`、内置图源、播放设置与基础验证 | Done |
| 1 | 真实本地文件接入 | 支持 `localFiles` 图源、真实文件播放与持久化恢复 | Done |
| 2 | 本地目录接入 | 支持 `localDirectory` 图源与目录型媒体集合 | Done |
| 3 | 相册 / 媒体库接入 | 支持系统媒体库选择与媒体资产导入 | In Progress |
| 4 | 网络图源接入 | 逐步接入 WebDAV / SMB / SFTP 等远程 source | Planned |
| 5 | 高级播放能力 | 扩展 Fade / Slide / 缓存 / 更丰富展示能力 | Planned |

## 当前阶段
- 当前 Phase：Phase 3 - 相册 / 媒体库接入（实现中）
- 当前 active OpenSpec change：`add-media-library-sources`
- Phase 2 收口状态：已完成 `localDirectory` 图源实现、自动化验证与 macOS 手工验收
- Phase 3 当前目标：以最小闭环方式完成 Android / iOS 媒体库授权、图片选择、恢复、删除回收与 Playback 展示

## 阶段映射规则
- 一个 Phase 对应一个主 OpenSpec change
- 每完成一个 Phase，必须同步更新：
  - `docs/migration-roadmap.md`
  - `docs/phase-status.md`
  - 对应 `docs/phase-x-*.md`
  - 对应 OpenSpec `tasks.md`

## 当前阶段边界
### Phase 3 当前要做
- 在 Sources 页增加 Android / iOS 的系统媒体库 / 相册导入入口
- 生成 `MediaSourceKind.mediaLibrary`
- 保存稳定资产标识与最小展示元数据
- 让媒体库图源进入现有 Playback 闭环
- 处理权限拒绝、取消选择与失效资产的最小语义

### Phase 3 当前不做
- 视频 / GIF / Live Photo 特殊处理
- 智能相册、系统相册分组浏览与搜索筛选
- 媒体库监听、自动刷新与增量同步
- macOS 媒体库导入入口与权限流（当前阶段暂不开放）
- 远程协议图源
- 高级缓存、EXIF、排序与同步
