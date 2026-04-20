import 'dart:convert';
import 'dart:io';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import '../models/preset_model.dart';

class ImportService {
  static final ImportService _instance = ImportService._internal();
  factory ImportService() => _instance;
  ImportService._internal();

  /// Called when app is launched from a .json file tap (app was closed)
  Future<PresetModel?> getInitialSharedFile() async {
    try {
      final List<SharedMediaFile> files =
          await ReceiveSharingIntent.instance.getInitialMedia();
      if (files.isNotEmpty) {
        return _parseFile(files.first.path);
      }
    } catch (e) {
      // No initial file
    }
    return null;
  }

  /// Stream for when app is already open and receives a .json file
  Stream<PresetModel?> listenForSharedFiles() {
    return ReceiveSharingIntent.instance.getMediaStream().map((files) {
      if (files.isEmpty) return null;
      return _parseFile(files.first.path);
    });
  }

  /// Parse a .json file path into a PresetModel
  PresetModel? _parseFile(String? filePath) {
    if (filePath == null || filePath.isEmpty) return null;

    try {
      final file = File(filePath);
      if (!file.existsSync()) return null;

      final content = file.readAsStringSync();
      final Map<String, dynamic> json =
          jsonDecode(content) as Map<String, dynamic>;

      // Validate required fields
      if (!_isValidPresetJson(json)) return null;

      return PresetModel.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  /// Validate that JSON has required preset fields
  bool _isValidPresetJson(Map<String, dynamic> json) {
    return json.containsKey('name') &&
        json.containsKey('leftFrequency') &&
        json.containsKey('rightFrequency') &&
        (json['leftFrequency'] is num) &&
        (json['rightFrequency'] is num);
  }

  /// Parse preset from raw JSON string (for testing / manual import)
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
}
