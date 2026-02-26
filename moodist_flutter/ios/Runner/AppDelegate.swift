import Flutter
import UIKit
import AVFoundation

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // 配置音频会话用于后台播放
    configureAudioSession()
    
    // 配置 Platform Channel 用于获取 iOS 版本信息
    configurePlatformChannel()
    
    // 配置 Now Playing 服务（锁屏和控制中心媒体控制）
    configureNowPlayingService()
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func configurePlatformChannel() {
    guard let controller = window?.rootViewController as? FlutterViewController else {
      print("Failed to get FlutterViewController")
      return
    }
    
    let channel = FlutterMethodChannel(
      name: "com.moodist/platform_info",
      binaryMessenger: controller.binaryMessenger
    )
    
    channel.setMethodCallHandler { (call, result) in
      switch call.method {
      case "getIOSVersion":
        let version = ProcessInfo.processInfo.operatingSystemVersion
        result(version.majorVersion)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
  
  private func configureAudioSession() {
    do {
      let audioSession = AVAudioSession.sharedInstance()
      // .playback: 允许后台播放
      // .mixWithOthers: 允许与其他应用音频混合（如来电铃声）
      try audioSession.setCategory(.playback, 
                                   mode: .default, 
                                   options: [.mixWithOthers])
      try audioSession.setActive(true)
    } catch {
      print("Failed to configure audio session: \(error)")
    }
  }
  
  private func configureNowPlayingService() {
    guard let controller = window?.rootViewController as? FlutterViewController else {
      print("Failed to get FlutterViewController for NowPlayingService")
      return
    }
    
    NowPlayingService.shared.configure(with: controller.binaryMessenger)
  }
}
