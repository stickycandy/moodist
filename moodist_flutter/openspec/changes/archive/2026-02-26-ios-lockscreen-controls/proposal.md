## Why

当前 Moodist Flutter 应用已支持 iOS 后台音频播放，但用户在锁屏或控制中心无法直接控制播放。这是环境音应用的核心体验需求——用户经常在睡前设置好声音后锁屏，需要便捷地暂停或恢复播放。

## What Changes

- 在 iOS 锁屏界面和控制中心显示 Now Playing 媒体卡片
- 支持播放/暂停远程控制按钮
- 显示当前播放的预设名称或 "Ting" 作为标题
- 当设置睡眠定时时，显示进度条（已过时间/总时长）
- 封面图使用 App 图标

## Capabilities

### New Capabilities

- `ios-now-playing`: iOS 锁屏和控制中心的 Now Playing 媒体卡片集成，包括远程控制命令处理和播放信息同步

### Modified Capabilities

<!-- 无现有能力需要修改 -->

## Impact

- **iOS 原生代码**: 新增 `NowPlayingService.swift`，修改 `AppDelegate.swift` 注册 MethodChannel
- **Dart 服务层**: 新增 `lib/services/now_playing_service.dart`
- **状态管理**: 修改 `lib/providers/sound_state.dart` 增加预设名称追踪和原生同步
- **预设系统**: 修改预设加载流程，传递预设名称
- **Assets**: 在 iOS Bundle 中添加锁屏封面图
