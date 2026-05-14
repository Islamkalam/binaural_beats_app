import 'dart:convert';
import 'dart:io';
import '../models/preset_model.dart';

class ImportService {
  static final ImportService _instance = ImportService._internal();
  factory ImportService() => _instance;
  ImportService._internal();

  Future<PresetModel?> getInitialSharedFile() async {
    return null;
  }

  Stream<PresetModel?> listenForSharedFiles() {
    return const Stream.empty();
  }

  PresetModel? parseFromJsonString(String jsonString) {
    try {
      final Map<String, dynamic> json =
          jsonDecode(jsonString) as Map<String, dynamic>;
      if (!_isValidPresetJson(json)) return null;
      return PresetModel.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  bool _isValidPresetJson(Map<String, dynamic> json) {
    return json.containsKey('name') &&
        json.containsKey('leftFrequency') &&
        json.containsKey('rightFrequency');
  }
}
