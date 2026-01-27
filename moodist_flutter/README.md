# Moodist Flutter

与 [Moodist](https://github.com/remvze/moodist) Web 版功能对等的 **Flutter** 应用，支持 **iOS** 与 **Android**。

## 功能概览

- **环境音混音**：75+ 种环境音（自然、雨声、动物、城市、场景、交通、物品、白噪音、双耳节拍），多选混播、单独音量、收藏、持久化
- **预设**：保存/加载/重命名/删除当前声音组合为预设
- **分享**：分享当前声音组合（JSON），他人可导入
- **睡眠定时**：15 / 30 / 45 / 60 / 120 分钟后自动停止播放
- **番茄钟**：25 分钟专注 + 5 分钟休息，可开始/暂停/重置
- **记事本**：纯文本笔记，持久化，支持清空与撤销恢复
- **待办**：简单待办列表，增删改、完成勾选、持久化
- **隐私**：无数据上报，数据仅存本地（SharedPreferences）

## 环境要求

- Flutter SDK >= 3.2（建议用 stable channel）
- Xcode（iOS）、Android Studio / SDK（Android）

## 快速开始

### 1. 安装 Flutter 并生成平台工程

若尚未安装 Flutter，请先安装并配置好环境变量：

- [Flutter 官网](https://flutter.dev/docs/get-started/install)

在项目根目录执行（首次或克隆后建议执行一次）：

```bash
cd moodist_flutter
flutter pub get
flutter create . --platforms=ios,android
```

若已存在 `android/` 与 `ios/`，上述 `flutter create` 会保留已有代码并补全缺失文件。

### 2. 添加音频资源（否则预览/运行无声音）

**无音频时**：界面可操作，但点击播放不会出声，并可能看到提示「无法播放…请将 Web 版的 public/sounds/ 复制到…」。

将 Web 版 Moodist 的音频拷贝到 Flutter 项目的 `assets/sounds/` 下对应子目录：

- 源路径：`moodist/public/sounds/`  
- 目标路径：`moodist_flutter/assets/sounds/`  
- 子文件夹：`nature`, `rain`, `animals`, `urban`, `places`, `transport`, `things`, `noise`, `binaural`

在项目仓库根目录（同时包含 `moodist` 与 `moodist_flutter` 的上一级）执行一键复制：

```bash
cp -R moodist/public/sounds/* moodist_flutter/assets/sounds/
```

或在 `moodist_flutter` 目录下执行：

```bash
cp -R ../public/sounds/* assets/sounds/
```

复制后重新运行一次 `flutter run -d chrome`（或其它设备）即可播放。

### 3. 运行

```bash
flutter run
```

- 连接真机或启动模拟器后，可选择设备。
- 仅跑 Android：`flutter run -d android`
- 仅跑 iOS：`flutter run -d ios`

### 4. 发布构建

- Android release：`flutter build apk` 或 `flutter build appbundle`
- iOS release：`flutter build ios`，再在 Xcode 中完成签名与上传

## 项目结构（简要）

- `lib/main.dart`：入口、主题、底部导航与页面壳
- `lib/models/sound.dart`：声音与分类模型
- `lib/data/sound_catalog.dart`：声音目录（与 Web 版分类、ID 对应）
- `lib/providers/`：状态（声音、预设、笔记、待办、番茄钟），持久化在 SharedPreferences
- `lib/screens/`：声音、预设、睡眠定时、番茄钟、笔记、待办页面

## 与 Web 版对应关系

- 声音分类与 ID、资源路径与 Web 版 `src/data/sounds/` 对齐，便于复用同一套音频与分享数据。
- 预设、笔记、待办、睡眠定时、番茄钟等逻辑与 Web 版 Zustand store 行为一致，仅实现方式改为 Flutter + Provider。

## 许可证

与主项目 Moodist 一致（如 MIT）。第三方音频请遵循其各自授权（如 Pixabay、CC0 等）。
