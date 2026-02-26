## ADDED Requirements

### Requirement: GradientBackground Widget 提供渐变背景容器
系统 SHALL 提供 `GradientBackground` Widget，作为页面内容的背景容器，渲染半透明渐变效果。

#### Scenario: 浅色模式下显示清新渐变
- **WHEN** 系统处于浅色模式
- **THEN** 背景 SHALL 显示从淡青到薄荷白的垂直渐变效果

#### Scenario: 深色模式下显示沉稳渐变
- **WHEN** 系统处于深色模式
- **THEN** 背景 SHALL 显示从深青到深蓝绿的垂直渐变效果

### Requirement: GradientBackground 支持包裹子组件
`GradientBackground` Widget SHALL 接受 `child` 参数，将子组件渲染在渐变背景之上。

#### Scenario: 内容层叠在渐变背景上
- **WHEN** 使用 `GradientBackground` 包裹页面内容
- **THEN** 子组件 SHALL 显示在渐变背景的上层

### Requirement: GradientBackground 自适应屏幕尺寸
`GradientBackground` Widget SHALL 自动填充父容器的全部可用空间。

#### Scenario: 横屏模式下渐变背景铺满
- **WHEN** 设备处于横屏模式
- **THEN** 渐变背景 SHALL 铺满整个屏幕区域

#### Scenario: 竖屏模式下渐变背景铺满
- **WHEN** 设备处于竖屏模式
- **THEN** 渐变背景 SHALL 铺满整个屏幕区域

### Requirement: GradientBackground 支持可选透明度配置
`GradientBackground` Widget SHALL 支持可选的 `opacity` 参数（默认值 1.0），控制整体渐变的不透明度。

#### Scenario: 使用默认透明度
- **WHEN** 未指定 `opacity` 参数
- **THEN** 渐变背景 SHALL 以完全不透明（opacity=1.0）显示

#### Scenario: 使用自定义透明度
- **WHEN** 指定 `opacity` 参数为 0.8
- **THEN** 渐变背景 SHALL 以 80% 不透明度显示
