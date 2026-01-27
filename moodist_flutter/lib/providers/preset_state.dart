import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// 预设：名称 + soundId -> volume
class Preset {
  Preset({required this.id, required this.label, required this.sounds});
  final String id;
  String label;
  Map<String, double> sounds;
  Map<String, dynamic> toJson() => {'id': id, 'label': label, 'sounds': sounds};
  static Preset fromJson(Map<String, dynamic> j) => Preset(
        id: j['id'] as String? ?? const Uuid().v4(),
        label: j['label'] as String? ?? '',
        sounds: Map<String, double>.from((j['sounds'] as Map?) ?? {}),
      );
}

class PresetState extends ChangeNotifier {
  static const _key = 'moodist_presets';
  final List<Preset> _presets = [];
  final _uuid = const Uuid();

  List<Preset> get presets => List.unmodifiable(_presets);

  PresetState() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List<dynamic>?;
        if (list != null) {
          _presets.clear();
          for (final e in list) {
            if (e is Map<String, dynamic>) _presets.add(Preset.fromJson(e));
          }
        }
      } catch (_) {}
    }
    notifyListeners();
  }

  Future<void> _save() async {
    final list = _presets.map((p) => p.toJson()).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(list));
    notifyListeners();
  }

  void addPreset(String label, Map<String, double> sounds) {
    _presets.insert(0, Preset(id: _uuid.v4(), label: label, sounds: Map.from(sounds)));
    _save();
  }

  void changeName(String id, String newName) {
    final i = _presets.indexWhere((p) => p.id == id);
    if (i >= 0) {
      _presets[i].label = newName;
      _save();
    }
  }

  void deletePreset(String id) {
    _presets.removeWhere((p) => p.id == id);
    _save();
  }
}
