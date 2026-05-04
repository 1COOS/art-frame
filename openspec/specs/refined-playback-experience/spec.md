# refined-playback-experience Specification

## Purpose
TBD - created by archiving change redesign-app-ui. Update Purpose after archive.
## Requirements
### Requirement: Playback controls auto-hide after inactivity
播放页面的所有控件（返回按钮、计数器、导航按钮、图源标题）SHALL 在用户无操作一段时间后自动淡出隐藏。

#### Scenario: Controls fade out after inactivity timeout
- **WHEN** 用户在播放页面无任何触摸或鼠标移动操作超过3秒
- **THEN** 所有覆盖控件 SHALL 以淡出动画隐藏，仅保留纯净的图片展示

#### Scenario: Controls reappear on user interaction
- **WHEN** 用户在控件隐藏状态下触摸屏幕或移动鼠标
- **THEN** 所有控件 SHALL 以淡入动画重新显示，并重置隐藏计时器

#### Scenario: Extended visibility on first entry
- **WHEN** 用户首次进入播放页面
- **THEN** 控件 SHALL 保持可见5秒（而非常规的3秒），给用户足够时间了解界面布局

### Requirement: Playback supports swipe gesture for image navigation
播放页面 SHALL 支持水平滑动手势切换图片，作为导航按钮的补充交互方式。

#### Scenario: Swipe left to show next image
- **WHEN** 用户在播放页面向左滑动
- **THEN** 系统 SHALL 切换到下一张图片

#### Scenario: Swipe right to show previous image
- **WHEN** 用户在播放页面向右滑动
- **THEN** 系统 SHALL 切换到上一张图片

#### Scenario: Swipe resets autoplay timer
- **WHEN** 用户通过滑动手势切换图片且自动播放已开启
- **THEN** 自动播放计时器 SHALL 重置，从当前图片重新开始计时

### Requirement: Image transition uses elegant crossfade with scale
图片切换 SHALL 使用带缩放效果的交叉淡入淡出动画，营造优雅的视觉过渡。

#### Scenario: Animate image transition with scale crossfade
- **WHEN** 播放页面切换到新图片（自动或手动）
- **THEN** 旧图片 SHALL 以微缩（scale 0.95）+ 淡出动画退出，新图片以微放大（scale 1.05→1.0）+ 淡入动画进入，总时长约600ms

#### Scenario: Transition maintains smooth frame rate
- **WHEN** 图片切换动画执行中
- **THEN** 动画 SHALL 保持流畅（目标60fps），不因图片解码或布局计算产生卡顿

### Requirement: Playback controls use refined visual style
播放页面的控件 SHALL 采用更精致的视觉风格，与沉浸式体验协调。

#### Scenario: Controls use glassmorphism style
- **WHEN** 播放控件可见
- **THEN** 控件背景 SHALL 使用半透明模糊效果（毛玻璃风格），与底层图片自然融合

#### Scenario: Navigation controls are minimal
- **WHEN** 播放控件可见
- **THEN** 前进/后退按钮 SHALL 使用简洁的图标样式，无明显按钮边框，保持视觉轻量

