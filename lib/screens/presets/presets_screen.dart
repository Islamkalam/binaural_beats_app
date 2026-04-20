import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/preset_provider.dart';
import '../../providers/audio_provider.dart';
import '../../widgets/preset_card.dart';
import '../custom_frequency/custom_frequency_screen.dart';
import '../player/player_screen.dart';

class PresetsScreen extends ConsumerWidget {
  const PresetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allPresets = ref.watch(presetProvider);
    final audioState = ref.watch(audioProvider);
    final notifier = ref.read(presetProvider.notifier);

    final defaultPresets = allPresets.where((p) => !p.isCustom).toList();
    final customPresets = allPresets.where((p) => p.isCustom).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.presetsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'New Custom Frequency',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const CustomFrequencyScreen()),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Default Presets
          const Text(AppStrings.defaultPresets,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...defaultPresets.map((preset) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: PresetCard(
                  preset: preset,
                  isPlaying: audioState.isPlaying &&
                      audioState.currentPreset?.id == preset.id,
                  showDelete: false,
                  onTap: () {
                    ref.read(audioProvider.notifier).play(preset);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => PlayerScreen(preset: preset)),
                    );
                  },
                ),
              )),

          // Custom Presets
          if (customPresets.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text(AppStrings.customPresets,
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...customPresets.map((preset) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: PresetCard(
                    preset: preset,
                    isPlaying: audioState.isPlaying &&
                        audioState.currentPreset?.id == preset.id,
                    showDelete: true,
                    onTap: () {
                      ref.read(audioProvider.notifier).play(preset);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => PlayerScreen(preset: preset)),
                      );
                    },
                    onDelete: () => _confirmDelete(
                        context, ref, notifier, preset.id, preset.name),
                  ),
                )),
          ],
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CustomFrequencyScreen()),
        ),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Custom', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref,
      PresetNotifier notifier, String id, String name) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Preset'),
        content: Text('Delete "$name"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              notifier.deletePreset(id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
