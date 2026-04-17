# Phase 2 - 本地目录接入

## 背景
Phase 1 已完成 `localFiles` 图源能力，但当前本地图源仍以离散文件集合为主，不能表达“一个目录就是一个可复用图源”。为了进一步靠拢 ShowcaseApp 的本地图源模型，Phase 2 将引入 `localDirectory`。

## 目标
- 支持用户选择一个本地目录
- 生成 `MediaSourceKind.localDirectory`
- 保存 `directoryPath` 与目录中扫描到的图片条目
- 让目录型图源进入现有 Sources -> Playback 闭环

## 范围内
- 本地目录选择
- 目录扫描生成 `MediaItem(kind=file)`
- source 持久化与重启恢复
- 删除目录型图源后的状态回收

## 不在范围内
- 目录监听与自动刷新
- 高级排序、EXIF、去重
- 相册 / 媒体库
- 远程协议图源
- 缓存数据库与图片复制入沙盒

## OpenSpec 对应关系
- 主 change：`add-local-directory-sources`

## 当前状态
- 状态：Planned
- 说明：Phase 1 已收口，当前进入 Phase 2 规划阶段，尚未开始代码实现。
