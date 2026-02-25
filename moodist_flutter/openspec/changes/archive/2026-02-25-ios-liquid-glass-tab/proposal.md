## Why

iOS 26 引入了全新的「液态玻璃」(Liquid Glass) 设计语言，包括重新设计的 Tab Bar 组件。为了让 Moodist 在 iOS 26 设备上提供原生级体验并与系统视觉风格保持一致，需要将底部导航栏升级为支持 iOS 26 液态玻璃效果的样式。这将提升应用的现代感和用户体验，同时保持在旧版 iOS 上的兼容性。

## What Changes

- **新增 iOS 26 液态玻璃 Tab Bar 组件**：创建自定义的 `LiquidGlassTabBar` 组件，实现 iOS 26 的毛玻璃材质、动态模糊和浮动胶囊指示器效果
- **平台条件渲染**：在 iOS 26+ 设备上使用新的液态玻璃 Tab Bar，其他平台继续使用 Material 3 的 `NavigationBar`
- **动画增强**：添加平滑的 Tab 切换动画，包括指示器滑动、图标缩放和颜色渐变
- **主题适配**：支持 Light/Dark 模式下的液态玻璃效果自动调整

## Capabilities

### New Capabilities
- `liquid-glass-tab-bar`: iOS 26 风格的液态玻璃底部导航栏组件，包含毛玻璃背景、浮动指示器和流畅动画

### Modified Capabilities
<!-- 无需修改现有 spec -->

## Impact

- **代码影响**：
  - `lib/main.dart` - 替换 `NavigationBar` 为条件渲染逻辑
  - 新增 `lib/widgets/liquid_glass_tab_bar.dart` - 液态玻璃 Tab Bar 组件
- **依赖**：
  - 可能需要 `dart:ui` 的 `ImageFilter` 进行模糊效果
  - 需要平台版本检测 (`Platform.operatingSystemVersion`)
- **兼容性**：
  - iOS 26+：完整液态玻璃效果
  - iOS 18-25：回退到标准 `CupertinoTabBar`
  - Android/其他：继续使用 Material `NavigationBar`
