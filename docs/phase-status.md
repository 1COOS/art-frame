# 当前阶段状态

## 当前 Phase
- Phase 2 - 本地目录接入（规划中）

## 当前目标
在不引入目录监听与高级刷新策略的前提下，将本地图源从离散文件集合扩展到目录型图源，让 `localDirectory` 能进入现有 `source -> playback` 主链路。

## 当前 active OpenSpec change
- `add-local-directory-sources`

## 当前进行中
- Phase 1 已完成并完成 Android 虚拟机手工验收
- 已建立 Phase 2 的 docs 骨架与 OpenSpec change
- 正在收敛目录选择、目录扫描与恢复行为的最小范围

## 下一步
1. 确认目录选择的支持平台与入口呈现方式
2. 设计目录扫描结果如何映射到 `MediaSourceKind.localDirectory`
3. 开始 Phase 2 的实现前准备与任务拆分

## Blockers
- 目录选择平台兼容范围尚未最终确认
- 目录内容变更后的刷新语义暂未定义（本阶段倾向静态快照）

## 最近完成
- Phase 1 `localFiles` 图源已收口
- `flutter analyze` / `flutter test` 已通过
- Android 虚拟机手工验证已完成：导入、播放、重启恢复、删除回收全部通过
- 已完成删除当前选中本地图源时的 selected state 显式回收

## 追踪约定
以后每完成一个 Phase，必须同步：
- 更新当前 `phase-status.md`
- 更新路线图 `migration-roadmap.md`
- 更新对应阶段文档
- 更新对应 OpenSpec change 状态
