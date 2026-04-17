## 1. 追踪与阶段对齐

- [ ] 1.1 建立 Phase 2 的 docs 文档与 OpenSpec artifacts，并将本 change 设为 Phase 2 主追踪项
- [ ] 1.2 明确目录型图源的范围、完成标准与不在范围内的能力

## 2. 目录选择与图源建模

- [ ] 2.1 在 Sources 页增加支持平台的本地目录选择入口
- [ ] 2.2 将目录选择结果转换为 `MediaSource(kind: localDirectory)`，并保存 `directoryPath`
- [ ] 2.3 扫描目录中的受支持图片并生成 `MediaItem(kind=file)` 列表

## 3. 闭环与回收

- [ ] 3.1 使用现有 repository/controller 持久化目录型图源
- [ ] 3.2 让目录型图源进入现有 Sources -> Playback 闭环
- [ ] 3.3 删除目录型图源时同步回收失效的选中状态

## 4. 验证与收口

- [ ] 4.1 补充自动化测试覆盖目录型图源的保存、恢复与删除
- [ ] 4.2 执行 `flutter analyze` 与 `flutter test`
- [ ] 4.3 在支持目录选择的平台完成手工验证：导入、播放、重启恢复、删除回收
- [ ] 4.4 完成后同步更新 docs 与路线图状态
