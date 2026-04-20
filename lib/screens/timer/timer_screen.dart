import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/frequencies.dart';
import '../../core/utils/timer_utils.dart';
import '../../providers/timer_provider.dart';
import '../../providers/audio_provider.dart';

class TimerScreen extends ConsumerWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerProvider);
    final timerNotifier = ref.read(timerProvider.notifier);

    // Connect timer finish to stop audio
    timerNotifier.onTimerFinished = () {
      ref.read(audioProvider.notifier).stop();
    };

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.timerTitle)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Timer Display
            if (timerState.totalSeconds > 0) ...[
              const SizedBox(height: 20),
              _CircularTimerWidget(timerState: timerState),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!timerState.isRunning && !timerState.isFinished)
                    ElevatedButton.icon(
                      onPressed: timerNotifier.start,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Start'),
                    ),
                  if (timerState.isRunning) ...[
                    OutlinedButton.icon(
                      onPressed: timerNotifier.pause,
                      icon: const Icon(Icons.pause),
                      label: const Text('Pause'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: timerNotifier.cancel,
                      icon: const Icon(Icons.stop),
                      label: const Text('Cancel'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                  if (timerState.isFinished) ...[
                    const Icon(Icons.check_circle,
                        color: AppColors.success, size: 32),
                    const SizedBox(width: 8),
                    const Text('Timer Complete!',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.success)),
                  ],
                ],
              ),
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
            ],

            // Timer Selection
            const Text(
              'Select Duration',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: FrequencyConstants.timerOptions.map((minutes) {
                final isSelected =
                    timerState.totalSeconds == minutes * 60 &&
                        !timerState.isFinished;
                return GestureDetector(
                  onTap: () {
                    timerNotifier.setTimer(minutes);
                    timerNotifier.start();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      TimerUtils.minutesToLabel(minutes),
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 32),

            // Info Box
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      color: AppColors.primary, size: 20),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Audio will automatically stop when the timer ends.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircularTimerWidget extends StatelessWidget {
  final TimerState timerState;
  const _CircularTimerWidget({required this.timerState});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 180,
          height: 180,
          child: CircularProgressIndicator(
            value: 1 - timerState.progress,
            strokeWidth: 10,
            backgroundColor: AppColors.primary.withOpacity(0.15),
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
        Column(
          children: [
            Text(
              TimerUtils.formatDuration(timerState.remainingSeconds),
              style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2),
            ),
            if (timerState.isRunning)
              const Text('Running',
                  style: TextStyle(
                      color: AppColors.success,
                      fontSize: 12,
                      fontWeight: FontWeight.w500))
            else if (timerState.isFinished)
              const Text('Done',
                  style: TextStyle(
                      color: AppColors.success,
                      fontSize: 12,
                      fontWeight: FontWeight.w500))
            else
              const Text('Paused',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
      ],
    );
  }
}
