## 1. iOS 原生层实现

- [x] 1.1 在 iOS Bundle 中添加 NowPlayingArtwork 图片资源
- [x] 1.2 创建 `ios/Runner/NowPlayingService.swift` - 封装 MPNowPlayingInfoCenter 和 MPRemoteCommandCenter
- [x] 1.3 修改 `ios/Runner/AppDelegate.swift` - 注册 MethodChannel 并连接 NowPlayingService

## 2. Dart 服务层实现

- [x] 2.1 创建 `lib/services/now_playing_service.dart` - MethodChannel 封装，提供 updateNowPlayingInfo 和 clearNowPlayingInfo 方法
- [x] 2.2 在 NowPlayingService 中实现远程控制回调监听 (onRemotePlay/onRemotePause)

## 3. 状态管理增强

- [x] 3.1 在 SoundState 中添加 `_currentPresetName` 字段和 getter
- [x] 3.2 在 SoundState 中添加 `_sleepStartTime` 字段用于计算已过时间
- [x] 3.3 修改 `applySounds()` 方法 - 接收并存储预设名称参数
- [x] 3.4 修改 `select()` 和 `unselect()` 方法 - 清空 currentPresetName
- [x] 3.5 实现 `_updateNowPlaying()` 私有方法 - 同步状态到原生层
- [x] 3.6 在 `play()`、`pause()`、`togglePlay()` 中调用 `_updateNowPlaying()`
- [x] 3.7 在 `setSleepTimer()` 和 `cancelSleepTimer()` 中调用 `_updateNowPlaying()`
- [x] 3.8 在 `unselectAll()` 中调用 `clearNowPlayingInfo()`

## 4. 预设加载流程调整

- [x] 4.1 修改 `PresetScreen` 中加载预设的调用 - 传递预设名称

## 5. 远程控制响应

- [x] 5.1 在 SoundState 初始化时注册 NowPlayingService 的远程控制回调
- [x] 5.2 实现 onRemotePlay 回调 - 调用 play()
- [x] 5.3 实现 onRemotePause 回调 - 调用 pause()

## 6. 测试验证

- [x] 6.1 真机测试锁屏界面显示 Now Playing 卡片
- [x] 6.2 测试控制中心播放/暂停控制
- [x] 6.3 测试预设加载后标题显示正确
- [x] 6.4 测试睡眠定时进度显示
- [x] 6.5 测试取消所有声音后 Now Playing 消失
