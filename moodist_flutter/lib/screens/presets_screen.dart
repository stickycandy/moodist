import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sound_state.dart';
import '../providers/preset_state.dart';
import '../widgets/center_toast.dart';

class PresetsScreen extends StatelessWidget {
  const PresetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('预设'),
        centerTitle: true,
      ),
      body: Consumer<PresetState>(
        builder: (context, presetState, _) {
          final list = presetState.presets;
          if (list.isEmpty) {
            return _EmptyPresets(theme: theme);
          }
          return _PresetsList(
            presets: list,
            presetState: presetState,
            theme: theme,
          );
        },
      ),
    );
  }

}

class _EmptyPresets extends StatelessWidget {
  const _EmptyPresets({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.bookmark_border_rounded,
                size: 56,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '暂无预设',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '在「声音」页选好音效后，点击保存即可将当前组合存为预设',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PresetsList extends StatelessWidget {
  const _PresetsList({
    required this.presets,
    required this.presetState,
    required this.theme,
  });

  final List<Preset> presets;
  final PresetState presetState;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      itemCount: presets.length,
      itemBuilder: (context, i) {
        final p = presets[i];
        final isLast = i == presets.length - 1;
        return Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
          child: _PresetCard(
            preset: p,
            presetState: presetState,
            onEdit: () => _editName(context, presetState, p.id, p.label),
            onDelete: () => _confirmDelete(context, presetState, p.id, p.label),
          ),
        );
      },
    );
  }

  void _editName(BuildContext context, PresetState presetState, String id, String current) {
    final controller = TextEditingController(text: current);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('重命名预设'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: '预设名称',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          FilledButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                presetState.changeName(id, name);
                Navigator.pop(ctx);
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, PresetState presetState, String id, String label) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除预设'),
        content: Text('确定删除「$label」？删除后无法恢复。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(ctx).colorScheme.error),
            onPressed: () {
              presetState.deletePreset(id);
              Navigator.pop(ctx);
              if (context.mounted) {
                CenterToast.show(context, message: '已删除', icon: Icons.delete_outline);
              }
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}

class _PresetCard extends StatelessWidget {
  const _PresetCard({
    required this.preset,
    required this.presetState,
    required this.onEdit,
    required this.onDelete,
  });

  final Preset preset;
  final PresetState presetState;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final count = preset.sounds.length;

    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
          context.read<SoundState>().applySounds(preset.sounds, presetName: preset.label);
          context.read<SoundState>().play();
          CenterToast.show(context, message: '已加载并播放', icon: Icons.play_circle_outline);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.queue_music_rounded,
                  color: theme.colorScheme.onPrimaryContainer,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      preset.label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      count == 0 ? '未包含声音' : '$count 个声音',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.play_circle_fill_rounded,
                color: theme.colorScheme.primary,
                size: 40,
              ),
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                icon: Icon(Icons.more_vert, color: theme.colorScheme.onSurfaceVariant),
                onSelected: (value) {
                  if (value == 'edit') onEdit();
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (ctx) {
                  final menuTheme = Theme.of(ctx);
                  return [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 20),
                          SizedBox(width: 12),
                          Text('重命名'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, size: 20, color: menuTheme.colorScheme.error),
                          const SizedBox(width: 12),
                          Text('删除', style: TextStyle(color: menuTheme.colorScheme.error)),
                        ],
                      ),
                    ),
                  ];
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
