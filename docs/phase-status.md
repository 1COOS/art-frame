# 当前阶段状态

## 当前 Phase
- Phase 4 - 网络图源接入（进行中）

## 当前目标
在不一次性完成全部远程协议、复杂认证体系与缓存同步机制的前提下，先建立统一 `network` 图源 foundation，并优先用 WebDAV 打通真实远程图源的连接验证、目录浏览 / 图片枚举、最小持久化恢复与 `Sources -> Playback` 主链路。

## 当前 active OpenSpec change
- `add-network-source-foundation`
- `add-webdav-source`

## 当前进行中
- Phase 1 已完成并完成 Android 虚拟机手工验收
- Phase 2 已完成目录选择、目录扫描、静态快照持久化、删除回收与 macOS 重启恢复修复
- Phase 3 已完成媒体库图源最小闭环，并完成 Android 支持平台手工验收
- 已建立 Phase 4 的 network foundation OpenSpec change，并完成最小脚手架实现
- 正在实现 WebDAV 作为首个真实远程协议，已打通基础配置、最小目录枚举、网络图源创建、恢复与 Playback 远程条目显示

## 下一步
1. 在至少一个支持平台完成 WebDAV 手工验证路径
2. 根据手工验证结果收口 `add-webdav-source`
3. 归档 `add-network-source-foundation` 与 `add-webdav-source`
4. 评估并启动下一个协议 change（优先 SMB，其次 SFTP）

## Blockers
- WebDAV 真实验证依赖可用服务端、认证信息与远程图片目录
- 敏感信息当前为最小分层持久化实现，后续仍需评估是否升级到系统安全存储
- SMB / SFTP 尚未开始实现，当前仍只承诺 WebDAV 首个真实协议落地

## 最近完成
- Phase 3 `add-media-library-sources` 已完成 docs、自动化验证与手工验收收口
- 已建立 `add-network-source-foundation` proposal / design / specs / tasks，并完成 network source 最小脚手架
- 已建立 `add-webdav-source` proposal / design / specs / tasks
- 已完成 WebDAV 的最小连接验证、目录浏览 / 图片枚举、network source 创建、删除回收与远程播放占位降级
- `flutter analyze` 与当前 WebDAV 相关测试已通过

## 追踪约定
以后每完成一个 Phase，必须同步：
- 更新当前 `phase-status.md`
- 更新路线图 `migration-roadmap.md`
- 更新对应阶段文档
- 更新对应 OpenSpec change 状态
