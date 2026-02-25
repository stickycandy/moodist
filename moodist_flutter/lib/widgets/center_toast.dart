import 'dart:ui';
import 'package:flutter/material.dart';

/// 居中半透明弹窗提示
///
/// 模仿 iOS 风格的 HUD 提示，居中显示半透明黑色/白色弹窗，
/// 自动在指定时间后消失。
class CenterToast {
  CenterToast._();

  /// 显示居中提示
  ///
  /// [context] - BuildContext
  /// [message] - 提示文字
  /// [icon] - 可选图标（如 Icons.check_circle）
  /// [duration] - 显示时长，默认 1.5 秒
  static void show(
    BuildContext context, {
    required String message,
    IconData? icon,
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    final overlay = Overlay.of(context);
    late final OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => _CenterToastWidget(
        message: message,
        icon: icon,
        duration: duration,
        onDismiss: () {
          entry.remove();
        },
      ),
    );

    overlay.insert(entry);
  }
}

class _CenterToastWidget extends StatefulWidget {
  final String message;
  final IconData? icon;
  final Duration duration;
  final VoidCallback onDismiss;

  const _CenterToastWidget({
    required this.message,
    this.icon,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<_CenterToastWidget> createState() => _CenterToastWidgetState();
}

class _CenterToastWidgetState extends State<_CenterToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      reverseDuration: const Duration(milliseconds: 180),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeIn,
      ),
    );

    _controller.forward();

    // 自动消失
    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse().then((_) {
          if (mounted) widget.onDismiss();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Positioned.fill(
      child: IgnorePointer(
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    constraints: const BoxConstraints(
                      minWidth: 120,
                      maxWidth: 240,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: widget.icon != null ? 20 : 16,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.18)
                          : Colors.black.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.12)
                            : Colors.white.withOpacity(0.08),
                        width: 0.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 24,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(
                            widget.icon,
                            size: 36,
                            color: isDark
                                ? Colors.white.withOpacity(0.9)
                                : Colors.white.withOpacity(0.95),
                          ),
                          const SizedBox(height: 10),
                        ],
                        Text(
                          widget.message,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? Colors.white.withOpacity(0.9)
                                : Colors.white.withOpacity(0.95),
                            decoration: TextDecoration.none,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
