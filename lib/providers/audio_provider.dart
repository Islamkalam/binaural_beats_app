import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/audio_service.dart';
import '../models/preset_model.dart';

// Audio state
class AudioState {
  final bool isPlaying;
  final bool isPaused;
  final double leftHz;
  final double rightHz;
  final double volume;
  final PresetModel? currentPreset;

  const AudioState({
    this.isPlaying = false,
    this.isPaused = false,
    this.leftHz = 200.0,
    this.rightHz = 204.0,
    this.volume = 0.8,
    this.currentPreset,
  });

  AudioState copyWith({
    bool? isPlaying,
    bool? isPaused,
    double? leftHz,
    double? rightHz,
    double? volume,
    PresetModel? currentPreset,
  }) =>
      AudioState(
        isPlaying: isPlaying ?? this.isPlaying,
        isPaused: isPaused ?? this.isPaused,
        leftHz: leftHz ?? this.leftHz,
        rightHz: rightHz ?? this.rightHz,
        volume: volume ?? this.volume,
        currentPreset: currentPreset ?? this.currentPreset,
      );
}

class AudioNotifier extends StateNotifier<AudioState> {
  final AudioService _audioService = AudioService();

  AudioNotifier() : super(const AudioState());

  Future<void> play(PresetModel preset) async {
    state = state.copyWith(
      leftHz: preset.leftFrequency,
      rightHz: preset.rightFrequency,
      currentPreset: preset,
    );
    await _audioService.playBinaural(
      leftHz: preset.leftFrequency,
      rightHz: preset.rightFrequency,
    );
    state = state.copyWith(isPlaying: true, isPaused: false);
  }

  Future<void> playCustom({required double leftHz, required double rightHz}) async {
    state = state.copyWith(leftHz: leftHz, rightHz: rightHz, currentPreset: null);
    await _audioService.playBinaural(leftHz: leftHz, rightHz: rightHz);
    state = state.copyWith(isPlaying: true, isPaused: false);
  }

  Future<void> pause() async {
    await _audioService.pause();
    state = state.copyWith(isPaused: true);
  }

  Future<void> resume() async {
    await _audioService.resume();
    state = state.copyWith(isPaused: false);
  }

  Future<void> stop() async {
    await _audioService.stop();
    state = state.copyWith(isPlaying: false, isPaused: false);
  }

  Future<void> setVolume(double volume) async {
    await _audioService.setVolume(volume);
    state = state.copyWith(volume: volume);
  }

  @override
  void dispose() {
    _audioService.stop();
    super.dispose();
  }
}

final audioProvider = StateNotifierProvider<AudioNotifier, AudioState>(
  (ref) => AudioNotifier(),
);
