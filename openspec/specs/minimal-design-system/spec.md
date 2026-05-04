# minimal-design-system Specification

## Purpose
TBD - created by archiving change redesign-app-ui. Update Purpose after archive.
## Requirements
### Requirement: Design system uses muted neutral color palette
设计系统 SHALL 采用低饱和度的中性色调作为主色彩方案，营造画廊级的优雅氛围。

#### Scenario: Apply muted seed color to Material 3 scheme
- **WHEN** 应用主题初始化
- **THEN** 色彩方案 SHALL 基于低饱和度的灰紫色种子色生成，避免高饱和度的强烈色彩

#### Scenario: Dark theme uses deep neutral background
- **WHEN** 深色模式激活
- **THEN** 背景色 SHALL 使用接近纯黑的深色中性色（如 #0A0A0C），营造画廊暗室感

#### Scenario: Light theme uses warm neutral background
- **WHEN** 亮色模式激活
- **THEN** 背景色 SHALL 使用温暖的浅灰色（如 #F8F7F9），避免纯白的刺眼感

### Requirement: Design system uses refined border radius scale
设计系统 SHALL 采用更现代锐利的圆角比例，取代当前较大的圆角值。

#### Scenario: Cards use moderate border radius
- **WHEN** 卡片组件被渲染
- **THEN** 卡片圆角 SHALL 为 16px（取代当前的 28px）

#### Scenario: Buttons use compact border radius
- **WHEN** 按钮组件被渲染
- **THEN** 按钮圆角 SHALL 为 12px（取代当前的 18px）

#### Scenario: Chips use small border radius
- **WHEN** Chip 组件被渲染
- **THEN** Chip 圆角 SHALL 为 10px（取代当前的 16px）

### Requirement: Design system defines unified motion language
设计系统 SHALL 定义统一的动效语言，所有 UI 动画遵循一致的时长和曲线规范。

#### Scenario: Standard transitions use easeOutCubic curve
- **WHEN** UI 元素执行标准过渡动画（显示/隐藏、位移）
- **THEN** 动画曲线 SHALL 使用 `Curves.easeOutCubic`

#### Scenario: Quick interactions use 200ms duration
- **WHEN** 执行快速交互反馈（按钮状态、hover 效果）
- **THEN** 动画时长 SHALL 为 200ms

#### Scenario: Page-level transitions use 400ms duration
- **WHEN** 执行页面级过渡（控件显隐、内容切换）
- **THEN** 动画时长 SHALL 为 400ms

#### Scenario: Emphasis transitions use 600ms duration
- **WHEN** 执行强调性过渡（图片切换、重要状态变化）
- **THEN** 动画时长 SHALL 为 600ms

### Requirement: Design system uses refined typography scale
设计系统 SHALL 采用更精致的字体排版，强调层次感和可读性。

#### Scenario: Headlines use tighter letter spacing
- **WHEN** 标题文字被渲染
- **THEN** 标题 SHALL 使用 -0.5 的字间距和 w700 字重，营造紧凑有力的视觉效果

#### Scenario: Body text uses comfortable line height
- **WHEN** 正文文字被渲染
- **THEN** 正文 SHALL 使用 1.5 的行高，确保舒适的阅读体验

### Requirement: Design system defines surface elevation through opacity
设计系统 SHALL 通过透明度而非阴影来表达表面层级关系。

#### Scenario: Elevated surfaces use semi-transparent fill
- **WHEN** 需要表达表面层级（如卡片、弹出层）
- **THEN** 系统 SHALL 使用半透明背景填充（而非 elevation 阴影）来区分层级

#### Scenario: No visible box shadows on cards
- **WHEN** 卡片组件被渲染
- **THEN** 卡片 SHALL 不显示任何阴影，通过背景色差异和细边框区分层级

