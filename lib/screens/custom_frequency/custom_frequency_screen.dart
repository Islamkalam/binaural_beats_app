import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/frequencies.dart';
import '../../models/preset_model.dart';
import '../../providers/audio_provider.dart';
import '../../providers/preset_provider.dart';
import '../../widgets/frequency_slider.dart';
import '../player/player_screen.dart';

class CustomFrequencyScreen extends ConsumerStatefulWidget {
  const CustomFrequencyScreen({super.key});

  @override
  ConsumerState<CustomFrequencyScreen> createState() =>
      _CustomFrequencyScreenState();
}

class _CustomFrequencyScreenState
    extends ConsumerState<CustomFrequencyScreen> {
  double _leftHz = 200.0;
  double _rightHz = 210.0;
  final TextEditingController _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String get _brainWave =>
      FrequencyConstants.getBrainWave(_leftHz, _rightHz);

  Color get _waveColor {
    switch (_brainWave) {
      case 'Delta': return AppColors.delta;
      case 'Theta': return AppColors.theta;
      case 'Alpha': return AppColors.alpha;
      case 'Beta': return AppColors.beta;
      case 'Gamma': return AppColors.gamma;
      default: return AppColors.primary;
    }
  }

  void _playCustom() {
    ref.read(audioProvider.notifier).playCustom(
      leftHz: _leftHz,
      rightHz: _rightHz,
    );
    final preset = PresetModel(
      id: 'custom_temp',
      name: 'Custom',
      emoji: '🎵',
      leftFrequency: _leftHz,
      rightFrequency: _rightHz,
      benefit: 'Custom frequency session',
      isCustom: true,
    );
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PlayerScreen(preset: preset)),
    );
  }

  void _savePreset() {
    if (_formKey.currentState?.validate() != true) return;
    final preset = PresetModel(
      id: const Uuid().v4(),
      name: _nameController.text.trim(),
      emoji: '🎵',
      leftFrequency: _leftHz,
      rightFrequency: _rightHz,
      benefit: 'Custom preset — ${_brainWave} waves',
      isCustom: true,
    );
    ref.read(presetProvider.notifier).addPreset(preset);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Preset "${preset.name}" saved!'),
        backgroundColor: AppColors.success,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final diff = (_rightHz - _leftHz).abs();

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.customFrequency)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Brain Wave Badge
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: _waveColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: _waveColor.withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 10, height: 10,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: _waveColor),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$_brainWave Wave  •  ${diff.toStringAsFixed(1)} Hz diff',
                        style: TextStyle(
                            color: _waveColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Left Hz Slider
              FrequencySlider(
                label: AppStrings.leftHzLabel,
                value: _leftHz,
                color: AppColors.primary,
                onChanged: (v) => setState(() => _leftHz = v),
              ),

              const SizedBox(height: 20),

              // Right Hz Slider
              FrequencySlider(
                label: AppStrings.rightHzLabel,
                value: _rightHz,
                color: AppColors.accent,
                onChanged: (v) => setState(() => _rightHz = v),
              ),

              const SizedBox(height: 28),

              // Play Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _playCustom,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Play Custom Frequency'),
                ),
              ),

              const SizedBox(height: 28),
              const Divider(),
              const SizedBox(height: 20),

              // Save as Preset
              const Text(AppStrings.saveAsPreset,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: AppStrings.presetName,
                  hintText: 'e.g. My Morning Focus',
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter a preset name' : null,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _savePreset,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Save Preset'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
