## Why

当前应用使用纯黑/白色背景，视觉效果较为传统单调。为了提升用户体验，需要将 UI 风格升级为更现代、清新的设计，使用半透明渐变背景和轻量化的操作控件，营造更沉浸、舒适的视觉氛围，与白噪音/氛围音乐应用的放松主题更加契合。

## What Changes

- 移除全局纯黑/白色背景，改用半透明渐变背景（支持深浅色模式）
- 创建统一的渐变背景 Widget，可在所有页面复用
- 更新 AppBar 样式为透明/半透明，与渐变背景融合
- 更新 Card、ExpansionTile、ListTile 等组件的视觉风格为清新、轻量化设计
- 优化按钮、Switch、Slider 等交互控件的颜色和样式
- 调整整体色彩方案，使用更柔和、清新的配色（如浅青、淡蓝、米白等）
- 确保深色模式下也保持一致的渐变风格

## Capabilities

### New Capabilities
- `gradient-background`: 提供可复用的半透明渐变背景组件，支持深浅色模式自适应
- `fresh-theme`: 定义清新风格的主题配置，包括颜色、组件样式覆盖等

### Modified Capabilities
<!-- 无现有 spec 需要修改 -->

## Impact

- **UI 层**: `lib/main.dart` 的 ThemeData 配置需要更新
- **所有页面**: `lib/screens/` 下的 5 个页面需要应用新背景和组件样式
- **组件**: `lib/widgets/` 下的组件可能需要调整以适配新主题
- **无 API 变更**: 纯 UI 层改动，不影响业务逻辑和数据层
