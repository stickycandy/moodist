## Context

当前 Moodist 使用 Flutter 的 Material 3 `NavigationBar` 组件作为底部导航。该组件在 Android 上表现良好，但在 iOS 26 设备上与系统的新「液态玻璃」设计语言存在视觉差异。

iOS 26 的 Tab Bar 特点：
- 半透明毛玻璃背景（Frosted Glass）
- 动态模糊效果（Blur）随内容变化
- 浮动胶囊形指示器
- 流畅的弹性动画

当前状态：
- `lib/main.dart` 中使用 `NavigationBar` 组件
- 5 个 Tab：声音、预设、睡眠定时、番茄钟、待办

## Goals / Non-Goals

**Goals:**
- 在 iOS 26+ 设备上呈现原生液态玻璃风格的 Tab Bar
- 保持与旧版 iOS 和 Android 的完全兼容
- 实现平滑的 Tab 切换动画
- 支持 Light/Dark 模式自动适配
- 代码可维护，便于未来系统升级时调整

**Non-Goals:**
- 不在 Android 上模拟 iOS 风格（Android 保持 Material Design）
- 不实现完整的 iOS 系统级动态模糊（性能考虑，使用静态模糊近似）
- 不支持自定义 Tab Bar 位置（仅底部）
- 暂不实现 Tab Bar 隐藏/显示动画

## Decisions

### Decision 1: 组件架构 - 使用独立的 Platform-Aware Wrapper

**选择**: 创建 `AdaptiveTabBar` 组件，内部根据平台条件渲染不同实现

**理由**:
- 单一入口点，调用方无需关心平台差异
- 便于测试和维护
- 未来添加其他平台样式时扩展性好

**替代方案考虑**:
- 直接在 `main.dart` 中条件判断 → 代码耦合，不利于复用
- 使用 Flutter 的 `Platform` widget → 不支持 iOS 版本检测

### Decision 2: 毛玻璃效果实现 - ClipRect + BackdropFilter

**选择**: 使用 `ClipRect` + `BackdropFilter` 搭配 `ImageFilter.blur()`

**理由**:
- Flutter 原生支持，无需额外依赖
- 性能可接受（模糊半径控制在 20-30）
- iOS 上利用 Metal 渲染，效果接近原生

**替代方案考虑**:
- 使用 `flutter_blur` 等三方库 → 增加依赖，维护风险
- 使用 `CupertinoTabBar` → 不支持自定义毛玻璃强度

### Decision 3: 浮动指示器动画 - AnimatedPositioned + AnimatedContainer

**选择**: 组合使用 `AnimatedPositioned` 控制位置 + `AnimatedContainer` 控制大小/样式

**理由**:
- 隐式动画，代码简洁
- 自动处理中断动画的平滑过渡
- `Curves.easeOutCubic` 贴近 iOS 原生弹性感

**替代方案考虑**:
- 显式 `AnimationController` → 更精细控制，但代码复杂
- `Hero` 动画 → 不适用于同一页面内元素

### Decision 4: iOS 版本检测 - Platform Channel

**选择**: 通过 MethodChannel 调用原生代码获取 iOS 版本号

**理由**:
- `Platform.operatingSystemVersion` 返回格式不统一，解析困难
- 原生调用一次后缓存结果，性能影响可忽略
- 精确获取主版本号用于条件判断

**替代方案考虑**:
- 解析 `Platform.operatingSystemVersion` 字符串 → 格式可能变化，不可靠
- 使用 `device_info_plus` 插件 → 引入额外依赖

### Decision 5: 颜色与透明度 - 基于主题动态计算

**选择**: 根据 `Theme.of(context).brightness` 动态调整背景色和透明度

| 模式 | 背景色 | 透明度 | 模糊半径 |
|------|--------|--------|----------|
| Light | White | 0.7 | 25 |
| Dark | Black | 0.5 | 30 |

**理由**:
- 贴近 iOS 26 原生效果
- 适配系统外观设置
- 无需额外的主题配置

## Risks / Trade-offs

| Risk | Impact | Mitigation |
|------|--------|------------|
| **BackdropFilter 性能问题** | 低端设备卡顿 | 检测设备性能，必要时降低模糊半径或禁用模糊 |
| **iOS 版本检测失败** | 回退到默认样式 | 捕获异常，默认返回 false |
| **未来 iOS 更新改变设计语言** | 需要调整组件 | 组件独立封装，修改集中 |
| **Flutter 升级影响 BackdropFilter** | 效果变化 | 锁定 Flutter 版本或监控更新日志 |

## Open Questions

1. ~~是否需要支持 iPad 的不同布局？~~ → 暂不支持，scope 仅限 iPhone
2. 是否需要添加触觉反馈（Haptic Feedback）？→ 待用户测试反馈后决定
