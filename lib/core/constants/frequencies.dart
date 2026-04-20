import '../../models/preset_model.dart';

class FrequencyConstants {
  // Hz Range
  static const double minHz = 50.0;
  static const double maxHz = 600.0;
  static const double defaultLeftHz = 200.0;
  static const double defaultRightHz = 204.0;

  // Brain Wave Ranges
  static const Map<String, Map<String, double>> brainWaveRanges = {
    'Delta': {'min': 1, 'max': 4},
    'Theta': {'min': 4, 'max': 8},
    'Alpha': {'min': 8, 'max': 13},
    'Beta': {'min': 13, 'max': 30},
    'Gamma': {'min': 30, 'max': 50},
  };

  // Get brain wave state from Hz difference
  static String getBrainWave(double leftHz, double rightHz) {
    final diff = (rightHz - leftHz).abs();
    if (diff >= 1 && diff <= 4) return 'Delta';
    if (diff > 4 && diff <= 8) return 'Theta';
    if (diff > 8 && diff <= 13) return 'Alpha';
    if (diff > 13 && diff <= 30) return 'Beta';
    if (diff > 30 && diff <= 50) return 'Gamma';
    return 'Custom';
  }

  // Default Presets
  static List<PresetModel> get defaultPresets => [
    PresetModel(
      id: 'default_1',
      name: 'Deep Sleep',
      emoji: '😴',
      leftFrequency: 100.0,
      rightFrequency: 104.0,
      benefit: 'Deep sleep support — Delta waves for insomnia relief',
      isCustom: false,
    ),
    PresetModel(
      id: 'default_2',
      name: 'Meditation',
      emoji: '🧘',
      leftFrequency: 200.0,
      rightFrequency: 204.0,
      benefit: 'Deep relaxation — Theta waves for stress relief',
      isCustom: false,
    ),
    PresetModel(
      id: 'default_3',
      name: 'Relax',
      emoji: '🌿',
      leftFrequency: 250.0,
      rightFrequency: 256.0,
      benefit: 'Stress relief — Theta waves for calm mind',
      isCustom: false,
    ),
    PresetModel(
      id: 'default_4',
      name: 'Focus',
      emoji: '🎯',
      leftFrequency: 300.0,
      rightFrequency: 310.0,
      benefit: 'Study & work focus — Alpha waves for clarity',
      isCustom: false,
    ),
    PresetModel(
      id: 'default_5',
      name: 'Energy',
      emoji: '⚡',
      leftFrequency: 400.0,
      rightFrequency: 420.0,
      benefit: 'Alertness & energy — Beta waves for motivation',
      isCustom: false,
    ),
    PresetModel(
      id: 'default_6',
      name: 'Anxiety Relief',
      emoji: '💙',
      leftFrequency: 200.0,
      rightFrequency: 206.0,
      benefit: 'Calm anxiety — Theta waves for peace of mind',
      isCustom: false,
    ),
    PresetModel(
      id: 'default_7',
      name: 'Creativity',
      emoji: '🎨',
      leftFrequency: 350.0,
      rightFrequency: 358.0,
      benefit: 'Creative thinking — Alpha waves for imagination',
      isCustom: false,
    ),
    PresetModel(
      id: 'default_8',
      name: 'Workout',
      emoji: '💪',
      leftFrequency: 450.0,
      rightFrequency: 480.0,
      benefit: 'High energy boost — Beta waves for peak performance',
      isCustom: false,
    ),
  ];

  // Timer Options (minutes)
  static const List<int> timerOptions = [5, 10, 15, 30, 60, 90, 120];
}
