import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

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

  // 弹性跟随的平滑因子 (越小越滞后，0.08~0.15 手感较好)
  static const _smoothFactor = 0.12;
  // 吸附阈值：气泡与目标距离小于此值时视为到达
  static const _snapThreshold = 0.5;

  // 位置滑动动画（点击切换用）
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

  // ---- 拖拽跟手状态 ----
  bool _isDragging = false;
  Ticker? _dragTicker;
  double _fingerTargetLeft = 0;  // 手指实际位置（目标）
  double _fingerTargetPage = 0;  // 手指位置对应的 page 值
  double _bubbleCurrentLeft = 0; // 气泡当前位置（滞后追赶中）
  double _bubbleCurrentPage = 0; // 气泡当前 page 值

  @override
  void initState() {
    super.initState();

    // 位置滑动
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slideAnimation = _slideController.drive(
      CurveTween(curve: Curves.easeOutCubic),
    );

    // 指示器弹性缩放
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.12)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.12, end: 0.96)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.96, end: 1.03)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
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
    _dragTicker?.dispose();
    _slideController.dispose();
    _bounceController.dispose();
    _iconBounceController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant LiquidGlassTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex && !_isDragging) {
      _animateToIndex(widget.selectedIndex);
    }
  }

  // ---- 辅助计算 ----

  double get _barWidth =>
      MediaQuery.of(context).size.width - _barHorizontalMargin * 2;

  double get _itemWidth => _barWidth / widget.items.length;

  double _leftForIndex(int index) =>
      index * _itemWidth + _indicatorHorizontalPadding;

  double _leftForPage(double page) =>
      page * _itemWidth + _indicatorHorizontalPadding;

  double _pageForLocalX(double localX) {
    return (localX / _itemWidth).clamp(0.0, widget.items.length - 1.0);
  }

  // ---- 点击切换动画 ----

  void _animateToIndex(int index) {
    final newLeft = _leftForIndex(index);
    _prevLeft = _targetLeft;
    _targetLeft = newLeft;

    _slideController.reset();
    _slideController.forward();

    _bounceController.reset();
    _bounceController.forward();

    _iconBounceController.reset();
    _iconBounceController.forward();
  }

  double _computeIndicatorLeft() {
    final targetLeft = _leftForIndex(widget.selectedIndex);

    if (_isFirstBuild) {
      _prevLeft = targetLeft;
      _targetLeft = targetLeft;
      _isFirstBuild = false;
      return targetLeft;
    }

    return lerpDouble(_prevLeft, _targetLeft, _slideAnimation.value) ??
        targetLeft;
  }

  // ---- 拖拽手势 + Ticker 驱动的弹性跟随 ----

  void _startDragTicker() {
    _dragTicker?.dispose();
    _dragTicker = createTicker(_onDragTick);
    _dragTicker!.start();
  }

  void _stopDragTicker() {
    _dragTicker?.stop();
    _dragTicker?.dispose();
    _dragTicker = null;
  }

  void _onDragTick(Duration elapsed) {
    if (!_isDragging) return;

    // 指数平滑插值：气泡每帧靠近手指目标一点
    final diffLeft = _fingerTargetLeft - _bubbleCurrentLeft;
    final diffPage = _fingerTargetPage - _bubbleCurrentPage;

    if (diffLeft.abs() < _snapThreshold && diffPage.abs() < 0.01) {
      // 足够近，直接吸附
      _bubbleCurrentLeft = _fingerTargetLeft;
      _bubbleCurrentPage = _fingerTargetPage;
    } else {
      _bubbleCurrentLeft += diffLeft * _smoothFactor;
      _bubbleCurrentPage += diffPage * _smoothFactor;
    }

    setState(() {});
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    _slideController.stop();

    final localX = details.localPosition.dx;
    final page = _pageForLocalX(localX);
    final left = _leftForPage(page);

    // 气泡从当前实际显示位置开始追赶
    final currentIndicatorLeft =
        _isDragging ? _bubbleCurrentLeft : _computeIndicatorLeft();
    final currentIndicatorPage = _isDragging
        ? _bubbleCurrentPage
        : widget.selectedIndex.toDouble();

    setState(() {
      _isDragging = true;
      _fingerTargetLeft = left;
      _fingerTargetPage = page;
      _bubbleCurrentLeft = currentIndicatorLeft;
      _bubbleCurrentPage = currentIndicatorPage;
    });

    _startDragTicker();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    final localX = details.localPosition.dx;
    final page = _pageForLocalX(localX);
    _fingerTargetLeft = _leftForPage(page);
    _fingerTargetPage = page;
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    _stopDragTicker();

    // 吸附到最近的 tab
    final nearestIndex =
        _bubbleCurrentPage.round().clamp(0, widget.items.length - 1);

    setState(() {
      _isDragging = false;
      // 从气泡当前位置动画到目标 tab
      _prevLeft = _bubbleCurrentLeft;
      _targetLeft = _leftForIndex(nearestIndex);
    });

    _slideController.reset();
    _slideController.forward();

    // 松手弹性动画
    _bounceController.reset();
    _bounceController.forward();

    _iconBounceController.reset();
    _iconBounceController.forward();

    if (nearestIndex != widget.selectedIndex) {
      widget.onTap(nearestIndex);
    }
  }

  void _onHorizontalDragCancel() {
    _stopDragTicker();
    setState(() {
      _isDragging = false;
    });
  }

  // ---- 构建 UI ----

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
      child: GestureDetector(
        onHorizontalDragStart: _onHorizontalDragStart,
        onHorizontalDragUpdate: _onHorizontalDragUpdate,
        onHorizontalDragEnd: _onHorizontalDragEnd,
        onHorizontalDragCancel: _onHorizontalDragCancel,
        child: Container(
          height: _tabBarHeight,
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xE01C1C1E)
                : const Color(0xDDF5F5F7),
            borderRadius: BorderRadius.circular(_barBorderRadius),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.white.withOpacity(0.6),
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.4 : 0.12),
                blurRadius: 24,
                offset: const Offset(0, 8),
                spreadRadius: -2,
              ),
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
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                _buildLiquidGlassIndicator(context, isDark),
                _buildTabItems(context, isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLiquidGlassIndicator(BuildContext context, bool isDark) {
    final indicatorWidth = _itemWidth - _indicatorHorizontalPadding * 2;
    final indicatorHeight = _tabBarHeight - _indicatorVerticalPadding * 2;

    return AnimatedBuilder(
      animation: Listenable.merge([_slideController, _bounceController]),
      builder: (context, child) {
        // 拖拽时直接用 _dragLeft，否则用动画计算的位置
        final left = _isDragging ? _bubbleCurrentLeft : _computeIndicatorLeft();
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
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.25)
                : Colors.white.withOpacity(0.9),
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.white.withOpacity(0.3),
              blurRadius: 12,
              spreadRadius: 0,
            ),
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
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(_indicatorBorderRadius),
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
    // 拖拽时使用连续的 page 值来计算颜色过渡
    final currentPage =
        _isDragging ? _bubbleCurrentPage : widget.selectedIndex.toDouble();

    return Row(
      children: List.generate(widget.items.length, (index) {
        final item = widget.items[index];
        final isSelected = index == widget.selectedIndex;

        // 根据距离当前位置的远近计算接近程度 (0.0 ~ 1.0)
        final double proximity =
            (1.0 - (currentPage - index).abs()).clamp(0.0, 1.0);

        final Color activeColor;
        final Color inactiveColor;
        if (isDark) {
          activeColor = Colors.white;
          inactiveColor = Colors.white.withOpacity(0.4);
        } else {
          activeColor = const Color(0xFF1C1C1E);
          inactiveColor = const Color(0xFF8E8E93);
        }

        // 颜色随接近程度平滑过渡
        final color = Color.lerp(inactiveColor, activeColor, proximity)!;
        final fontWeight =
            proximity > 0.5 ? FontWeight.w600 : FontWeight.w400;
        final iconScale = 1.0 + proximity * 0.08;

        return Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => widget.onTap(index),
            child: SizedBox(
              height: _tabBarHeight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildIcon(item, isSelected, color, iconScale),
                  const SizedBox(height: 2),
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: fontWeight,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildIcon(
    LiquidGlassTabItem item,
    bool isSelected,
    Color color,
    double scale,
  ) {
    // 点击切换时，选中图标播放弹性动画
    if (isSelected && !_isDragging && _iconBounceController.isAnimating) {
      return AnimatedBuilder(
        animation: _iconBounceController,
        builder: (context, child) {
          return Transform.scale(
            scale: _iconBounceAnimation.value,
            child: child,
          );
        },
        child: Icon(item.icon, size: 24, color: color),
      );
    }

    return Transform.scale(
      scale: scale,
      child: Icon(item.icon, size: 24, color: color),
    );
  }
}