## 1. 导入入口与图源组装

- [x] 1.1 在 Sources 页接入支持平台的本地图片多选入口，并对不在范围的平台隐藏或禁用入口
- [x] 1.2 将文件选择结果转换为 `MediaItem(kind: file)` 列表，并组装 `MediaSource(kind: localFiles)`

## 2. 持久化与选择态闭环

- [x] 2.1 通过 `localSourcesRepository` 与 `localSourcesController` 持久化导入的本地图源
- [x] 2.2 导入成功后联动 `selectedSourceController`，让新图源进入现有 Sources -> Playback 闭环
- [x] 2.3 删除本地图源时同步回收持久化数据与失效的选中状态

## 3. Playback 真实渲染

- [x] 3.1 在 Playback 页将 `MediaItemKind.file` 从占位态升级为真实本地图片渲染
- [x] 3.2 确保本地图源在自动轮播、上一张 / 下一张与空态流程中行为正确

## 4. 验证与收口

- [x] 4.1 补充 repository、controller 或 widget 测试，覆盖导入、恢复与删除后的最小闭环
- [x] 4.2 执行 `flutter analyze` 与 `flutter test`
- [x] 4.3 在支持文件选择的目标平台完成手工验证：Android 虚拟机已验证导入、播放、重启恢复、删除回收全部通过
