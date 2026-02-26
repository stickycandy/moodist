## ADDED Requirements

### Requirement: AppTheme 提供清新风格的浅色主题
系统 SHALL 提供 `AppTheme.lightTheme` 静态属性，返回配置好清新风格的 `ThemeData` 实例。

#### Scenario: 浅色主题使用清新配色方案
- **WHEN** 应用使用 `AppTheme.lightTheme`
- **THEN** 主题色系 SHALL 基于青绿色（teal）生成，整体风格清新淡雅

#### Scenario: 浅色主题 AppBar 透明
- **WHEN** 应用使用 `AppTheme.lightTheme`
- **THEN** AppBar SHALL 具有透明背景且无阴影

### Requirement: AppTheme 提供清新风格的深色主题
系统 SHALL 提供 `AppTheme.darkTheme` 静态属性，返回配置好清新风格的 `ThemeData` 实例。

#### Scenario: 深色主题使用沉稳配色方案
- **WHEN** 应用使用 `AppTheme.darkTheme`
- **THEN** 主题色系 SHALL 基于青绿色（teal）生成，整体风格沉稳柔和

#### Scenario: 深色主题 AppBar 透明
- **WHEN** 应用使用 `AppTheme.darkTheme`
- **THEN** AppBar SHALL 具有透明背景且无阴影

### Requirement: Card 组件样式清新化
`AppTheme` SHALL 覆盖 `cardTheme`，使 Card 组件呈现半透明、圆角更大的清新风格。

#### Scenario: 浅色模式下 Card 半透明
- **WHEN** 系统处于浅色模式
- **THEN** Card 背景 SHALL 为半透明白色（约 80% 不透明度）

#### Scenario: 深色模式下 Card 半透明
- **WHEN** 系统处于深色模式
- **THEN** Card 背景 SHALL 为半透明深色（约 70% 不透明度）

#### Scenario: Card 圆角增大
- **WHEN** 应用使用 AppTheme
- **THEN** Card 圆角 SHALL 为 16px 或更大

### Requirement: Slider 组件样式清新化
`AppTheme` SHALL 覆盖 `sliderTheme`，使 Slider 组件呈现与整体风格一致的清新样式。

#### Scenario: Slider 使用主题色
- **WHEN** 应用使用 AppTheme
- **THEN** Slider 激活部分 SHALL 使用主题色（teal 系）

#### Scenario: Slider 滑块样式现代化
- **WHEN** 应用使用 AppTheme
- **THEN** Slider 滑块 SHALL 具有适当大小和阴影效果

### Requirement: Switch 组件样式清新化
`AppTheme` SHALL 覆盖 `switchTheme`，使 Switch 组件呈现与整体风格一致的清新样式。

#### Scenario: Switch 开启状态使用主题色
- **WHEN** Switch 处于开启状态
- **THEN** Switch 轨道和滑块 SHALL 使用主题色系

### Requirement: Scaffold 背景透明化
`AppTheme` SHALL 配置 `scaffoldBackgroundColor` 为透明，以便 `GradientBackground` 可见。

#### Scenario: Scaffold 背景透明
- **WHEN** 应用使用 AppTheme
- **THEN** Scaffold 默认背景 SHALL 为透明色

### Requirement: 对话框样式清新化
`AppTheme` SHALL 覆盖 `dialogTheme`，使对话框呈现与整体风格一致的清新样式。

#### Scenario: 对话框使用半透明背景
- **WHEN** 显示 AlertDialog
- **THEN** 对话框背景 SHALL 为半透明效果

#### Scenario: 对话框圆角增大
- **WHEN** 显示 AlertDialog
- **THEN** 对话框圆角 SHALL 为 20px 或更大
