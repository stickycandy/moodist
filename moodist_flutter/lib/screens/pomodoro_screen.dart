import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pomodoro_state.dart';

class PomodoroScreen extends StatelessWidget {
  const PomodoroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('番茄钟'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Consumer<PomodoroState>(
          builder: (context, state, _) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _PhaseBadge(isRest: state.isRest, theme: theme),
                  const SizedBox(height: 32),
                  _TimerRing(
                    displayMinutes: state.displayMinutes,
                    displaySeconds: state.displaySeconds,
                    isRest: state.isRest,
                    theme: theme,
                  ),
                  const SizedBox(height: 40),
                  _ControlButtons(state: state, theme: theme),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PhaseBadge extends StatelessWidget {
  const _PhaseBadge({required this.isRest, required this.theme});

  final bool isRest;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isRest
            ? theme.colorScheme.tertiaryContainer.withOpacity(0.6)
            : theme.colorScheme.primaryContainer.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isRest ? Icons.coffee_rounded : Icons.psychology_alt_rounded,
            size: 20,
            color: isRest
                ? theme.colorScheme.onTertiaryContainer
                : theme.colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 8),
          Text(
            isRest ? '休息' : '专注',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: isRest
                  ? theme.colorScheme.onTertiaryContainer
                  : theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimerRing extends StatelessWidget {
  const _TimerRing({
    required this.displayMinutes,
    required this.displaySeconds,
    required this.isRest,
    required this.theme,
  });

  final String displayMinutes;
  final String displaySeconds;
  final bool isRest;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.cardTheme.color,
        border: Border.all(
          color: isRest
              ? theme.colorScheme.tertiary.withOpacity(0.5)
              : theme.colorScheme.primary.withOpacity(0.5),
          width: 6,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        '$displayMinutes:$displaySeconds',
        style: theme.textTheme.displayLarge?.copyWith(
          fontFeatures: [const FontFeature.tabularFigures()],
          fontWeight: FontWeight.w300,
        ),
      ),
    );
  }
}

class _ControlButtons extends StatelessWidget {
  const _ControlButtons({required this.state, required this.theme});

  final PomodoroState state;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FilledButton.icon(
          onPressed: () => state.setRunning(!state.running),
          icon: Icon(state.running ? Icons.pause_rounded : Icons.play_arrow_rounded),
          label: Text(state.running ? '暂停' : '开始'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          ),
        ),
        const SizedBox(width: 16),
        OutlinedButton.icon(
          onPressed: () => state.reset(),
          icon: const Icon(Icons.refresh_rounded, size: 20),
          label: const Text('重置'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
        ),
      ],
    );
  }
}
