# app-navigation-foundation Specification

## Purpose
TBD - created by archiving change build-flutter-multi-platform-foundation. Update Purpose after archive.
## Requirements
### Requirement: Application uses declarative routing as the navigation foundation
应用 SHALL 继续以声明式路由作为导航基础，将应用 URL、顶层 destination 与页面内容映射到统一的路由模型上，并在不要求各页面手动编排临时 Navigator 栈的前提下，支持用户从 Sources 闭环进入本地图源、媒体库图源与网络图源的 Playback 预览。

#### Scenario: Resolve a route from an application URL
- **WHEN** the application is opened from a supported route URL on Web or deep-link entry
- **THEN** the router SHALL resolve the matching destination from the declared route table

#### Scenario: Navigate between top-level destinations
- **WHEN** a user selects a primary destination from the application shell
- **THEN** the router SHALL update the active route without requiring manual Navigator stack orchestration in each screen

#### Scenario: Preview an imported local, media-library, or network source through the existing shell
- **WHEN** 用户已经在 Sources 中导入或选中了 `localFiles`、`localDirectory`、`mediaLibrary` 或网络图源并请求进入播放预览
- **THEN** 路由与 shell SHALL 激活既有 Playback destination，同时保留共享 shell UI 与当前选中图源状态

### Requirement: Navigation supports shell-based persistent UI
系统 SHALL 支持基于 shell 的路由，在子内容变化时保持共享导航可见，但导航 chrome SHALL 最小化以让内容占据最大空间。

#### Scenario: Keep shell navigation visible during child route changes
- **WHEN** shell 内的子目的地变为活跃状态
- **THEN** 共享 shell 导航 SHALL 保持挂载，同时子内容更新

#### Scenario: Support multi-branch navigation structures
- **WHEN** 基础架构定义了多个顶层目的地
- **THEN** 路由模型 SHALL 支持基于 shell 的分支导航，适用于底部导航、rail 导航或侧边导航

#### Scenario: Shell navigation has no AppBar
- **WHEN** shell 导航被渲染
- **THEN** 系统 SHALL 不显示传统的 AppBar/顶部栏，页面标题融入各页面的内容区域

#### Scenario: Bottom navigation uses compact height
- **WHEN** 手机端底部导航栏被渲染
- **THEN** 导航栏 SHALL 使用紧凑高度（56px 而非 72px），仅显示图标和微型标签

### Requirement: Navigation supports redirect-based application guards
The system SHALL support redirect logic at the router layer for app-level guard conditions such as initialization or future authentication state.

#### Scenario: Apply a redirect before rendering a protected destination
- **WHEN** a route requires a guard decision before display
- **THEN** the router SHALL be able to redirect the user to an alternate route based on application state

