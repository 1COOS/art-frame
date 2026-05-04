## MODIFIED Requirements

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
