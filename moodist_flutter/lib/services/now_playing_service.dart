import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// iOS 锁屏和控制中心 Now Playing 服务
/// 
/// 通过 MethodChannel 与原生 iOS 代码通信，
/// 支持更新 Now Playing 信息和响应远程控制命令。
class NowPlayingService {
  static const _channel = MethodChannel('com.moodist.ting/now_playing');
  
  static VoidCallback? _onRemotePlay;
  static VoidCallback? _onRemotePause;
  static VoidCallback? _onRemoteToggle;
  
  /// 初始化服务，设置远程控制回调
  static void init({
    VoidCallback? onRemotePlay,
    VoidCallback? onRemotePause,
    VoidCallback? onRemoteToggle,
  }) {
    _onRemotePlay = onRemotePlay;
    _onRemotePause = onRemotePause;
    _onRemoteToggle = onRemoteToggle;
    
    // 设置方法调用处理器，接收来自原生层的回调
    _channel.setMethodCallHandler(_handleMethodCall);
  }
  
  /// 处理来自原生层的方法调用
  static Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onRemotePlay':
        _onRemotePlay?.call();
        break;
      case 'onRemotePause':
        _onRemotePause?.call();
        break;
      case 'onRemoteToggle':
        _onRemoteToggle?.call();
        break;
      default:
        if (kDebugMode) {
          print('NowPlayingService: Unknown method ${call.method}');
        }
    }
  }
  
  /// 更新 Now Playing 信息
  /// 
  /// [title] - 显示的标题（预设名称或 "Ting"）
  /// [isPlaying] - 当前是否正在播放
  /// [duration] - 睡眠定时总秒数，null 表示不显示进度
  /// [position] - 已过秒数，null 表示不显示进度
  static Future<void> updateNowPlayingInfo({
    required String title,
    required bool isPlaying,
    double? duration,
    double? position,
  }) async {
    // 仅在 iOS 上执行
    if (!Platform.isIOS) return;
    
    try {
      await _channel.invokeMethod('updateNowPlayingInfo', {
        'title': title,
        'isPlaying': isPlaying,
        if (duration != null) 'duration': duration,
        if (position != null) 'position': position,
      });
    } catch (e) {
      if (kDebugMode) {
        print('NowPlayingService.updateNowPlayingInfo error: $e');
      }
    }
  }
  
  /// 清除 Now Playing 信息
  static Future<void> clearNowPlayingInfo() async {
    // 仅在 iOS 上执行
    if (!Platform.isIOS) return;
    
    try {
      await _channel.invokeMethod('clearNowPlayingInfo');
    } catch (e) {
      if (kDebugMode) {
        print('NowPlayingService.clearNowPlayingInfo error: $e');
      }
    }
  }
}