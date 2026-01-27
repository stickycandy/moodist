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

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  runApp(const MoodistApp());
}

class MoodistApp extends StatelessWidget {
  const MoodistApp({super.key});

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
        title: 'Moodist',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal, brightness: Brightness.light),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal, brightness: Brightness.dark),
          useMaterial3: true,
        ),
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
    (icon: Icons.check_circle_outline, label: '待办'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          SoundScreen(),
          PresetsScreen(),
          SleepTimerScreen(),
          PomodoroScreen(),
          TodoScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: _tabs.map((t) => NavigationDestination(icon: Icon(t.icon), label: t.label)).toList(),
      ),
    );
  }
}
