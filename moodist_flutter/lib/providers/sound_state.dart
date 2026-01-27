import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../data/sound_catalog.dart';
import '../models/sound.dart';
import 'asset_url_loader_stub.dart' if (dart.library.html) 'asset_url_loader_web.dart' as asset_loader;

/// 单音状态：是否选中、音量、是否收藏
class SoundEntry {
  SoundEntry({
    this.isSelected = false,
    this.volume = 0.5,
    this.isFavorite = false,
  });
  bool isSelected;
  double volume;
  bool isFavorite;
  Map<String, dynamic> toJson() => {
        's': isSelected ? 1 : 0,
        'v': volume,
        'f': isFavorite ? 1 : 0,
      };
  static SoundEntry fromJson(Map<String, dynamic>? j) {
    if (j == null) return SoundEntry();
    return SoundEntry(
      isSelected: (j['s'] ?? 0) == 1,
      volume: (j['v'] ?? 0.5).toDouble(),
      isFavorite: (j['f'] ?? 0) == 1,
    );
  }
}

/// 声音播放与混音状态（与 Web 版逻辑一致）
class SoundState extends ChangeNotifier {
  SoundState() {
    _loadFromPrefs();
    _initCatalog();
  }

  static const _prefsKey = 'moodist_sound_state';
  final Map<String, SoundEntry> _entries = {};
  final Map<String, AudioPlayer> _players = {};
  final List<SoundCategory> _categories = getSoundCategories();
  double _globalVolume = 1.0;
  bool _isPlaying = false;
  bool _locked = false;
  Timer? _sleepTimer;
  String? _lastPlayError;

  List<SoundCategory> get categories => _categories;
  /// 播放失败时的提示，显示后可由 [clearPlayError] 清空
  String? get lastPlayError => _lastPlayError;
  void clearPlayError() {
    _lastPlayError = null;
    notifyListeners();
  }

  double get globalVolume => _globalVolume;
  bool get isPlaying => _isPlaying;
  bool get locked => _locked;
  bool get noSelected =>
      _entries.values.every((e) => !e.isSelected);

  SoundEntry entry(String soundId) =>
      _entries[soundId] ?? SoundEntry();

