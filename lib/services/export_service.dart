import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/preset_model.dart';
import '../services/hive_service.dart';

class ExportService {
  static final ExportService _instance = ExportService._internal();
  factory ExportService() => _instance;
  ExportService._internal();

  final HiveService _hiveService = HiveService();

  /// Export a preset as a JSON file and share via any app (WhatsApp, Email, etc.)
  Future<void> exportAndShare(PresetModel preset) async {
    // Step 1: Build JSON object
    final Map<String, dynamic> jsonData = {
      'id': 'coach_preset_${DateTime.now().millisecondsSinceEpoch}',
      'name': preset.name,
      'emoji': preset.emoji,
      'leftFrequency': preset.leftFrequency,
      'rightFrequency': preset.rightFrequency,
      'benefit': preset.benefit,
      'isCustom': true,
      'createdBy': _hiveService.coachName,
      'exportedAt': DateTime.now().toIso8601String(),
    };

    // Step 2: Save JSON file to temporary directory
    final directory = await getTemporaryDirectory();
    final safeFileName = preset.name
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(' ', '_');
    final filePath = '${directory.path}/$safeFileName.json';
    final file = File(filePath);
    await file.writeAsString(jsonEncode(jsonData), flush: true);

    // Step 3: Share via share_plus (WhatsApp / Email / Telegram / any app)
    await Share.shareXFiles(
      [XFile(filePath, mimeType: 'application/json')],
      text:
          '🎧 Your personal Binaural Beats preset is ready!\n\nTap the file to open it in the Binaural Beats app.',
      subject: 'Your Binaural Beats Preset – ${preset.name}',
    );

    // Clean up temp file after a delay
    Future.delayed(const Duration(minutes: 5), () {
      if (file.existsSync()) file.deleteSync();
    });
  }
}
