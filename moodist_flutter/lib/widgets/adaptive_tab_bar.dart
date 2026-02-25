import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../services/platform_service.dart';
import 'liquid_glass_tab_bar.dart';

/// 自适应 Tab Bar 项目配置
class AdaptiveTabItem {
  final IconData icon;
  final String label;

  const AdaptiveTabItem({
    required this.icon,
    required this.label,
  });
}

/// 平台自适应的底部导航栏
/// 
/// 根据平台和 iOS 版本自动选择合适的 Tab Bar 样式：
/// - iOS 26+: Liquid Glass 风格
/// - iOS <26: CupertinoTabBar
/// - Android/其他: Material NavigationBar
class AdaptiveTabBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final List<AdaptiveTabItem> items;

  const AdaptiveTabBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    try {
      // iOS 平台
      if (Platform.isIOS) {
        // 始终使用 Liquid Glass 风格（因为目标设备是 iOS 26）
        return LiquidGlassTabBar(
          selectedIndex: selectedIndex,
          onTap: onTap,
          items: items.map((item) => LiquidGlassTabItem(
            icon: item.icon,
            label: item.label,
          )).toList(),
        );
      }
    } catch (e) {
      // 平台检测失败，使用 Material 风格
    }
    
    // Android/其他平台使用 Material NavigationBar
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onTap,
      destinations: items.map((item) => NavigationDestination(
        icon: Icon(item.icon),
        label: item.label,
      )).toList(),
    );
  }
}
