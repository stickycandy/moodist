/// 单个环境音
class Sound {
  const Sound({
    required this.id,
    required this.label,
    required this.assetPath,
    this.iconName = 'music_note',
  });
  final String id;
  final String label;
  final String assetPath;
  final String iconName;
}

/// 声音分类（与 Web 版一致）
class SoundCategory {
  const SoundCategory({
    required this.id,
    required this.title,
    required this.sounds,
    this.iconName = 'folder',
  });
  final String id;
  final String title;
  final List<Sound> sounds;
  final String iconName;
}
