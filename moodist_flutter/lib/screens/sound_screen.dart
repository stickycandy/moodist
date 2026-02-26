import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/sound.dart';
import '../data/sound_catalog.dart';
import '../providers/sound_state.dart';
import '../providers/preset_state.dart';
import '../widgets/center_toast.dart';

class SoundScreen extends StatelessWidget {
  const SoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ting'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareSelection(context),
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => _showSavePresetDialog(context),
          ),
        ],
      ),
      body: Consumer<SoundState>(
        builder: (context, state, _) {
          final err = state.lastPlayError;
          if (err != null && context.mounted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!context.mounted) return;
              CenterToast.show(
                context,
                message: err,
                icon: Icons.error_outline,
                duration: const Duration(seconds: 3),
              );
              state.clearPlayError();
            });
          }
          return Column(
            children: [
              _GlobalControls(state: state),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 100),
                  children: [
                    Slider(
                      value: state.globalVolume,
                      onChanged: state.locked ? null : (v) => state.setGlobalVolume(v),
                      divisions: 20,
                      label: '总音量',
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('总音量', style: TextStyle(fontSize: 12)),
                    ),
                    ...state.categories.map((cat) => _CategorySection(category: cat, state: state)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _shareSelection(BuildContext context) {
    final state = context.read<SoundState>();
    final map = <String, double>{};
    for (final e in state.categories) {
      for (final s in e.sounds) {
        final ent = state.entry(s.id);
        if (ent.isSelected && ent.volume > 0) map[s.id] = ent.volume;
      }
    }
    if (map.isEmpty) {
      CenterToast.show(context, message: '请先选择一些声音', icon: Icons.music_off_outlined);
      return;
    }
    Share.share('Ting 声音组合：\n${jsonEncode(map)}\n可在 Ting 中通过分享链接导入。');
  }

  void _showSavePresetDialog(BuildContext context) {
    final soundState = context.read<SoundState>();
    final presetState = context.read<PresetState>();
    final map = <String, double>{};
    for (final cat in soundState.categories) {
      for (final s in cat.sounds) {
        final ent = soundState.entry(s.id);
        if (ent.isSelected && ent.volume > 0) map[s.id] = ent.volume;
      }
    }
    if (map.isEmpty) {
      CenterToast.show(context, message: '请先选择一些声音', icon: Icons.music_off_outlined);
      return;
    }
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('保存预设'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: '预设名称'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          FilledButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                presetState.addPreset(name, map);
                Navigator.pop(ctx);
                CenterToast.show(context, message: '已保存', icon: Icons.check_circle_outline);
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
}

class _GlobalControls extends StatelessWidget {
  const _GlobalControls({required this.state});

  final SoundState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton.filled(
            icon: Icon(state.isPlaying ? Icons.pause : Icons.play_arrow),
            onPressed: state.locked ? null : () => state.togglePlay(),
          ),
          TextButton(
            onPressed: state.locked || state.noSelected ? null : () => state.unselectAll(),
            child: const Text('全部取消'),
          ),
        ],
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({required this.category, required this.state});

  final SoundCategory category;
  final SoundState state;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: Icon(_iconData(category.iconName)),
        title: Text(category.title),
        children: category.sounds
            .map((s) => _SoundTile(sound: s, entry: state.entry(s.id), state: state))
            .toList(),
      ),
    );
  }

  IconData _iconData(String name) {
    switch (name) {
      case 'grass':
        return Icons.grass;
      case 'water_drop':
        return Icons.water_drop;
      case 'pets':
        return Icons.pets;
      case 'location_city':
        return Icons.location_city;
      case 'place':
        return Icons.place;
      case 'directions_car':
        return Icons.directions_car;
      case 'tune':
        return Icons.tune;
      case 'graphic_eq':
        return Icons.graphic_eq;
      case 'hearing':
        return Icons.hearing;
      default:
        return Icons.music_note;
    }
  }
}

class _SoundTile extends StatelessWidget {
  const _SoundTile({required this.sound, required this.entry, required this.state});

  final Sound sound;
  final SoundEntry entry;
  final SoundState state;

  @override
  Widget build(BuildContext context) {
    final locked = state.locked;
    return ListTile(
      leading: Icon(
        entry.isFavorite ? Icons.star : Icons.star_border,
        color: entry.isFavorite ? Colors.amber : null,
      ),
      title: Text(sound.label),
      subtitle: Slider(
        value: entry.volume,
        onChanged: locked ? null : (v) => state.setVolume(sound.id, v),
        divisions: 20,
      ),
      trailing: Switch(
        value: entry.isSelected,
        onChanged: locked
            ? null
            : (v) {
                if (v) {
                  state.select(sound.id);
                } else {
                  state.unselect(sound.id);
                }
              },
      ),
      onTap: () {
        if (locked) return;
        if (entry.isSelected) {
          state.unselect(sound.id);
        } else {
          state.select(sound.id);
        }
      },
      onLongPress: () => state.toggleFavorite(sound.id),
    );
  }
}