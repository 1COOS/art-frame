## ADDED Requirements

### Requirement: Playback 必须优先突出媒体内容
系统 SHALL 将 Playback 页面呈现为以当前图片内容为主的沉浸式浏览界面，并减少常驻辅助文案、标签和控制对视觉焦点的占用。

#### Scenario: 播放页默认以媒体为主要视觉焦点
- **WHEN** 用户从已选中的图源进入 Playback 页面
- **THEN** 当前媒体内容 SHALL 占据主视觉区域，而来源说明、统计信息与控制元素 MUST 以次级层级呈现，不得持续压过图片主体

### Requirement: Playback 必须保留最小可发现控制
系统 SHALL 在精简叠层信息的同时保留用户完成返回与切换图片所需的最小控制能力。

#### Scenario: 用户仍可返回来源页并切换图片
- **WHEN** 用户在非空 Playback 页面中浏览图源内容
- **THEN** 页面 SHALL 保留返回 Sources 的入口以及切换上一张、下一张图片的控制能力，即使这些控件的视觉权重被降低

#### Scenario: Playback 空状态保持明确退路
- **WHEN** Playback 页面没有可展示的图源或图片内容
- **THEN** 系统 SHALL 继续展示清晰的空状态反馈，并提供返回 Sources 的明确入口
