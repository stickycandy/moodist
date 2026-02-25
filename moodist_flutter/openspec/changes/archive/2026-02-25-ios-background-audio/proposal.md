## iOS 后台播放与定时控制

### 概述

为 Moodist Flutter 应用实现稳定的 iOS 后台音频播放功能，并增强睡眠定时器的可靠性，确保定时器在后台也能正常工作。

### 背景

当前应用存在以下问题：
1. **后台播放不稳定**：App 切到后台后，音频可能在一段时间后被系统中断
2. **定时器后台失效**：Dart Timer 在 App 挂起后停止工作，导致睡眠定时不准确
3. **缺少系统集成**：没有配置 iOS 后台音频模式

### 目标

1. **稳定的后台播放**：App 切后台后继续播放环境音
2. **可靠的定时控制**：睡眠定时器在后台精确执行
3. **良好的用户体验**：显示剩余时间倒计时

### 非目标

- 控制中心媒体控件（第三阶段功能）
- 定时开始功能（第三阶段功能）
- Apple Watch 支持

### 技术方案

#### 第一阶段：后台播放基础支持

1. **Info.plist 配置**
   - 添加 `UIBackgroundModes: ["audio"]`

2. **AppDelegate.swift 增强**
   - 配置 AVAudioSession 为 `.playback` 类别
   - 启用 `.mixWithOthers` 选项支持混音

#### 第二阶段：定时控制可靠性

1. **依赖添加**
   - `flutter_local_notifications` - 本地通知
   - `timezone` - 时区支持

2. **定时策略改造**
   - 记录定时结束的绝对时间而非相对时间
   - 安排本地通知作为后台 fallback
   - App 恢复前台时重建 Timer

3. **UI 增强**
   - 显示剩余时间倒计时
   - 后台状态指示

### 改动范围

```
ios/Runner/Info.plist              - 添加后台模式
ios/Runner/AppDelegate.swift       - 音频会话配置
pubspec.yaml                       - 添加依赖
lib/main.dart                      - App 生命周期监听
lib/providers/sound_state.dart     - 定时控制增强
lib/services/                      - 新建服务目录
lib/services/notification_service.dart - 本地通知服务
lib/screens/sleep_timer_screen.dart    - UI 增强
```

### 风险与考量

1. **电池消耗**：后台音频播放会消耗电量，需在 UI 中提示用户
2. **系统限制**：iOS 可能在低电量时限制后台活动
3. **通知权限**：定时功能需要用户授权通知权限
