## MODIFIED Requirements

### Requirement: Layout adapts to phone, tablet, and wide web form factors
系统 SHALL 支持手机、平板和宽屏 Web 体验的自适应布局，使用显式断点，并针对画廊式内容展示优化各尺寸下的空间利用。

#### Scenario: Render handset layout
- **WHEN** 可用宽度在手机断点范围内
- **THEN** 应用 SHALL 呈现手机优化的布局，图源网格为1-2列，底部紧凑导航

#### Scenario: Render tablet layout
- **WHEN** 可用宽度在平板断点范围内
- **THEN** 应用 SHALL 呈现平板优化的布局，图源网格为2-3列，侧边图标导航栏（可收起）

#### Scenario: Render wide web layout
- **WHEN** 可用宽度在宽屏断点范围内
- **THEN** 应用 SHALL 呈现桌面风格布局，图源网格为3-4列，侧边图标导航栏默认收起

### Requirement: Adaptive shell keeps shared navigation behavior across form factors
系统 SHALL 定义共享 shell 模型，导航状态和主要目的地在手机、平板和宽屏布局间保持一致，同时最小化导航 chrome 的视觉占用。

#### Scenario: Change shell presentation by breakpoint
- **WHEN** 活跃的设备形态在手机、平板和宽屏布局间变化
- **THEN** 系统 SHALL 适配导航呈现方式，同时保持相同的逻辑目的地，导航元素 SHALL 尽可能紧凑

#### Scenario: Reuse business routes across layouts
- **WHEN** 某个功能路由在应用中可用
- **THEN** 该路由 SHALL 通过自适应 shell 保持可达，无需为每种设备类型复制业务逻辑

#### Scenario: Navigation rail collapses to icon-only mode
- **WHEN** 平板或桌面端侧边导航被渲染
- **THEN** 导航 SHALL 默认以仅图标模式显示（无文字标签），最小化水平空间占用
