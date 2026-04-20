import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/frequencies.dart';
import '../../models/preset_model.dart';
import '../../providers/preset_provider.dart';

class ImportPresetScreen extends ConsumerWidget {
  final PresetModel preset;

  const ImportPresetScreen({super.key, required this.preset});

  Color _waveColor(String wave) {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final brainWave = FrequencyConstants.getBrainWave(
        preset.leftFrequency, preset.rightFrequency);
    final color = _waveColor(brainWave);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.importPresetTitle)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.accent.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.download_rounded,
                        color: AppColors.accent),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Preset Received!',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(
                          'Your coach sent you a custom preset',
                          style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Preset Preview Card
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(AppStrings.presetPreview,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withOpacity(0.4)),
              ),
              child: Column(
                children: [
                  Text(preset.emoji,
                      style: const TextStyle(fontSize: 48)),
                  const SizedBox(height: 10),
                  Text(
                    preset.name,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Frequencies Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _FreqInfo(
                          label: 'Left Ear',
                          value:
                              '${preset.leftFrequency.toStringAsFixed(0)} Hz',
                          color: AppColors.primary),
                      Container(
                          height: 40, width: 1, color: color.withOpacity(0.3)),
                      _FreqInfo(
                          label: 'Right Ear',
                          value:
                              '${preset.rightFrequency.toStringAsFixed(0)} Hz',
                          color: AppColors.accent),
                      Container(
                          height: 40, width: 1, color: color.withOpacity(0.3)),
                      _FreqInfo(
                          label: 'Brain Wave',
                          value: brainWave,
                          color: color),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Benefit
                  if (preset.benefit.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        preset.benefit,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13, height: 1.5),
                      ),
                    ),
                  ],

                  // Coach name if available
                  if (preset.createdBy != null &&
                      preset.createdBy!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      'By ${preset.createdBy}',
                      style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ],
              ),
            ),

            const Spacer(),

            // Import Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _importPreset(context, ref),
                icon: const Icon(Icons.add_circle_outline),
                label: const Text(AppStrings.importButton),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Cancel Button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(AppStrings.cancelButton),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _importPreset(BuildContext context, WidgetRef ref) {
    ref.read(presetProvider.notifier).addPreset(preset);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(AppStrings.importSuccess),
        backgroundColor: AppColors.success,
      ),
    );
    Navigator.of(context).pop();
  }
}

class _FreqInfo extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _FreqInfo({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 15)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}
