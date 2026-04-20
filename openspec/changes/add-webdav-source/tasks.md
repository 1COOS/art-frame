## 1. WebDAV 来源配置与验证

- [x] 1.1 在现有 network foundation 上补齐 WebDAV 配置模型与协议字段
- [x] 1.2 选定并接入 WebDAV 客户端依赖，建立最小连接验证能力
- [x] 1.3 为 WebDAV 认证信息与普通来源元数据设计分层持久化接口

## 2. WebDAV 目录浏览与图源生成

- [x] 2.1 实现 WebDAV 目录浏览或图片枚举流程
- [x] 2.2 将选中的 WebDAV 图片条目转换为可持久化的 network source
- [x] 2.3 在 Sources 页接入 WebDAV 创建流，并支持导入后立即进入 Playback

## 3. Playback 与恢复闭环

- [x] 3.1 实现 Playback 对 WebDAV 远程图片条目的解析与显示
- [x] 3.2 在解析失败时提供明确占位态，保证不崩溃
- [x] 3.3 打通 WebDAV 图源的重启恢复与删除回收语义

## 4. 验证与收口

- [x] 4.1 补充自动化测试覆盖 WebDAV 配置验证、取消、恢复与删除场景
- [ ] 4.2 在至少一个支持平台完成 WebDAV 手工验证路径
- [x] 4.3 完成后同步更新 docs、路线图与 OpenSpec 状态
