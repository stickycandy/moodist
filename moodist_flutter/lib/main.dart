import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/sound_state.dart';
import 'providers/preset_state.dart';
import 'providers/todo_state.dart';
import 'providers/pomodoro_state.dart';
import 'screens/sound_screen.dart';
import 'screens/presets_screen.dart';
import 'screens/sleep_timer_screen.dart';
import 'screens/pomodoro_screen.dart';
import 'screens/todo_screen.dart';
import 'services/notification_service.dart';
import 'services/platform_service.dart';
import 'widgets/adaptive_tab_bar.dart';
import 'widgets/gradient_background.dart';
import 'theme/app_theme.dart';

void main() {
  // 不使用 async，直接启动
  WidgetsFlutterBinding.ensureInitialized();
  
  // 立即启动 App
  runApp(const MoodistApp());
}

class MoodistApp extends StatefulWidget {
  const MoodistApp({super.key});

  @override
  State<MoodistApp> createState() => _MoodistAppState();
}

class _MoodistAppState extends State<MoodistApp> {
  @override
  void initState() {
    super.initState();
    // 在 initState 中延迟初始化服务
    _initServices();
  }
  
  Future<void> _initServices() async {
    // 延迟初始化，确保 Flutter 框架完全就绪
    await Future.delayed(const Duration(milliseconds: 800));
    
    try {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp, 
        DeviceOrientation.landscapeLeft, 
        DeviceOrientation.landscapeRight
      ]);
    } catch (e) {
      debugPrint('Orientation error: $e');
    }
    
    try {
      await NotificationService().initialize();
    } catch (e) {
      debugPrint('NotificationService init error: $e');
    }
    
    try {
      await PlatformService().initialize();
    } catch (e) {
      debugPrint('PlatformService init error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SoundState()),
        ChangeNotifierProvider(create: (_) => PresetState()),
        ChangeNotifierProvider(create: (_) => TodoState()),
        ChangeNotifierProvider(create: (_) => PomodoroState()),
      ],
      child: MaterialApp(
        title: 'Ting',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: const MainShell(),
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _tabs = [
    (icon: Icons.graphic_eq, label: '声音'),
    (icon: Icons.bookmark, label: '预设'),
    (icon: Icons.timer, label: '睡眠'),
    (icon: Icons.work_outline, label: '番茄钟'),
    // TODO: 待办功能暂时隐藏，后续放开
    // (icon: Icons.check_circle_outline, label: '待办'),
  ];

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        body: Stack(
          children: [
            // 页面内容延伸到最底部
            Positioned.fill(
              child: IndexedStack(
                index: _index,
                children: const [
                  SoundScreen(),
                  PresetsScreen(),
                  SleepTimerScreen(),
                  PomodoroScreen(),
                  // TODO: 待办功能暂时隐藏，后续放开
                  // TodoScreen(),
                ],
              ),
            ),
            // Tab bar 浮动在内容之上
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AdaptiveTabBar(
                selectedIndex: _index,
                onTap: (i) => setState(() => _index = i),
                items: _tabs.map((t) => AdaptiveTabItem(icon: t.icon, label: t.label)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}