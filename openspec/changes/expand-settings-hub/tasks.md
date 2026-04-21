## 1. 设置页结构重组

- [x] 1.1 重构 `lib/features/settings/presentation/settings_page.dart`，将页面改为 `General`、`Playback`、`About` 三个分组的 settings hub
- [x] 1.2 调整设置页头部与分组文案，确保中英文文案都围绕“设置中心”而不是“播放设置”组织
- [x] 1.3 保留并迁移现有语言切换、自动播放和播放间隔控件到对应分组，避免现有交互回退

## 2. 外观偏好与应用注入

- [x] 2.1 新增外观偏好数据模型与 Riverpod controller，并使用 SharedPreferences 持久化 `light`、`dark`、`system` 三种主题模式
- [x] 2.2 扩展 `lib/app/theme/app_theme.dart`，补齐与现有设计风格一致的暗色主题定义
- [x] 2.3 更新 `lib/app/bootstrap/app.dart`，在应用根节点注入 `theme`、`darkTheme` 与 `themeMode`，确保主题切换全局即时生效

## 3. About 分组与依赖补齐

- [x] 3.1 引入版本信息与外链打开所需依赖，并封装设置页所需的最小 About 数据读取与跳转逻辑
- [x] 3.2 在 `About` 分组中接入应用版本、项目仓库、隐私政策和问题反馈入口
- [x] 3.3 为新增 About 与主题模式补齐中英文本地化文案，确保设置页各分组说明完整一致

## 4. 验证与回归

- [x] 4.1 为新增外观偏好 controller 与设置页分组展示补充单元测试或 widget 测试
- [x] 4.2 运行必要的 Flutter 代码生成、测试与静态检查，确认设置页改造未破坏既有播放偏好和导航流程
- [x] 4.3 在至少一个目标端手工验证语言切换、主题切换、播放偏好修改与 About 入口触发链路