  void _initCatalog() {
    for (final cat in _categories) {
      for (final s in cat.sounds) {
        if (!_entries.containsKey(s.id)) {
          _entries[s.id] = SoundEntry();
        }
      }
    }
    notifyListeners();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null) return;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>?;
      if (map == null) return;
      for (final e in map.entries) {
        final v = e.value;
        if (v is Map<String, dynamic>) {
          _entries[e.key] = SoundEntry.fromJson(v);
        }
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _saveToPrefs() async {
    final map = <String, dynamic>{};
    for (final e in _entries.entries) {
      map[e.key] = e.value.toJson();
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(map));
  }

  void setGlobalVolume(double v) {
    _globalVolume = v.clamp(0.0, 1.0);
    _updateAllVolumes();
    notifyListeners();
  }

  void _updateAllVolumes() {
    for (final p in _players.entries) {
      final ent = _entries[p.key];
      if (ent == null || !ent.isSelected) continue;
      p.value.setVolume(ent.volume * _globalVolume);
    }
  }

  void select(String id) {
    if (_entries[id] == null) return;
    _entries[id]!.isSelected = true;
    _playSound(id);
    _saveToPrefs();
    notifyListeners();
  }

  void unselect(String id) {
    _entries[id]?.isSelected = false;
    _stopSound(id);
    _saveToPrefs();
    notifyListeners();
  }

  void setVolume(String id, double volume) {
    final ent = _entries[id];
    if (ent == null) return;
    ent.volume = volume.clamp(0.0, 1.0);
    final p = _players[id];
    if (p != null && ent.isSelected) {
      p.setVolume(ent.volume * _globalVolume);
    }
    _saveToPrefs();
    notifyListeners();
  }

  void toggleFavorite(String id) {
    final ent = _entries[id];
    if (ent == null) return;
    ent.isFavorite = !ent.isFavorite;
    _saveToPrefs();
    notifyListeners();
  }

  List<String> getFavorites() =>
      _entries.entries.where((e) => e.value.isFavorite).map((e) => e.key).toList();

  void togglePlay() {
    _isPlaying = !_isPlaying;
    if (_isPlaying) {
      for (final e in _entries.entries) {
        if (e.value.isSelected) _playSound(e.key);
      }
    } else {
      for (final id in _players.keys) {
        _players[id]?.stop();
      }
    }
    notifyListeners();
  }

  void play() {
    _isPlaying = true;
    for (final e in _entries.entries) {
      if (e.value.isSelected) _playSound(e.key);
    }
    notifyListeners();
  }

  void pause() {
    _isPlaying = false;
    for (final p in _players.values) {
      p.stop();
    }
    notifyListeners();
  }

  void unselectAll() {
    for (final ent in _entries.values) {
      ent.isSelected = false;
      ent.volume = 0.5;
    }
    for (final p in _players.values) {
      p.stop();
    }
    _saveToPrefs();
    notifyListeners();
  }

  /// 用预设覆盖当前选择（用于分享或预设加载）
  void applySounds(Map<String, double> sounds) {
    unselectAll();
    for (final e in sounds.entries) {
      if (_entries[e.key] != null) {
        _entries[e.key]!.isSelected = true;
        _entries[e.key]!.volume = e.value;
      }
    }
    if (_isPlaying) {
      for (final id in sounds.keys) {
        _playSound(id);
      }
    }
    _saveToPrefs();
    notifyListeners();
  }

  void _playSound(String id) async {
    Sound? sound;
    for (final cat in _categories) {
      for (final s in cat.sounds) {
        if (s.id == id) { sound = s; break; }
      }
      if (sound != null) break;
    }
    if (sound == null) return;
    final ent = _entries[id]!;
    var player = _players[id];
    if (player == null) {
      player = AudioPlayer();
      await player.setReleaseMode(ReleaseMode.loop);
      _players[id] = player;
    }
    try {
      _lastPlayError = null;
      if (kIsWeb) {
        final url = await asset_loader.getAssetAudioUrl(sound.assetPath);
        if (url != null) {
          await player.setSource(UrlSource(url));
        } else {
          await player.setSource(AssetSource(sound.assetPath));
        }
      } else {
        await player.setSource(AssetSource(sound.assetPath));
      }
      await player.setVolume(ent.volume * _globalVolume);
      await player.resume();
    } catch (e, st) {
      _lastPlayError = '无法播放「${sound.label}」。请将 Web 版的 public/sounds/ 复制到 moodist_flutter/assets/sounds/ 对应子目录。';
      if (kDebugMode) {
        // ignore: avoid_print
        print('SoundState._playSound failed: $e\n$st');
      }
      notifyListeners();
    }
  }

  void _stopSound(String id) {
    _players[id]?.stop();
  }

  void lock() {
    _locked = true;
    notifyListeners();
  }

  void unlock() {
    _locked = false;
    notifyListeners();
  }

  void setSleepTimer(Duration? duration) {
    _sleepTimer?.cancel();
    if (duration == null || duration.inSeconds <= 0) {
      _sleepTimer = null;
      notifyListeners();
      return;
    }
    _sleepTimer = Timer(duration, () {
      pause();
      _sleepTimer = null;
      notifyListeners();
    });
    notifyListeners();
  }

  void cancelSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    notifyListeners();
  }

  bool get hasSleepTimer {
    return _sleepTimer != null;
  }

  @override
  void dispose() {
    _sleepTimer?.cancel();
    if (kIsWeb) {
      asset_loader.revokeAllAssetAudioUrls();
    }
    for (final p in _players.values) {
      p.dispose();
    }
    super.dispose();
  }
}

