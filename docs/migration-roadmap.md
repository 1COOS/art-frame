# Flutter 重写迁移路线图

## 目标
将参考 `ShowcaseApp` 的核心图源接入与播放能力，按阶段迁移到 `art-frame` Flutter 项目中，逐步从基础壳层演进到可扩展的数字相框应用。

## 阶段总览

| Phase | 名称 | 目标 | 状态 |
| --- | --- | --- | --- |
| 0 | 最小闭环基础 | 打通 `sources / playback / settings`、内置图源、播放设置与基础验证 | Done |
| 1 | 真实本地文件接入 | 支持 `localFiles` 图源、真实文件播放与持久化恢复 | Done |
| 2 | 本地目录接入 | 支持 `localDirectory` 图源与目录型媒体集合 | Done |
| 3 | 相册 / 媒体库接入 | 支持系统媒体库选择与媒体资产导入 | Done |
| 4 | 网络图源接入 | 建立统一 network foundation，并优先落地 WebDAV 首个真实协议 | In Progress |
| 5 | 高级播放能力 | 扩展 Fade / Slide / 缓存 / 更丰富展示能力 | Planned |

## 当前阶段
- 当前 Phase：Phase 4 - 网络图源接入（进行中）
- 当前 active OpenSpec changes：`add-network-source-foundation`、`add-webdav-source`
- Phase 3 收口状态：已完成 Android / iOS 媒体库导入最小闭环、自动化验证与 Android 手工验收
- Phase 4 当前目标：先建立统一网络图源 foundation，再以 WebDAV 作为首个真实协议打通连接验证、目录浏览、持久化恢复与 Playback 主链路

## 阶段映射规则
- 一个 Phase 对应一个主 OpenSpec change
- 如某阶段先建立 foundation，再拆分首个实现协议，允许存在“主 change + 协议子 change”的组合
- 每完成一个 Phase，必须同步更新：
  - `docs/migration-roadmap.md`
  - `docs/phase-status.md`
  - 对应 `docs/phase-x-*.md`
  - 对应 OpenSpec `tasks.md`

## 当前阶段边界
### Phase 4 当前要做
- 建立统一 `network` 图源建模、来源配置、最小持久化与恢复语义
- 在 Sources 页增加统一网络图源创建入口
- 让网络图源进入现有 selectedSource / Playback 闭环
- 优先实现 WebDAV：连接验证、目录浏览 / 图片枚举、图源生成、恢复与删除回收
- 为后续 SMB / SFTP 预留统一 adapter 与 capability 边界

### Phase 4 当前不做
- 在单个 change 中一次性完整实现 WebDAV / SMB / SFTP 全部协议
- 复杂认证体系、系统安全存储强化与后台同步机制
- 缩略图预热、离线缓存数据库、增量刷新与目录监听
- 高级远程媒体排序、搜索筛选与完整远程浏览器页面体系
- 远程视频 / Live Photo / GIF 特殊语义
