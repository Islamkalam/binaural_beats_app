import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class PlayerControls extends StatelessWidget {
  final bool isPlaying;
  final bool isPaused;
  final VoidCallback onPlay;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onStop;

  const PlayerControls({
    super.key,
    required this.isPlaying,
    required this.isPaused,
    required this.onPlay,
    required this.onPause,
    required this.onResume,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Stop button
        _ControlButton(
          icon: Icons.stop_rounded,
          color: AppColors.error,
          size: 52,
          onTap: onStop,
          enabled: isPlaying,
        ),
        const SizedBox(width: 20),

        // Play / Pause main button
        _MainPlayButton(
          isPlaying: isPlaying,
          isPaused: isPaused,
          onPlay: onPlay,
          onPause: onPause,
          onResume: onResume,
        ),
      ],
    );
  }
}

class _MainPlayButton extends StatelessWidget {
  final bool isPlaying;
  final bool isPaused;
  final VoidCallback onPlay;
  final VoidCallback onPause;
  final VoidCallback onResume;

  const _MainPlayButton({
    required this.isPlaying,
    required this.isPaused,
    required this.onPlay,
    required this.onPause,
    required this.onResume,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = isPlaying && !isPaused;

    return GestureDetector(
      onTap: () {
        if (!isPlaying) {
          onPlay();
        } else if (isPaused) {
          onResume();
        } else {
          onPause();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 76,
        height: 76,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: isActive
                ? [AppColors.primary, AppColors.accent]
                : [AppColors.primary.withOpacity(0.6), AppColors.accent.withOpacity(0.6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(isActive ? 0.5 : 0.2),
              blurRadius: isActive ? 20 : 8,
              spreadRadius: isActive ? 4 : 0,
            ),
          ],
        ),
        child: Icon(
          isActive ? Icons.pause_rounded : Icons.play_arrow_rounded,
          color: Colors.white,
          size: 38,
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final VoidCallback onTap;
  final bool enabled;

  const _ControlButton({
    required this.icon,
    required this.color,
    required this.size,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: enabled
              ? color.withOpacity(0.15)
              : AppColors.textSecondary.withOpacity(0.08),
          border: Border.all(
            color: enabled
                ? color.withOpacity(0.5)
                : AppColors.textSecondary.withOpacity(0.2),
          ),
        ),
        child: Icon(
          icon,
          color: enabled ? color : AppColors.textSecondary.withOpacity(0.4),
          size: size * 0.45,
        ),
      ),
    );
  }
}
