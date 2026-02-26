import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sound_state.dart';
import '../services/notification_service.dart';
import '../widgets/center_toast.dart';

class SleepTimerScreen extends StatelessWidget {
  const SleepTimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('睡眠定时'),
        centerTitle: true,
      ),
      body: Consumer<SoundState>(
        builder: (context, state, _) {
          return SafeArea(
            child: state.hasSleepTimer
                ? _ActiveTimerContent(state: state)
                : _DurationSelector(state: state, theme: theme),
          );
        },
      ),
    );
  }
}

class _ActiveTimerContent extends StatelessWidget {
  const _ActiveTimerContent({required this.state});

  final SoundState state;

  /// 格式化剩余时间为 mm:ss 或 hh:mm:ss
  String _formatRemainingTime(Duration? duration) {
    if (duration == null) return '--:--';
    
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final remaining = state.remainingTime;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.nightlight_round,
                size: 72,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              '睡眠定时进行中',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            // 倒计时显示
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    '剩余时间',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatRemainingTime(remaining),
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w300,
                      fontFeatures: const [FontFeature.tabularFigures()],
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '到时将自动停止播放',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.tonalIcon(
              onPressed: () {
                state.cancelSleepTimer();
                CenterToast.show(context, message: '已取消睡眠定时', icon: Icons.timer_off_outlined);
              },
              icon: const Icon(Icons.timer_off_outlined),
              label: const Text('取消定时'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DurationSelector extends StatelessWidget {
  const _DurationSelector({required this.state, required this.theme});

  final SoundState state;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          Icon(
            Icons.schedule,
            size: 48,
            color: theme.colorScheme.primary.withOpacity(0.8),
          ),
          const SizedBox(height: 16),
          Text(
            '选择关闭时间',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            '到时将自动停止所有声音播放',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          _TimerButton(
            label: '15 分钟',
            minutes: 15,
            state: state,
            icon: Icons.coffee,
          ),
          _TimerButton(
            label: '30 分钟',
            minutes: 30,
            state: state,
            icon: Icons.bedtime_outlined,
          ),
          _TimerButton(
            label: '45 分钟',
            minutes: 45,
            state: state,
            icon: Icons.nightlight_round_outlined,
          ),
          _TimerButton(
            label: '1 小时',
            minutes: 60,
            state: state,
            icon: Icons.hourglass_top,
          ),
          _TimerButton(
            label: '2 小时',
            minutes: 120,
            state: state,
            icon: Icons.hourglass_empty,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _TimerButton extends StatelessWidget {
  const _TimerButton({
    required this.label,
    required this.minutes,
    required this.state,
    required this.icon,
    this.isLast = false,
  });

  final String label;
  final int minutes;
  final SoundState state;
  final IconData icon;
  final bool isLast;

  Future<void> _setTimer(BuildContext context) async {
    // 首次使用时请求通知权限（用于后台定时）
    final granted = await NotificationService().requestPermissions();
    if (!granted && context.mounted) {
      // 提示用户权限重要性，但仍允许使用（前台仍可工作）
      CenterToast.show(
        context,
        message: '未授予通知权限，后台定时可能不准确',
        icon: Icons.notifications_off_outlined,
        duration: const Duration(seconds: 3),
      );
    }
    
    state.setSleepTimer(Duration(minutes: minutes));
    if (context.mounted) {
      CenterToast.show(context, message: '已设置 $label 后停止播放', icon: Icons.bedtime_outlined);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Material(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _setTimer(context),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: theme.colorScheme.onPrimaryContainer, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}