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

## 完成标准
- Sources 页在支持平台显示“添加本地目录”入口
- 目录选择后生成 `localDirectory` 图源并保存 `directoryPath`
- 首次导入时扫描目录下受支持图片，生成静态快照 `MediaItem(kind=file)` 列表
- 目录图源可进入现有 Sources -> Playback 闭环
- 重启后可恢复目录图源
- 删除目录图源时可同步回收失效选中状态

## 当前状态
- 状态：Done
- 说明：目录选择、扫描、持久化、删除回收与 macOS 重启恢复修复均已完成；本阶段以静态快照语义收口，目录监听与刷新留待后续阶段。

## 手工验收清单
- [x] 在 macOS 导入一个含图片目录
- [x] 导入后自动进入 Playback，且可以看到目录中的图片
- [x] 重启应用后目录图源仍可恢复
- [x] 删除当前选中的目录图源后，Playback 不再引用失效 source
- [x] Web / iOS 不显示目录导入入口（按实现约束）
