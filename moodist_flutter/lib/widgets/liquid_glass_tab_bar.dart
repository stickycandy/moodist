import 'dart:ui';
import 'package:flutter/material.dart';

/// Liquid Glass Tab Bar 的单个项目配置
class LiquidGlassTabItem {
  final IconData icon;
  final String label;

  const LiquidGlassTabItem({
    required this.icon,
    required this.label,
  });
}

/// iOS 26 风格的液态玻璃底部导航栏
/// 
/// 特性：
/// - 整体毛玻璃背景效果
/// - 玻璃质感的浮动胶囊指示器（带高光、阴影、折射效果）
/// - 平滑的液态切换动画
/// - Light/Dark 模式自动适配
class LiquidGlassTabBar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final List<LiquidGlassTabItem> items;

  const LiquidGlassTabBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    required this.items,
  });

  @override
  State<LiquidGlassTabBar> createState() => _LiquidGlassTabBarState();
}

class _LiquidGlassTabBarState extends State<LiquidGlassTabBar> {
  // 动画配置
  static const _animationDuration = Duration(milliseconds: 350);
  static const _animationCurve = Curves.easeOutBack;
  
  // Tab Bar 高度（不含安全区）
  static const _tabBarHeight = 64.0;
  
  // 指示器配置
  static const _indicatorHeight = 44.0;
  static const _indicatorHorizontalPadding = 6.0;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    final activeColor = Theme.of(context).colorScheme.primary;
    final inactiveColor = isDark 
        ? Colors.white.withOpacity(0.5) 
        : Colors.black.withOpacity(0.4);

    return Container(
      height: _tabBarHeight + bottomPadding,
      decoration: BoxDecoration(
        // 毛玻璃底层背景
        color: isDark 
            ? Colors.black.withOpacity(0.3)
            : Colors.white.withOpacity(0.6),
        // 顶部微妙的分割线
        border: Border(
          top: BorderSide(
            color: isDark 
                ? Colors.white.withOpacity(0.08) 
                : Colors.black.withOpacity(0.06),
            width: 0.5,
          ),
        ),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
          child: Padding(
            padding: EdgeInsets.only(bottom: bottomPadding),
            child: Stack(
              children: [
                // Liquid Glass 浮动胶囊指示器
                _buildLiquidGlassIndicator(context, activeColor, isDark),
                // Tab 项
                _buildTabItems(context, activeColor, inactiveColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLiquidGlassIndicator(BuildContext context, Color activeColor, bool isDark) {
    final itemWidth = MediaQuery.of(context).size.width / widget.items.length;
    final indicatorWidth = itemWidth - _indicatorHorizontalPadding * 2;
    
    return AnimatedPositioned(
      duration: _animationDuration,
      curve: _animationCurve,
      left: widget.selectedIndex * itemWidth + _indicatorHorizontalPadding,
      top: (_tabBarHeight - _indicatorHeight) / 2,
      child: AnimatedContainer(
        duration: _animationDuration,
        curve: _animationCurve,
        width: indicatorWidth,
        height: _indicatorHeight,
        decoration: BoxDecoration(
          // 液态玻璃渐变背景
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    Colors.white.withOpacity(0.18),
                    Colors.white.withOpacity(0.08),
                  ]
                : [
                    Colors.white.withOpacity(0.9),
                    Colors.white.withOpacity(0.6),
                  ],
          ),
          borderRadius: BorderRadius.circular(_indicatorHeight / 2),
          // 玻璃质感边框
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.25)
                : Colors.white.withOpacity(0.8),
            width: 1.0,
          ),
          // 外层柔和阴影
          boxShadow: [
            // 主阴影
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
            // 内发光效果（模拟玻璃折射）
            BoxShadow(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.white.withOpacity(0.5),
              blurRadius: 1,
              offset: const Offset(0, -0.5),
              spreadRadius: 0,
            ),
          ],
        ),
        // 内部高光层
        child: ClipRRect(
          borderRadius: BorderRadius.circular(_indicatorHeight / 2),
          child: Stack(
            children: [
              // 顶部高光条
              Positioned(
                top: 1,
                left: 8,
                right: 8,
                child: Container(
                  height: 1.5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0),
                        Colors.white.withOpacity(isDark ? 0.3 : 0.6),
                        Colors.white.withOpacity(0),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabItems(BuildContext context, Color activeColor, Color inactiveColor) {
    return Row(
      children: List.generate(widget.items.length, (index) {
        final item = widget.items[index];
        final isSelected = index == widget.selectedIndex;
        
        return Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => widget.onTap(index),
            child: SizedBox(
              height: _tabBarHeight,
              child: Center(
                // 图标（带缩放和颜色动画）
                child: AnimatedScale(
                  scale: isSelected ? 1.2 : 1.0,
                  duration: _animationDuration,
                  curve: _animationCurve,
                  child: Icon(
                    item.icon,
                    size: 26,
                    color: isSelected ? activeColor : inactiveColor,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}