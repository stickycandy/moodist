import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

/// Liquid Glass Tab Bar 的单个项目配置
class LiquidGlassTabItem {
  final IconData icon;
  final String label;

  const LiquidGlassTabItem({
    required this.icon,
    required this.label,
  });
}

/// iOS 26 液态玻璃风格底部导航栏
///
/// 特性：
/// - 浮动大圆角卡片样式
/// - 选中项使用 iOS 26 Liquid Glass 毛玻璃效果
/// - 切换时指示器带弹性放大回弹动画（类似 iOS 26 原生）
/// - 图标 + 文字双行显示
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

class _LiquidGlassTabBarState extends State<LiquidGlassTabBar>
    with TickerProviderStateMixin {
  // Tab Bar 配置
  static const _tabBarHeight = 68.0;
  static const _barHorizontalMargin = 24.0;
  static const _barBorderRadius = 28.0;

  // 指示器配置
  static const _indicatorVerticalPadding = 6.0;
  static const _indicatorHorizontalPadding = 5.0;
  static const _indicatorBorderRadius = 22.0;

  // 位置滑动动画
  late AnimationController _slideController;
  late Animation<double> _slideAnimation;
  double _prevLeft = 0;
  double _targetLeft = 0;

  // 弹性缩放动画
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  // 图标弹性动画
  late AnimationController _iconBounceController;
  late Animation<double> _iconBounceAnimation;

  bool _isFirstBuild = true;

  @override
  void initState() {
    super.initState();

    // 位置滑动 - 使用自定义弹簧曲线
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slideAnimation = _slideController.drive(
      CurveTween(curve: Curves.easeOutCubic),
    );

    // 指示器弹性缩放 - 先放大再弹回
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _bounceAnimation = TweenSequence<double>([
      // 快速放大
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.12)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 25,
      ),
      // 弹性回弹 - 过冲后稳定
      TweenSequenceItem(
        tween: Tween(begin: 1.12, end: 0.96)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
      // 轻微反弹
      TweenSequenceItem(
        tween: Tween(begin: 0.96, end: 1.03)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
      // 回归原始
      TweenSequenceItem(
        tween: Tween(begin: 1.03, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 25,
      ),
    ]).animate(_bounceController);

    // 选中图标弹性
    _iconBounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _iconBounceAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.25)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.25, end: 0.92)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.92, end: 1.05)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.05, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 20,
      ),
    ]).animate(_iconBounceController);
  }

  @override
  void dispose() {
    _slideController.dispose();
    _bounceController.dispose();
    _iconBounceController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant LiquidGlassTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _animateToIndex(widget.selectedIndex);
    }
  }

  void _animateToIndex(int index) {
    final barWidth = MediaQuery.of(context).size.width - _barHorizontalMargin * 2;
    final itemWidth = barWidth / widget.items.length;
    final newLeft = index * itemWidth + _indicatorHorizontalPadding;

    _prevLeft = _targetLeft;
    _targetLeft = newLeft;

    // 重置并启动位置动画
    _slideController.reset();
    _slideController.forward();

    // 重置并启动弹性缩放
    _bounceController.reset();
    _bounceController.forward();

    // 重置并启动图标弹性
    _iconBounceController.reset();
    _iconBounceController.forward();
  }

  double _computeIndicatorLeft() {
    final barWidth = MediaQuery.of(context).size.width - _barHorizontalMargin * 2;
    final itemWidth = barWidth / widget.items.length;
    final targetLeft = widget.selectedIndex * itemWidth + _indicatorHorizontalPadding;

    if (_isFirstBuild) {
      _prevLeft = targetLeft;
      _targetLeft = targetLeft;
      _isFirstBuild = false;
      return targetLeft;
    }

    // 使用 lerpDouble 根据动画进度插值
    return lerpDouble(_prevLeft, _targetLeft, _slideAnimation.value) ?? targetLeft;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: _barHorizontalMargin,
        right: _barHorizontalMargin,
        bottom: bottomPadding > 0 ? bottomPadding : 12.0,
      ),
      child: Container(
        height: _tabBarHeight,
        decoration: BoxDecoration(
          // 整体背景 - 半透明深色，让底部内容微微透出
          color: isDark
              ? const Color(0xE01C1C1E)
              : const Color(0xDDF5F5F7),
          borderRadius: BorderRadius.circular(_barBorderRadius),
          // 外边框 - 模拟玻璃边缘
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.white.withOpacity(0.6),
            width: 0.5,
          ),
          boxShadow: [
            // 主阴影
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.4 : 0.12),
              blurRadius: 24,
              offset: const Offset(0, 8),
              spreadRadius: -2,
            ),
            // 近距阴影
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: BackdropFilter(
          // 整体 bar 也有轻微的毛玻璃效果
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 选中项液态玻璃指示器
              _buildLiquidGlassIndicator(context, isDark),
              // Tab 项
              _buildTabItems(context, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLiquidGlassIndicator(BuildContext context, bool isDark) {
    final barWidth =
        MediaQuery.of(context).size.width - _barHorizontalMargin * 2;
    final itemWidth = barWidth / widget.items.length;
    final indicatorWidth = itemWidth - _indicatorHorizontalPadding * 2;
    final indicatorHeight = _tabBarHeight - _indicatorVerticalPadding * 2;

    return AnimatedBuilder(
      animation: Listenable.merge([_slideController, _bounceController]),
      builder: (context, child) {
        final left = _computeIndicatorLeft();
        final scale = _bounceAnimation.value;

        return Positioned(
          left: left,
          top: _indicatorVerticalPadding,
          child: Transform.scale(
            scale: scale,
            child: child,
          ),
        );
      },
      child: Container(
        width: indicatorWidth,
        height: indicatorHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_indicatorBorderRadius),
          // Liquid Glass 多层效果
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    Colors.white.withOpacity(0.22),
                    Colors.white.withOpacity(0.08),
                  ]
                : [
                    Colors.white.withOpacity(0.85),
                    Colors.white.withOpacity(0.55),
                  ],
          ),
          // 玻璃高光边框
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.25)
                : Colors.white.withOpacity(0.9),
            width: 0.5,
          ),
          // 玻璃阴影
          boxShadow: [
            // 外发光
            BoxShadow(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.white.withOpacity(0.3),
              blurRadius: 12,
              spreadRadius: 0,
            ),
            // 底部阴影（让指示器浮起来）
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
              spreadRadius: -1,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(_indicatorBorderRadius),
          child: BackdropFilter(
            // 液态玻璃的模糊效果
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(_indicatorBorderRadius),
                // 顶部高光 - 模拟 iOS 26 液态玻璃的光泽
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.center,
                  colors: [
                    Colors.white.withOpacity(isDark ? 0.15 : 0.4),
                    Colors.white.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabItems(BuildContext context, bool isDark) {
    return Row(
      children: List.generate(widget.items.length, (index) {
        final item = widget.items[index];
        final isSelected = index == widget.selectedIndex;

        // 动态颜色
        final Color activeColor;
        final Color inactiveColor;
        if (isDark) {
          activeColor = Colors.white;
          inactiveColor = Colors.white.withOpacity(0.4);
        } else {
          activeColor = const Color(0xFF1C1C1E);
          inactiveColor = const Color(0xFF8E8E93);
        }

        return Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => widget.onTap(index),
            child: SizedBox(
              height: _tabBarHeight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 选中图标带弹性动画
                  _buildAnimatedIcon(item, isSelected, activeColor, inactiveColor),
                  const SizedBox(height: 2),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? activeColor : inactiveColor,
                    ),
                    child: Text(item.label),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildAnimatedIcon(
    LiquidGlassTabItem item,
    bool isSelected,
    Color activeColor,
    Color inactiveColor,
  ) {
    if (!isSelected) {
      return AnimatedScale(
        scale: 1.0,
        duration: const Duration(milliseconds: 250),
        child: Icon(
          item.icon,
          size: 24,
          color: inactiveColor,
        ),
      );
    }

    // 选中项使用弹性动画
    return AnimatedBuilder(
      animation: _iconBounceController,
      builder: (context, child) {
        return Transform.scale(
          scale: _iconBounceAnimation.value,
          child: child,
        );
      },
      child: Icon(
        item.icon,
        size: 24,
        color: activeColor,
      ),
    );
  }
}