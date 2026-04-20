import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/preset_model.dart';
import '../services/hive_service.dart';
import '../core/constants/frequencies.dart';

class PresetNotifier extends StateNotifier<List<PresetModel>> {
  final HiveService _hiveService = HiveService();

  PresetNotifier() : super([]) {
    loadPresets();
  }

  void loadPresets() {
    state = _hiveService.getAllPresets();
  }

  Future<void> addPreset(PresetModel preset) async {
    await _hiveService.savePreset(preset);
    loadPresets();
  }

  Future<void> deletePreset(String id) async {
    await _hiveService.deletePreset(id);
    loadPresets();
  }

  Future<void> updatePreset(PresetModel preset) async {
    await _hiveService.savePreset(preset);
    loadPresets();
  }

  List<PresetModel> get defaultPresets => FrequencyConstants.defaultPresets;
  List<PresetModel> get customPresets => _hiveService.getCustomPresets();
}

final presetProvider = StateNotifierProvider<PresetNotifier, List<PresetModel>>(
  (ref) => PresetNotifier(),
);
