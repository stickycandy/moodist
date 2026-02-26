import 'package:flutter/material.dart';

/// 渐变背景组件
/// 
/// 提供清新风格的半透明渐变背景，自动适配深浅色模式。
/// 
/// 浅色模式：淡青 → 薄荷白
/// 深色模式：深青 → 深蓝绿
class GradientBackground extends StatelessWidget {
  /// 要显示在渐变背景上的子组件
  final Widget? child;
  
  /// 渐变的不透明度，默认为 1.0（完全不透明）
  final double opacity;

  const GradientBackground({
    super.key,
    this.child,
    this.opacity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final colors = isDark
        ? [
            const Color(0xFF004D40), // 深青
            const Color(0xFF1A2E3B), // 深蓝绿
          ]
        : [
            const Color(0xFFE0F7FA), // 淡青
            const Color(0xFFF0FFF4), // 薄荷白
          ];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors.map((c) => c.withOpacity(opacity)).toList(),
        ),
      ),
      child: child,
    );
  }
}
