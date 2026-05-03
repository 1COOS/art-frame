## 1. SMB 来源配置与连接验证

- [x] 1.1 明确 SMB 配置字段与统一 `NetworkSourceConfig` 的映射关系，包括主机、共享名、端口、认证信息、根目录与显示名
- [x] 1.2 评估并选定 SMB 客户端依赖与 `macOS`、`iOS`、`Android` 首发支持边界，明确后续平台扩展约束
- [x] 1.3 设计并接入 SMB secrets 与普通 source 元数据的分层持久化接口

## 2. SMB 目录浏览与图源生成

- [x] 2.1 实现 SMB 连接验证、共享目录浏览与图片枚举流程
- [x] 2.2 将 SMB 选中结果转换为可持久化的 `network` source，并保留稳定配置引用
- [x] 2.3 在 Sources 页接入 SMB 创建 / 编辑流程，并保持与现有网络图源导入体验一致

## 3. Playback 与恢复闭环

- [x] 3.1 定义并实现 SMB 条目到 Playback 显示载体的桥接策略，避免直接依赖 HTTP URL + headers 语义
- [x] 3.2 在 SMB 图片加载失败时提供明确占位态或错误态，保证播放页不崩溃且可继续操作
- [x] 3.3 打通 SMB 图源的重启恢复、重新进入 Playback 与删除回收链路

## 4. 验证与收口

- [x] 4.1 补充自动化测试，覆盖 SMB 配置解析、验证失败、取消、恢复、删除与播放失败降级场景
- [ ] 4.2 在 `macOS`、`iOS`、`Android` 完成首发手工验证路径：创建来源、验证连接、浏览目录、生成图源、进入 Playback、重启恢复、删除回收
- [x] 4.3 完成后更新 OpenSpec 状态，并确认 `add-smb-source` 达到 apply-ready

