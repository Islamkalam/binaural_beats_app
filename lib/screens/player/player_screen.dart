import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/frequencies.dart';
import '../../core/utils/timer_utils.dart';
import '../../models/preset_model.dart';
import '../../providers/audio_provider.dart';
import '../../providers/timer_provider.dart';
import '../../widgets/player_controls.dart';
import '../timer/timer_screen.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  final PresetModel preset;

  const PlayerScreen({super.key, required this.preset});

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Start playing when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(audioProvider.notifier).play(widget.preset);
    });

    // Connect timer finish -> stop audio
    ref.read(timerProvider.notifier).onTimerFinished = () {
      ref.read(audioProvider.notifier).stop();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Timer ended — audio stopped')),
        );
      }
    };
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color _getBrainWaveColor(String wave) {
    switch (wave) {
      case 'Delta':
        return AppColors.delta;
      case 'Theta':
        return AppColors.theta;
      case 'Alpha':
        return AppColors.alpha;
      case 'Beta':
        return AppColors.beta;
      case 'Gamma':
        return AppColors.gamma;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final audioState = ref.watch(audioProvider);
    final timerState = ref.watch(timerProvider);
    final brainWave = FrequencyConstants.getBrainWave(
      widget.preset.leftFrequency,
      widget.preset.rightFrequency,
    );
    final waveColor = _getBrainWaveColor(brainWave);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.preset.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.timer_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TimerScreen()),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Animated Pulse Ring
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final scale = audioState.isPlaying && !audioState.isPaused
                    ? 1.0 + _pulseController.value * 0.12
                    : 1.0;
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          waveColor.withOpacity(0.3),
                          waveColor.withOpacity(0.05),
                        ],
                      ),
                      border: Border.all(
                          color: waveColor.withOpacity(0.6), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: waveColor.withOpacity(
                              audioState.isPlaying ? 0.4 : 0.1),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        widget.preset.emoji,
                        style: const TextStyle(fontSize: 56),
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            // Preset Name & Benefit
            Text(
              widget.preset.name,
              style: const TextStyle(
                  fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              widget.preset.benefit,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.textSecondary
                    : Colors.black54,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 28),

            // Frequency Display
            Row(
              children: [
                Expanded(
                  child: _FrequencyCard(
                    label: AppStrings.leftEar,
                    hz: widget.preset.leftFrequency,
                    color: AppColors.primary,
                    icon: Icons.headphones,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FrequencyCard(
                    label: AppStrings.rightEar,
                    hz: widget.preset.rightFrequency,
                    color: AppColors.accent,
                    icon: Icons.headphones,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Difference & Brain Wave
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: waveColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: waveColor.withOpacity(0.4)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        '${widget.preset.difference.toStringAsFixed(0)} Hz',
                        style: TextStyle(
                            color: waveColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      const Text('Difference',
                          style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  Container(
                      width: 1, height: 36, color: waveColor.withOpacity(0.3)),
                  Column(
                    children: [
                      Text(
                        brainWave,
                        style: TextStyle(
                            color: waveColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      const Text('Brain Wave',
                          style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Volume Slider
            _VolumeSlider(
              volume: audioState.volume,
              onChanged: (v) => ref.read(audioProvider.notifier).setVolume(v),
            ),

            const SizedBox(height: 24),

            // Timer display (if active)
            if (timerState.totalSeconds > 0) ...[
              _TimerBadge(timerState: timerState),
              const SizedBox(height: 20),
            ],

            // Play Controls
            PlayerControls(
              isPlaying: audioState.isPlaying,
              isPaused: audioState.isPaused,
              onPlay: () => ref.read(audioProvider.notifier).play(widget.preset),
              onPause: () => ref.read(audioProvider.notifier).pause(),
              onResume: () => ref.read(audioProvider.notifier).resume(),
              onStop: () {
                ref.read(audioProvider.notifier).stop();
                ref.read(timerProvider.notifier).cancel();
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _FrequencyCard extends StatelessWidget {
  final String label;
  final double hz;
  final Color color;
  final IconData icon;

  const _FrequencyCard({
    required this.label,
    required this.hz,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(label,
              style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(
            '${hz.toStringAsFixed(0)} Hz',
            style: TextStyle(
                color: color, fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _VolumeSlider extends StatelessWidget {
  final double volume;
  final ValueChanged<double> onChanged;

  const _VolumeSlider({required this.volume, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.volume_down,
            color: AppColors.textSecondary, size: 20),
        Expanded(
          child: Slider(
            value: volume,
            min: 0,
            max: 1,
            onChanged: onChanged,
          ),
        ),
        Icon(Icons.volume_up, color: AppColors.textSecondary, size: 20),
        const SizedBox(width: 8),
        Text(
          '${(volume * 100).round()}%',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

class _TimerBadge extends StatelessWidget {
  final TimerState timerState;
  const _TimerBadge({required this.timerState});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer, color: AppColors.primary, size: 18),
          const SizedBox(width: 8),
          Text(
            TimerUtils.formatDuration(timerState.remainingSeconds),
            style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16),
          ),
        ],
      ),
    );
  }
}
