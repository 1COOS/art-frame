# app-navigation-foundation Specification

## Purpose
TBD - created by archiving change build-flutter-multi-platform-foundation. Update Purpose after archive.
## Requirements
### Requirement: Application uses declarative routing as the navigation foundation
应用 SHALL 继续以声明式路由作为导航基础，将应用 URL、顶层 destination 与页面内容映射到统一的路由模型上，并在不要求各页面手动编排临时 Navigator 栈的前提下，支持用户从 Sources 闭环进入本地图源与媒体库图源的 Playback 预览。

#### Scenario: Resolve a route from an application URL
- **WHEN** the application is opened from a supported route URL on Web or deep-link entry
- **THEN** the router SHALL resolve the matching destination from the declared route table

#### Scenario: Navigate between top-level destinations
- **WHEN** a user selects a primary destination from the application shell
- **THEN** the router SHALL update the active route without requiring manual Navigator stack orchestration in each screen

#### Scenario: Preview an imported local or media-library source through the existing shell
- **WHEN** 用户已经在 Sources 中导入或选中了 `localFiles`、`localDirectory` 或 `mediaLibrary` 图源并请求进入播放预览
- **THEN** 路由与 shell SHALL 激活既有 Playback destination，同时保留共享 shell UI 与当前选中图源状态

### Requirement: Navigation supports shell-based persistent UI
The system SHALL support shell-based routing for layouts that keep shared navigation chrome visible while child content changes.

#### Scenario: Keep shell navigation visible during child route changes
- **WHEN** a child destination inside the primary shell becomes active
- **THEN** the shared shell UI SHALL remain mounted while the child content updates

#### Scenario: Support multi-branch navigation structures
- **WHEN** the foundation defines multiple top-level destinations
- **THEN** the routing model SHALL support shell-based branch navigation suitable for bottom navigation, rail navigation, or side navigation

### Requirement: Navigation supports redirect-based application guards
The system SHALL support redirect logic at the router layer for app-level guard conditions such as initialization or future authentication state.

#### Scenario: Apply a redirect before rendering a protected destination
- **WHEN** a route requires a guard decision before display
- **THEN** the router SHALL be able to redirect the user to an alternate route based on application state

