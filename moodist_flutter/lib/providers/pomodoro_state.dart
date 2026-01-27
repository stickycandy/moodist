import 'dart:async';
import 'package:flutter/foundation.dart';

/// 番茄钟：25 分钟工作 + 5 分钟休息（简化版，仅状态）
class PomodoroState extends ChangeNotifier {
  bool _running = false;
  Timer? _timer;
  static const int workSeconds = 25 * 60;
  static const int restSeconds = 5 * 60;
  int _remainingSeconds = workSeconds;
  bool _isRest = false;

  bool get running => _running;
  int get remainingSeconds => _remainingSeconds;
  bool get isRest => _isRest;

  void setRunning(bool value) {
    if (_running == value) return;
    _running = value;
    if (_running) {
      _tick();
    } else {
      _timer?.cancel();
      _timer = null;
    }
    notifyListeners();
  }

  void _tick() {
    _timer?.cancel();
    void callback() {
      _remainingSeconds--;
      if (_remainingSeconds <= 0) {
        _isRest = !_isRest;
        _remainingSeconds = _isRest ? restSeconds : workSeconds;
      }
      notifyListeners();
      _timer = Timer(const Duration(seconds: 1), callback);
    }
    _timer = Timer(const Duration(seconds: 1), callback);
  }

  void reset() {
    _timer?.cancel();
    _timer = null;
    _remainingSeconds = workSeconds;
    _isRest = false;
    _running = false;
    notifyListeners();
  }

  String get displayMinutes => '${(_remainingSeconds / 60).floor()}';
  String get displaySeconds => '${_remainingSeconds % 60}'.padLeft(2, '0');

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
