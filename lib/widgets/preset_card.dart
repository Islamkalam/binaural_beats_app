import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/frequencies.dart';
import '../../models/preset_model.dart';

class PresetCard extends StatelessWidget {
  final PresetModel preset;
  final bool isPlaying;
  final bool showDelete;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const PresetCard({
    super.key,
    required this.preset,
    required this.isPlaying,
    required this.onTap,
    this.showDelete = false,
    this.onDelete,
  });

  Color get _waveColor {
    final wave = FrequencyConstants.getBrainWave(
        preset.leftFrequency, preset.rightFrequency);
    switch (wave) {
      case 'Delta': return AppColors.delta;
      case 'Theta': return AppColors.theta;
      case 'Alpha': return AppColors.alpha;
      case 'Beta': return AppColors.beta;
      case 'Gamma': return AppColors.gamma;
      default: return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _waveColor;
    final wave = FrequencyConstants.getBrainWave(
        preset.leftFrequency, preset.rightFrequency);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isPlaying
              ? color.withOpacity(0.2)
              : color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isPlaying ? color : color.withOpacity(0.3),
            width: isPlaying ? 2 : 1,
          ),
          boxShadow: isPlaying
              ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 12)]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(preset.emoji, style: const TextStyle(fontSize: 22)),
                const Spacer(),
                if (isPlaying)
                  Icon(Icons.graphic_eq, color: color, size: 18),
                if (showDelete && !isPlaying && onDelete != null)
                  GestureDetector(
                    onTap: onDelete,
                    child: Icon(Icons.delete_outline,
                        color: AppColors.error, size: 18),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              preset.name,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                wave,
                style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${preset.leftFrequency.toStringAsFixed(0)} / '
              '${preset.rightFrequency.toStringAsFixed(0)} Hz',
              style: TextStyle(
                  color: color.withOpacity(0.8), fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
