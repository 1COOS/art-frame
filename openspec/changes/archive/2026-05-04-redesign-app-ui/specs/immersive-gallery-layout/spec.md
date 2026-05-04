## ADDED Requirements

### Requirement: Sources page displays sources as an immersive image grid
图源页面 SHALL 以自适应网格布局展示所有图源，每个图源以大尺寸封面图为主体视觉元素，取代当前的列表卡片布局。

#### Scenario: Display sources in grid layout
- **WHEN** 用户进入图源页面且存在至少一个图源
- **THEN** 系统 SHALL 以网格形式展示所有图源，每个网格项以封面图占据主要面积

#### Scenario: Grid adapts column count to screen width
- **WHEN** 屏幕宽度变化（手机/平板/桌面）
- **THEN** 网格 SHALL 自适应调整列数（手机1-2列，平板2-3列，桌面3-4列），保持每个网格项的图片有足够的视觉冲击力

### Requirement: Source grid items use overlay information layer
每个图源网格项 SHALL 将标题、类型标签和操作按钮以半透明叠层形式覆盖在封面图底部，而非独立的文字区域。

#### Scenario: Show source info overlay on grid item
- **WHEN** 图源网格项被渲染
- **THEN** 系统 SHALL 在封面图底部显示渐变遮罩叠层，包含图源标题、类型标签和图片数量

#### Scenario: Overlay text remains readable on light images
- **WHEN** 封面图为浅色内容
- **THEN** 底部渐变遮罩 SHALL 确保叠层文字始终清晰可读

### Requirement: Source grid items support contextual actions
图源网格项 SHALL 支持播放、选择、编辑和删除等操作，通过交互触发而非始终显示。

#### Scenario: Tap grid item to open playback
- **WHEN** 用户点击图源网格项的主体区域
- **THEN** 系统 SHALL 选中该图源并导航到播放页面

#### Scenario: Long press or secondary action reveals more options
- **WHEN** 用户长按图源网格项（移动端）或悬停显示操作按钮（桌面端）
- **THEN** 系统 SHALL 显示可用操作（选择、编辑、删除），其中编辑仅对网络图源可用，删除对非内置图源可用

### Requirement: Import actions are accessible from a compact trigger
图源导入操作 SHALL 通过紧凑的触发方式（如 FAB 或网格中的添加卡片）访问，而非占据页面顶部的大面积区域。

#### Scenario: Show import options via floating action button
- **WHEN** 用户点击浮动操作按钮或添加卡片
- **THEN** 系统 SHALL 展示所有可用的导入选项（本地文件、本地目录、媒体库、网络图源），根据平台能力动态显示

#### Scenario: Display add-source placeholder in empty grid
- **WHEN** 仅存在内置图源，无用户添加的图源
- **THEN** 网格中 SHALL 显示一个风格化的「添加图源」占位卡片，引导用户添加第一个自定义图源

### Requirement: Selected source has visual distinction in grid
当前选中的图源 SHALL 在网格中有明确的视觉区分。

#### Scenario: Highlight selected source
- **WHEN** 某个图源被选中为当前播放源
- **THEN** 该网格项 SHALL 显示视觉高亮标识（如边框高亮或角标），与未选中项形成明确区分
