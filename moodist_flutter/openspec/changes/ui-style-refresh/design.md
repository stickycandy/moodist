## Context

当前 Moodist Flutter 应用使用 Material 3 默认主题，背景为纯黑/白色。应用的核心定位是白噪音/氛围音乐播放器，需要营造放松、沉浸的视觉体验。现有 UI 风格过于传统，与产品调性不够契合。

**现状分析**:
- `lib/main.dart`: 使用 `ThemeData` 配置，基于 teal 色种子生成色彩方案
- 所有页面使用标准 `Scaffold` + `AppBar` 结构
- 组件使用默认 Material 3 样式（Card、ExpansionTile、Slider 等）
- 已有 `LiquidGlassTabBar` 实现底部导航的液态玻璃效果

## Goals / Non-Goals

**Goals:**
- 创建可复用的渐变背景组件，支持深浅色模式
- 定义清新风格的主题扩展，覆盖核心组件样式
- 保持与现有 LiquidGlassTabBar 风格的一致性
- 最小化对现有业务逻辑的影响

**Non-Goals:**
- 不修改业务逻辑或数据层
- 不重构现有组件的功能逻辑
- 不引入新的状态管理机制
- 不支持用户自定义主题（未来迭代）

## Decisions

### 1. 渐变背景实现方案

**决定**: 创建 `GradientBackground` Widget，使用 `Container` + `LinearGradient` 实现

**理由**:
- 简单高效，Flutter 原生支持
- 易于适配深浅色模式
- 可通过 `Theme.of(context).brightness` 动态切换配色

**备选方案**:
- ~~使用 CustomPainter~~: 过度复杂，渐变效果无需自定义绘制
- ~~使用图片背景~~: 增加资源体积，灵活性差

### 2. 主题配置方案

**决定**: 创建 `AppTheme` 静态类，提供 `lightTheme` 和 `darkTheme`，通过 `ThemeData.copyWith()` 扩展默认主题

**理由**:
- 集中管理主题配置
- 可逐步覆盖组件样式
- 便于维护和调整

**配色方案**:
- 浅色模式: 渐变从淡青 (#E0F7FA) 到薄荷白 (#F0FFF4)
- 深色模式: 渐变从深青 (#004D40) 到深蓝绿 (#1A2E3B)

### 3. 组件样式覆盖

**决定**: 通过 `ThemeData` 的 `cardTheme`、`appBarTheme`、`sliderTheme` 等属性统一覆盖

**理由**:
- Material 3 提供完善的主题覆盖机制
- 无需修改每个组件的具体实现
- 保持代码整洁

**样式调整**:
- Card: 半透明白色/深色背景，轻微阴影，圆角增大
- AppBar: 透明背景，移除阴影
- Slider: 使用主题色，调整滑块大小
- Switch: 适配清新配色

### 4. 页面适配方案

**决定**: 在 `Scaffold.body` 外层包装 `GradientBackground`，而非修改 `Scaffold.backgroundColor`

**理由**:
- `Scaffold.backgroundColor` 只支持纯色
- 独立 Widget 便于控制渐变效果
- 可在 Stack 中与内容层叠

## Risks / Trade-offs

| 风险 | 缓解措施 |
|------|---------|
| 渐变背景可能影响文字可读性 | 使用半透明 Card 作为内容容器，确保足够对比度 |
| 深色模式配色需要调试 | 遵循 Material 3 深色模式指南，确保对比度达标 |
| 组件样式覆盖可能有遗漏 | 逐页面检查，建立视觉测试清单 |
| 性能影响（渐变绘制） | Flutter 渐变绘制高效，预计无显著影响 |
