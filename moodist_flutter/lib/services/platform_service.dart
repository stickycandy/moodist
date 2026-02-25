import 'dart:io';
import 'package:flutter/services.dart';

/// 平台信息服务
/// 
/// 提供 iOS 版本检测功能，用于判断是否应该使用 iOS 26 液态玻璃风格
class PlatformService {
  static final PlatformService _instance = PlatformService._internal();
  factory PlatformService() => _instance;
  PlatformService._internal();

  static const _channel = MethodChannel('com.moodist/platform_info');
  
  /// 缓存的 iOS 主版本号
  int? _cachedIOSVersion;
  
  /// 是否已经初始化
  bool _initialized = false;

  /// 获取 iOS 主版本号
  /// 
  /// 首次调用时通过 Platform Channel 获取原生版本，之后使用缓存
  Future<int> getIOSMajorVersion() async {
    if (!Platform.isIOS) {
      return 0;
    }
    
    if (_cachedIOSVersion != null) {
      return _cachedIOSVersion!;
    }
    
    try {
      final version = await _channel.invokeMethod<int>('getIOSVersion');
      _cachedIOSVersion = version ?? 0;
      return _cachedIOSVersion!;
    } catch (e) {
      // 如果调用失败，返回 0（将回退到旧版样式）
      _cachedIOSVersion = 0;
      return 0;
    }
  }

  /// 初始化服务，预加载 iOS 版本信息
  Future<void> initialize() async {
    if (_initialized) return;
    
    if (Platform.isIOS) {
      await getIOSMajorVersion();
    }
    _initialized = true;
  }

  /// 检查是否为 iOS 26 或更高版本
  /// 
  /// 注意：此方法使用同步返回缓存值，需要先调用 [initialize] 或 [getIOSMajorVersion]
  bool get isIOS26OrAbove {
    if (!Platform.isIOS) {
      return false;
    }
    return (_cachedIOSVersion ?? 0) >= 26;
  }
  
  /// 同步检查是否为 iOS 平台
  bool get isIOS => Platform.isIOS;
}
