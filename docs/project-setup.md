# art-frame 项目说明

## 项目概述

`art-frame` 当前是一个 Flutter 多平台基础工程，已完成以下基础能力：

- Flutter Android / iOS / Web 工程初始化
- `go_router` 声明式路由
- `flutter_riverpod` 状态管理入口
- Phone / Tablet / Wide Web 自适配壳层
- `zh` / `en` 本地化资源与运行时切换
- 基础 Widget 测试与 Web 冒烟验证

## 构建环境约束

### JDK

项目已固定使用系统安装的 **JDK 21**：

- 配置位置：`android/gradle.properties`
- 当前配置：`org.gradle.java.home=/Library/Java/JavaVirtualMachines/liberica-jdk-21.jdk/Contents/Home`

这意味着 Android Gradle 构建不会随终端默认 Java 浮动，而是明确使用该 JDK 21。

### Gradle

项目使用 **Gradle Wrapper**，不依赖系统全局 Gradle。

- 配置位置：`android/gradle/wrapper/gradle-wrapper.properties`
- 当前版本：`8.14.3`

请始终通过以下方式执行 Android Gradle 命令：

```bash
cd android
./gradlew <task>
```

不要直接使用系统 `gradle`。

### Java / Kotlin 编译目标

Android app 当前已升级到 **Java 21** 编译目标：

- `sourceCompatibility = JavaVersion.VERSION_21`
- `targetCompatibility = JavaVersion.VERSION_21`
- `kotlinOptions.jvmTarget = JavaVersion.VERSION_21.toString()`

相关文件：`android/app/build.gradle.kts`

## 常用命令

### 依赖与代码生成

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### 质量检查

```bash
flutter analyze
flutter test
```

### Web 调试

```bash
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 3001
```

### Android 构建

```bash
cd android
./gradlew -version
./gradlew :app:assembleDebug
```

或在项目根目录：

```bash
flutter build apk --debug
```

## 临时文件约定

所有临时调试、截图、快照与一次性验证产物，后续统一放入项目根目录的 `temp/`。

当前约定：

- `temp/` 下的内容默认不提交
- 仅保留 `temp/.gitkeep` 用于占位
- 不再把临时文件直接散落在项目根目录

典型临时产物包括：

- 调试截图
- Playwright / DevTools 快照
- 一次性验证图片
- 本地临时输出文件

## 当前实现状态

OpenSpec change `build-flutter-multi-platform-foundation` 当前进度为 **17/18**。
Phase 1 change `add-local-file-sources` 已完成实现、自动化验证以及 Android 虚拟机手工验收。

已完成：

- 工程初始化
- 路由 / 自适配 / 本地化
- Riverpod 根接入
- Widget 测试
- `flutter analyze`
- `flutter test`
- Web URL / 响应式验证
- `localFiles` 图源导入、持久化、播放与删除回收

未完全完成：

- 多终端设备冒烟验证中的部分模拟器实测
- Phase 2 `localDirectory` 图源仍处于规划阶段

## 后续建议

- 将 `applicationId` 从默认 `com.example.art_frame` 调整为正式包名
- 视需要把 Kotlin `jvmTarget` 迁移到 `compilerOptions` DSL
- 补齐 Android Phone / Android Tablet / iPhone / iPad 的完整冒烟记录
- 继续推进 Phase 2 本地目录图源能力
