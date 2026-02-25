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
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func configurePlatformChannel() {
    guard let controller = window?.rootViewController as? FlutterViewController else {
      return
    }
    
    let channel = FlutterMethodChannel(
      name: "com.moodist/platform_info",
      binaryMessenger: controller.binaryMessenger
    )
    
    channel.setMethodCallHandler { [weak self] (call, result) in
      if call.method == "getIOSVersion" {
        let version = ProcessInfo.processInfo.operatingSystemVersion
        result(version.majorVersion)
      } else {
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
}