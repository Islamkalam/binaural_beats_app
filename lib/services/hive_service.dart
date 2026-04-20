import 'package:hive_flutter/hive_flutter.dart';
import '../models/preset_model.dart';
import '../models/reminder_model.dart';
import '../core/constants/frequencies.dart';

class HiveService {
  static final HiveService _instance = HiveService._internal();
  factory HiveService() => _instance;
  HiveService._internal();

  Box<PresetModel> get _presetsBox => Hive.box<PresetModel>('presets');
  Box<ReminderModel> get _remindersBox => Hive.box<ReminderModel>('reminders');
  Box get _settingsBox => Hive.box('settings');

  // ─── Presets ───────────────────────────────────────────────

  List<PresetModel> getAllPresets() {
    final custom = _presetsBox.values.toList();
    return [...FrequencyConstants.defaultPresets, ...custom];
  }

  List<PresetModel> getCustomPresets() {
    return _presetsBox.values.toList();
  }

  Future<void> savePreset(PresetModel preset) async {
    await _presetsBox.put(preset.id, preset);
  }

  Future<void> deletePreset(String id) async {
    await _presetsBox.delete(id);
  }

  PresetModel? getPresetById(String id) {
    // Check default first
    final defaultMatch = FrequencyConstants.defaultPresets
        .where((p) => p.id == id)
        .firstOrNull;
    if (defaultMatch != null) return defaultMatch;
    return _presetsBox.get(id);
  }

  // ─── Reminder ──────────────────────────────────────────────

  ReminderModel? getReminder() {
    if (_remindersBox.isEmpty) return null;
    return _remindersBox.values.first;
  }

  Future<void> saveReminder(ReminderModel reminder) async {
    await _remindersBox.put('reminder', reminder);
  }

  Future<void> deleteReminder() async {
    await _remindersBox.delete('reminder');
  }

  // ─── Settings ──────────────────────────────────────────────

  bool get isDarkTheme => _settingsBox.get('isDarkTheme', defaultValue: true);
  Future<void> setDarkTheme(bool value) async =>
      _settingsBox.put('isDarkTheme', value);

  String get coachName =>
      _settingsBox.get('coachName', defaultValue: 'Wellness Coach');
  Future<void> setCoachName(String name) async =>
      _settingsBox.put('coachName', name);
}
