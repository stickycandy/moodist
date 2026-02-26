## Context

Moodist Flutter (Ting) 是一个环境音混音应用，已实现 iOS 后台音频播放（UIBackgroundModes: audio）。当前使用 `audioplayers` 插件管理多音轨播放，状态通过 `SoundState` Provider 管理。

用户需求是在锁屏和控制中心显示媒体控制卡片，支持播放/暂停操作。由于应用特性（循环环境音、无固定时长、多音轨混音），需要定制化的 Now Playing 信息展示策略。

**现有架构**:
- `lib/providers/sound_state.dart`: 播放状态管理
- `lib/providers/preset_state.dart`: 预设管理
- `ios/Runner/AppDelegate.swift`: iOS 入口，已配置 AVAudioSession

## Goals / Non-Goals

**Goals:**
- 在 iOS 锁屏和控制中心显示 Now Playing 媒体卡片
- 支持播放/暂停远程控制
- 显示预设名称或 "Ting" 作为标题
- 利用睡眠定时作为进度信息来源

**Non-Goals:**
- 上一首/下一首控制（环境音混音无此概念）
- 进度条拖动控制（睡眠定时不可拖动）
- Android 媒体通知（后续单独实现）
- Apple Watch / CarPlay 支持

## Decisions

### 1. 使用原生桥接而非 audio_service 插件

**选择**: 保持 audioplayers + 通过 MethodChannel 调用原生 iOS API

**原因**:
- audio_service 需要重构播放逻辑到 AudioHandler，改动大
- 当前需求简单（仅播放/暂停），不需要 audio_service 的完整功能
- 原生桥接改动集中在新增代码，风险可控

**替代方案**:
- audio_service: 功能完整但需要大规模重构
- just_audio: 需要替换 audioplayers，影响现有功能

### 2. 预设名称追踪策略

**选择**: 在 SoundState 中记录 currentPresetName，音量调整不清空

**规则**:
- 加载预设 → 设置 currentPresetName
- 手动选择/取消声音 → 清空 currentPresetName
- 调整音量 → 保持 currentPresetName

**原因**: 用户微调音量时仍认为在使用该预设，提供更好的心理模型

### 3. 进度信息使用睡眠定时

**选择**: 使用睡眠定时的总时长和已过时间作为 Now Playing 的 duration 和 position

**原因**:
- 环境音循环播放无固定时长，无法显示传统进度
- 睡眠定时是用户关心的时间信息
- 无定时时不显示进度，符合用户预期

### 4. 封面图使用 App 图标

**选择**: 将 App 图标打包到 iOS Bundle，Swift 直接读取

**原因**:
- 简单可靠，无需运行时加载
- 所有声音使用统一封面，符合"混音"概念

## Risks / Trade-offs

### [Risk] iOS 系统可能在特定情况下不显示 Now Playing
→ 确保 AVAudioSession 正确配置为 .playback 类别，在 App 启动时激活

### [Risk] MethodChannel 通信延迟导致状态不同步
→ 状态更新采用单向推送（Dart→Swift），远程控制采用回调（Swift→Dart），减少双向依赖

### [Risk] 进度更新频繁可能影响性能
→ 仅在有睡眠定时时每秒更新，使用 Timer 批量更新而非逐帧

### [Trade-off] 不使用 audio_service 限制了未来扩展性
→ 当前需求简单，后续如需复杂功能可重新评估迁移
