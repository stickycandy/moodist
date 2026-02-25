## 1. iOS 原生层配置

- [x] 1.1 在 `ios/Runner/AppDelegate.swift` 中添加 Platform Channel 方法，返回 iOS 主版本号
- [x] 1.2 定义 MethodChannel 名称为 `com.moodist/platform_info`，方法名为 `getIOSVersion`

## 2. Flutter 平台服务

- [x] 2.1 创建 `lib/services/platform_service.dart`，封装 Platform Channel 调用
- [x] 2.2 实现 `getIOSMajorVersion()` 方法，调用原生并返回 int
- [x] 2.3 添加版本号缓存机制，避免重复原生调用
- [x] 2.4 实现 `isIOS26OrAbove` getter，根据缓存版本判断

## 3. Liquid Glass Tab Bar 组件

- [x] 3.1 创建 `lib/widgets/liquid_glass_tab_bar.dart` 文件
- [x] 3.2 定义 `LiquidGlassTabBar` StatefulWidget，接收 `selectedIndex`、`onTap`、`items` 参数
- [x] 3.3 定义 `LiquidGlassTabItem` 数据类，包含 `icon` 和 `label` 属性

## 4. 毛玻璃背景效果

- [x] 4.1 使用 `ClipRect` + `BackdropFilter` 实现模糊背景
- [x] 4.2 根据 `Theme.of(context).brightness` 切换 Light/Dark 模式配色
- [x] 4.3 Light 模式：白色 70% 透明度，25px 模糊
- [x] 4.4 Dark 模式：黑色 50% 透明度，30px 模糊

## 5. 浮动胶囊指示器

- [x] 5.1 使用 `AnimatedPositioned` 实现指示器水平滑动动画
- [x] 5.2 使用 `AnimatedContainer` 实现胶囊形状和颜色渐变
- [x] 5.3 设置动画时长 300ms，曲线 `Curves.easeOutCubic`
- [x] 5.4 指示器使用系统主题色填充，带圆角（pill shape）

## 6. Tab 图标与标签

- [x] 6.1 布局 5 个 Tab 项，使用 `Row` + `Expanded` 均分宽度
- [x] 6.2 每个 Tab 使用 `Column` 垂直排列图标和标签
- [x] 6.3 实现图标选中时 10% 放大动画（`AnimatedScale`）
- [x] 6.4 实现图标颜色渐变动画（`AnimatedDefaultTextStyle` 或 `ColorTween`）

## 7. Safe Area 处理

- [x] 7.1 使用 `MediaQuery.of(context).padding.bottom` 获取底部安全区
- [x] 7.2 Tab Bar 内容区使用 `SafeArea` 或手动 padding 处理
- [x] 7.3 背景色/模糊效果延伸到安全区底部

## 8. Adaptive Tab Bar 包装组件

- [x] 8.1 创建 `lib/widgets/adaptive_tab_bar.dart`
- [x] 8.2 在 `build` 中根据 `Platform.isIOS` 和 `isIOS26OrAbove` 条件判断
- [x] 8.3 iOS 26+：渲染 `LiquidGlassTabBar`
- [x] 8.4 iOS <26：渲染 `CupertinoTabBar`
- [x] 8.5 Android/其他：渲染 Material `NavigationBar`

## 9. 主页面集成

- [x] 9.1 修改 `lib/main.dart`，将 `NavigationBar` 替换为 `AdaptiveTabBar`
- [x] 9.2 传递 `_tabs` 配置和回调函数
- [x] 9.3 确保 `IndexedStack` 与新 Tab Bar 正确联动

## 10. 测试验证

- [x] 10.1 在 iOS 26 模拟器上验证 Liquid Glass 效果
- [x] 10.2 验证 Light/Dark 模式切换
- [x] 10.3 验证 Tab 切换动画流畅度
- [x] 10.4 在旧版 iOS 模拟器上验证回退到 CupertinoTabBar
- [x] 10.5 在 Android 模拟器上验证保持 Material 风格
