## Why

当前应用 UI 采用标准 Material 3 卡片式布局，功能完整但视觉表现力不足。作为一款数字画框应用，核心体验应该是「让艺术作品成为主角」。现有的图源管理页面信息密度较高，播放页面的控件层级不够优雅，整体缺乏画廊级的沉浸感和现代极简美学。需要重新设计 UI，使应用在视觉品质上匹配其「Art Frame」的定位。

## What Changes

- 重新设计图源页面（Sources）：从列表卡片布局改为沉浸式网格画廊，大尺寸图片预览为主，信息层叠覆盖，减少视觉噪音
- 重新设计播放页面（Playback）：优化控件为自动隐藏的浮层，增加优雅的图片切换动效，强化全屏沉浸体验
- 重新设计设置页面（Settings）：简化视觉层级，采用更现代的分组和交互方式
- 重新设计导航体系：简化导航结构，减少 chrome 元素，让内容占据更多空间
- 更新主题系统：调整色彩方案、字体排版和动效曲线，建立统一的极简视觉语言
- 优化空状态和引导流程：设计更有品质感的空状态插画和首次使用引导

## Capabilities

### New Capabilities
- `immersive-gallery-layout`: 图源页面的沉浸式网格画廊布局，包括大图预览、信息叠层、交互手势
- `refined-playback-experience`: 播放页面的精致化体验，包括自动隐藏控件、高级切换动效、手势操作
- `minimal-design-system`: 极简现代设计系统，包括色彩、字体、间距、动效、组件风格的统一规范

### Modified Capabilities
- `app-navigation-foundation`: 导航结构简化，减少 chrome 元素，适配沉浸式布局
- `adaptive-multi-device-layout`: 适配新的画廊网格布局在不同屏幕尺寸下的响应式表现

## Impact

- **UI 层**：所有三个页面（Sources、Playback、Settings）的 Widget 树需要重构
- **主题**：`AppTheme` 需要全面更新色彩、排版、组件样式
- **导航**：`AdaptiveShell` 需要适配新的导航模式
- **动效**：需要引入更丰富的动画（页面转场、控件显隐、图片切换）
- **依赖**：可能需要添加动画相关 package（如 `flutter_animate`）
- **无破坏性变更**：所有数据模型和业务逻辑保持不变，仅改变表现层
