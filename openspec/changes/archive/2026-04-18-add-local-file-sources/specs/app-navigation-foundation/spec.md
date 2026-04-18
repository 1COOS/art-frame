## MODIFIED Requirements

### Requirement: Application uses declarative routing as the navigation foundation
应用 SHALL 继续以声明式路由作为导航基础，将应用 URL、顶层 destination 与页面内容映射到统一的路由模型上，并在不要求各页面手动编排临时 Navigator 栈的前提下，支持用户从 Sources 闭环进入本地图源 Playback 预览。

#### Scenario: Resolve a route from an application URL
- **WHEN** the application is opened from a supported route URL on Web or deep-link entry
- **THEN** the router SHALL resolve the matching destination from the declared route table

#### Scenario: Navigate between top-level destinations
- **WHEN** a user selects a primary destination from the application shell
- **THEN** the router SHALL update the active route without requiring manual Navigator stack orchestration in each screen

#### Scenario: Preview an imported local source through the existing shell
- **WHEN** 用户已经在 Sources 中导入或选中了一个 `localFiles` 图源并请求进入播放预览
- **THEN** 路由与 shell SHALL 激活既有 Playback destination，同时保留共享 shell UI 与当前选中图源状态
