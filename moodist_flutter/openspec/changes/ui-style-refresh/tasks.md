## 1. 基础组件创建

- [x] 1.1 创建 `lib/widgets/gradient_background.dart`，实现 GradientBackground Widget
- [x] 1.2 创建 `lib/theme/app_theme.dart`，定义 AppTheme 静态类
- [x] 1.3 在 AppTheme 中实现 lightTheme 配置
- [x] 1.4 在 AppTheme 中实现 darkTheme 配置

## 2. 主题配置

- [x] 2.1 配置 cardTheme：半透明背景、16px 圆角、轻微阴影
- [x] 2.2 配置 appBarTheme：透明背景、无阴影
- [x] 2.3 配置 sliderTheme：主题色、现代化滑块样式
- [x] 2.4 配置 switchTheme：主题色系开关样式
- [x] 2.5 配置 dialogTheme：半透明背景、20px 圆角
- [x] 2.6 配置 scaffoldBackgroundColor 为透明

## 3. 应用主题

- [x] 3.1 修改 `lib/main.dart`，引入 AppTheme 替换原有 ThemeData
- [x] 3.2 在 MainShell 中添加 GradientBackground 作为全局背景

## 4. 页面适配

- [x] 4.1 更新 SoundScreen 页面，确保与新主题兼容
- [x] 4.2 更新 PresetsScreen 页面，确保与新主题兼容
- [x] 4.3 更新 SleepTimerScreen 页面，确保与新主题兼容
- [x] 4.4 更新 PomodoroScreen 页面，确保与新主题兼容
- [x] 4.5 更新 TodoScreen 页面，确保与新主题兼容

## 5. 视觉验证

- [ ] 5.1 验证浅色模式下渐变背景显示效果
- [ ] 5.2 验证深色模式下渐变背景显示效果
- [ ] 5.3 验证横屏模式下布局适配
- [ ] 5.4 验证 Card、Slider、Switch 等组件样式
- [ ] 5.5 验证对话框样式