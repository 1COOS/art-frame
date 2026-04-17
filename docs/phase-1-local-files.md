# Phase 1 - 真实本地文件接入

## 背景
当前应用已经能通过 `bundled` 图源演示完整播放闭环，但还不能接入真实用户本地图片。为了让 Flutter 版具备第一个真正有价值的图源能力，本阶段优先打通 `localFiles`。

## 目标
- 支持用户选择多张本地图片文件
- 生成 `MediaSourceKind.localFiles`
- 用现有持久化链路保存 source
- 在 Sources 页展示新图源
- 在 Playback 页显示真实 file 图片

## 范围内
- 本地文件多选
- `localFiles` source 生成
- source 持久化与重启恢复
- 播放页真实文件图片渲染
- 删除 source 后状态回收一致

## 不在范围内
- 本地目录递归与目录监听
- 相册 / 媒体库
- 视频 / GIF
- 缩略图缓存
- EXIF / 高级排序 / 去重
- WebDAV / SMB / SFTP / GitHub / TMDB / Unsplash / Pexels / Immich

## 当前建议路径
```text
文件多选
  ↓
MediaItem(kind: file)
  ↓
MediaSource(kind: localFiles)
  ↓
localSourcesController.upsert(...)
  ↓
allSourcesProvider
  ↓
selectedSourceController
  ↓
PlaybackPage
```

## 关键文件
- `lib/features/sources/presentation/sources_page.dart`
- `lib/features/playback/presentation/playback_page.dart`
- `lib/features/sources/application/local_file_picker.dart`
- `lib/features/sources/application/local_sources_controller.dart`
- `lib/features/sources/application/local_sources_repository.dart`
- `lib/features/sources/application/selected_source_controller.dart`
- `lib/features/sources/domain/media_source.dart`
- `lib/features/sources/domain/media_item.dart`
- `lib/core/widgets/local_image.dart`
- `test/widget_test.dart`
- `test/local_sources_repository_test.dart`
- `test/selected_source_controller_test.dart`

## OpenSpec 对应关系
- 主 change：`add-local-file-sources`

## 任务概览
- [x] 增加本地文件导入入口
- [x] 组装 `localFiles` source
- [x] 持久化 source
- [x] Playback 支持真实 file 图片渲染
- [x] 删除当前选中 source 时清理 selected state
- [x] 完成自动化测试验证
- [x] 完成 Android 虚拟机手工验证

## 完成标准
- 可从应用中选择多张本地图片文件
- 新图源出现在 Sources 页
- 可进入 Playback 且显示真实图片
- 重启应用后图源仍存在
- 删除当前选中 source 后状态正确回收
- `flutter analyze` / `flutter test` 通过

## 手工验证结果
- 平台：Android 虚拟机
- 导入：通过
- 播放：通过
- 重启恢复：通过
- 删除回收：通过

## 当前状态
- 状态：Done
- 说明：追踪骨架、导入入口、localFiles 图源持久化、选中跳转、Playback 真实 file 渲染、selected state 回收与自动化验证均已完成；Android 虚拟机手工验收也已通过。
