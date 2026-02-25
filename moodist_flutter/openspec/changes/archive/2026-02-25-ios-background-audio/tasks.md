## 任务列表

### 第一阶段：后台播放基础支持

- [x] **Task 1: Info.plist 添加后台音频模式**
  - 文件: `ios/Runner/Info.plist`
  - 添加 `UIBackgroundModes` 配置项
  - 包含 `audio` 后台模式

- [x] **Task 2: AppDelegate.swift 配置音频会话**
  - 文件: `ios/Runner/AppDelegate.swift`
  - 导入 AVFoundation
  - 配置 AVAudioSession 为 `.playback` 类别
  - 添加 `.mixWithOthers` 选项
  - 在 `didFinishLaunchingWithOptions` 中调用

### 第二阶段：定时控制可靠性

- [x] **Task 3: 添加 Flutter 依赖**
  - 文件: `pubspec.yaml`
  - 添加 `flutter_local_notifications: ^17.2.4`
  - 添加 `timezone: ^0.9.4`
  - 运行 `flutter pub get`

- [x] **Task 4: 创建通知服务**
  - 新建: `lib/services/notification_service.dart`
  - 初始化本地通知插件
  - 实现睡眠定时通知的安排与取消
  - 处理通知点击回调

- [x] **Task 5: 改造 SoundState 定时逻辑**
  - 文件: `lib/providers/sound_state.dart`
  - 添加 `WidgetsBindingObserver` 监听生命周期
  - 记录定时结束绝对时间 `_sleepEndTime`
  - 添加 `remainingTime` getter
  - 实现 `_onAppResumed` 和 `_onAppPaused`
  - 集成通知服务

- [x] **Task 6: main.dart 初始化**
  - 文件: `lib/main.dart`
  - 初始化通知服务
  - 初始化时区数据

- [x] **Task 7: 睡眠定时 UI 增强**
  - 文件: `lib/screens/sleep_timer_screen.dart`
  - 显示剩余时间倒计时
  - 每秒更新显示
  - 优化定时激活状态的视觉效果

### 验证测试

- [x] **Task 8: 功能验证**
  - 测试后台播放保持
  - 测试睡眠定时后台执行
  - 测试 App 切换前后台定时准确性
  - 测试通知权限请求流程