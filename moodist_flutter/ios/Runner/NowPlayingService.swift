import Foundation
import MediaPlayer
import Flutter

/// 管理 iOS 锁屏和控制中心的 Now Playing 信息
class NowPlayingService: NSObject {
    static let shared = NowPlayingService()
    
    private var channel: FlutterMethodChannel?
    private let commandCenter = MPRemoteCommandCenter.shared()
    private let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
    
    private override init() {
        super.init()
    }
    
    /// 配置 MethodChannel
    func configure(with messenger: FlutterBinaryMessenger) {
        channel = FlutterMethodChannel(
            name: "com.moodist.ting/now_playing",
            binaryMessenger: messenger
        )
        
        channel?.setMethodCallHandler { [weak self] (call, result) in
            self?.handleMethodCall(call, result: result)
        }
        
        setupRemoteCommands()
    }
    
    // MARK: - Method Call Handler
    
    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "updateNowPlayingInfo":
            guard let args = call.arguments as? [String: Any] else {
                result(FlutterError(code: "INVALID_ARGS", message: "Arguments required", details: nil))
                return
            }
            updateNowPlayingInfo(args)
            result(nil)
            
        case "clearNowPlayingInfo":
            clearNowPlayingInfo()
            result(nil)
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    // MARK: - Now Playing Info
    
    private func updateNowPlayingInfo(_ args: [String: Any]) {
        let title = args["title"] as? String ?? "Ting"
        let isPlaying = args["isPlaying"] as? Bool ?? false
        let duration = args["duration"] as? Double
        let position = args["position"] as? Double
        
        var nowPlayingInfo: [String: Any] = [
            MPMediaItemPropertyTitle: title,
            MPMediaItemPropertyArtist: "Ting",
            MPNowPlayingInfoPropertyPlaybackRate: isPlaying ? 1.0 : 0.0
        ]
        
        // 设置封面图
        if let artwork = UIImage(named: "NowPlayingArtwork") {
            let mediaArtwork = MPMediaItemArtwork(boundsSize: artwork.size) { _ in
                return artwork
            }
            nowPlayingInfo[MPMediaItemPropertyArtwork] = mediaArtwork
        }
        
        // 如果有睡眠定时，设置时长和进度
        if let dur = duration, let pos = position {
            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = dur
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = pos
        }
        
        nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
    }
    
    private func clearNowPlayingInfo() {
        nowPlayingInfoCenter.nowPlayingInfo = nil
    }
    
    // MARK: - Remote Commands
    
    private func setupRemoteCommands() {
        // 播放命令
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { [weak self] _ in
            self?.channel?.invokeMethod("onRemotePlay", arguments: nil)
            return .success
        }
        
        // 暂停命令
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.channel?.invokeMethod("onRemotePause", arguments: nil)
            return .success
        }
        
        // 播放/暂停切换命令
        commandCenter.togglePlayPauseCommand.isEnabled = true
        commandCenter.togglePlayPauseCommand.addTarget { [weak self] _ in
            self?.channel?.invokeMethod("onRemoteToggle", arguments: nil)
            return .success
        }
        
        // 禁用不需要的命令
        commandCenter.nextTrackCommand.isEnabled = false
        commandCenter.previousTrackCommand.isEnabled = false
        commandCenter.skipForwardCommand.isEnabled = false
        commandCenter.skipBackwardCommand.isEnabled = false
        commandCenter.changePlaybackPositionCommand.isEnabled = false
    }
}