# 当前阶段状态

## 当前 Phase
- Phase 2 - 本地目录接入（实现中）

## 当前目标
在不引入目录监听与高级刷新策略的前提下，将本地图源从离散文件集合扩展到目录型图源，让 `localDirectory` 能进入现有 `source -> playback` 主链路。

## 当前 active OpenSpec change
- `add-local-directory-sources`

## 当前进行中
- Phase 1 已完成并完成 Android 虚拟机手工验收
- 已建立 Phase 2 的 docs 骨架与 OpenSpec change
- 已完成目录选择、目录扫描、静态快照持久化、删除回收与 macOS 重启恢复修复

## 下一步
1. 继续补齐其他支持平台的手工验收
2. 根据阶段推进决定是否加入手动刷新 / 重新扫描动作
3. 进入后续本地图源能力扩展

## Blockers
- 目录内容变更后的刷新语义仍保持未定义（本阶段采用静态快照）

## 最近完成
- Phase 1 `localFiles` 图源已收口
- `flutter analyze` / `flutter test` 已通过
- Android 虚拟机手工验证已完成：导入、播放、重启恢复、删除回收全部通过
- 已完成删除当前选中本地图源时的 selected state 显式回收
- 已完成 `localDirectory` 图源入口、扫描与持久化闭环
- 已完成 macOS 手工验收：导入、播放、重启恢复、删除回收通过

## 追踪约定
以后每完成一个 Phase，必须同步：
- 更新当前 `phase-status.md`
- 更新路线图 `migration-roadmap.md`
- 更新对应阶段文档
- 更新对应 OpenSpec change 状态
