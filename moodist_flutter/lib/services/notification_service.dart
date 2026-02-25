import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

/// 本地通知服务 - 用于睡眠定时器的可靠后台执行
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// 睡眠定时通知 ID
  static const int sleepTimerNotificationId = 1001;

  /// 睡眠定时触发时的回调
  Function()? onSleepTimerFired;

  /// 初始化通知服务
  Future<void> initialize() async {
    if (_initialized) return;

    // 初始化时区数据
    tz_data.initializeTimeZones();

    // iOS 配置
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    // Android 配置
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      iOS: iosSettings,
      android: androidSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    _initialized = true;
    if (kDebugMode) {
      print('NotificationService: Initialized');
    }
  }

  /// 请求通知权限（iOS）
  Future<bool> requestPermissions() async {
    if (!Platform.isIOS) return true;

    final result = await _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: false,
          sound: true,
        );

    return result ?? false;
  }

  /// 安排睡眠定时通知
  /// 
  /// 当定时到达时，系统会触发通知，即使 App 在后台也能执行
  Future<void> scheduleSleepTimerNotification(DateTime endTime) async {
    // 先取消之前的定时通知
    await cancelSleepTimerNotification();

    final now = DateTime.now();
    if (endTime.isBefore(now)) return;

    // iOS 通知详情
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: false, // 不显示 alert（静默处理）
      presentBadge: false,
      presentSound: false,
    );

    // Android 通知详情
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'sleep_timer_channel',
      '睡眠定时',
      channelDescription: '睡眠定时器通知',
      importance: Importance.low,
      priority: Priority.low,
      showWhen: false,
      playSound: false,
      enableVibration: false,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      iOS: iosDetails,
      android: androidDetails,
    );

    // 转换为时区感知的时间
    final scheduledDate = tz.TZDateTime.from(endTime, tz.local);

    await _notifications.zonedSchedule(
      sleepTimerNotificationId,
      'Moodist',
      '睡眠定时已结束',
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: null,
    );

    if (kDebugMode) {
      print('NotificationService: Scheduled sleep timer for $endTime');
    }
  }

  /// 取消睡眠定时通知
  Future<void> cancelSleepTimerNotification() async {
    await _notifications.cancel(sleepTimerNotificationId);
    if (kDebugMode) {
      print('NotificationService: Cancelled sleep timer notification');
    }
  }

  /// 处理通知响应
  void _onNotificationResponse(NotificationResponse response) {
    if (response.id == sleepTimerNotificationId) {
      if (kDebugMode) {
        print('NotificationService: Sleep timer notification triggered');
      }
      onSleepTimerFired?.call();
    }
  }

  /// 检查是否有待处理的睡眠定时通知
  Future<bool> hasPendingSleepTimerNotification() async {
    final pending = await _notifications.pendingNotificationRequests();
    return pending.any((n) => n.id == sleepTimerNotificationId);
  }
}