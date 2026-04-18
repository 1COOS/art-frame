# 当前阶段状态

## 当前 Phase
- Phase 3 - 相册 / 媒体库接入（实现中）

## 当前目标
在不引入媒体库监听、智能相册分组与复杂权限恢复策略的前提下，将 Android / iOS 系统相册 / 媒体库中的图片资产接入现有本地图源链路，让 `mediaLibrary` 能进入现有 `source -> playback` 主链路。

## 当前 active OpenSpec change
- `add-media-library-sources`

## 当前进行中
- Phase 1 已完成并完成 Android 虚拟机手工验收
- Phase 2 已完成目录选择、目录扫描、静态快照持久化、删除回收与 macOS 重启恢复修复
- 已建立 Phase 3 的 docs 骨架与 OpenSpec change
- 正在实现 Android / iOS 媒体库导入、资产持久化恢复与 Playback 显示最小闭环

## 下一步
1. 打通 Android / iOS 媒体库授权、图片选择、source 生成与导入后预览
2. 补齐重启恢复、失效资产与删除回收语义
3. 完成自动化验证与至少一个支持平台的手工验收

## Blockers
- 不同平台的媒体库权限与受限授权语义存在差异，当前阶段仅承诺 Android / iOS 的最小可用导入闭环；macOS 暂未开放入口

## 最近完成
- Phase 1 `localFiles` 图源已收口
- Phase 2 `localDirectory` 图源已收口并完成 macOS 手工验收
- `flutter analyze` / `flutter test` 已通过上一阶段验证
- 已完成所有既有 OpenSpec changes 的 archive，并同步主 specs
- 已完成 Phase 3 `add-media-library-sources` 的 proposal / design / tasks 起草

## 追踪约定
以后每完成一个 Phase，必须同步：
- 更新当前 `phase-status.md`
- 更新路线图 `migration-roadmap.md`
- 更新对应阶段文档
- 更新对应 OpenSpec change 状态
