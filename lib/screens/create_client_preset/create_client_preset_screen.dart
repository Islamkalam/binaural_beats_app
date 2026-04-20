import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/frequencies.dart';
import '../../models/preset_model.dart';
import '../../services/export_service.dart';
import '../../services/hive_service.dart';
import '../../widgets/frequency_slider.dart';

class CreateClientPresetScreen extends ConsumerStatefulWidget {
  const CreateClientPresetScreen({super.key});

  @override
  ConsumerState<CreateClientPresetScreen> createState() =>
      _CreateClientPresetScreenState();
}

class _CreateClientPresetScreenState
    extends ConsumerState<CreateClientPresetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _clientNameController = TextEditingController();
  final _benefitController = TextEditingController();
  final ExportService _exportService = ExportService();
  final HiveService _hiveService = HiveService();

  double _leftHz = 100.0;
  double _rightHz = 104.0;
  bool _isExporting = false;

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

  String get _waveEmoji {
    switch (_brainWave) {
      case 'Delta': return '😴';
      case 'Theta': return '🧘';
      case 'Alpha': return '🎯';
      case 'Beta': return '⚡';
      case 'Gamma': return '🚀';
      default: return '🎵';
    }
  }

  Future<void> _exportAndShare() async {
    if (_formKey.currentState?.validate() != true) return;

    setState(() => _isExporting = true);

    try {
      final preset = PresetModel(
        id: 'coach_${const Uuid().v4()}',
        name: _clientNameController.text.trim(),
        emoji: _waveEmoji,
        leftFrequency: _leftHz,
        rightFrequency: _rightHz,
        benefit: _benefitController.text.trim().isNotEmpty
            ? _benefitController.text.trim()
            : 'Custom preset by ${_hiveService.coachName}',
        isCustom: true,
        createdBy: _hiveService.coachName,
        exportedAt: DateTime.now().toIso8601String(),
      );

      await _exportService.exportAndShare(preset);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  void dispose() {
    _clientNameController.dispose();
    _benefitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final diff = (_rightHz - _leftHz).abs();

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.createClientPresetTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.accent.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        color: AppColors.accent, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Create a custom frequency preset for your client. '
                        'They will receive it as a .json file and can import it directly into the app.',
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.textSecondary
                              : Colors.black54,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Client Name
              const Text('Client Name',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _clientNameController,
                decoration: const InputDecoration(
                  hintText: AppStrings.clientNameHint,
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Please enter client name'
                    : null,
              ),

              const SizedBox(height: 24),

              // Frequencies
              FrequencySlider(
                label: AppStrings.leftHzLabel,
                value: _leftHz,
                color: AppColors.primary,
                onChanged: (v) => setState(() => _leftHz = v),
              ),

              const SizedBox(height: 16),

              FrequencySlider(
                label: AppStrings.rightHzLabel,
                value: _rightHz,
                color: AppColors.accent,
                onChanged: (v) => setState(() => _rightHz = v),
              ),

              const SizedBox(height: 20),

              // Auto-computed brain wave badge
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: _waveColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: _waveColor.withOpacity(0.5)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 10, height: 10,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle, color: _waveColor),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$_brainWave Wave',
                            style: TextStyle(
                                color: _waveColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Difference: ${diff.toStringAsFixed(1)} Hz',
                        style: TextStyle(
                            color: _waveColor.withOpacity(0.8),
                            fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Benefit/Note
              const Text('Benefit / Note (Optional)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _benefitController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: AppStrings.benefitNoteHint,
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 24),
                    child: Icon(Icons.note_outlined),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Preview Card
              const Text('Preview',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              _PreviewCard(
                name: _clientNameController.text.isEmpty
                    ? 'Client Name'
                    : _clientNameController.text,
                emoji: _waveEmoji,
                leftHz: _leftHz,
                rightHz: _rightHz,
                brainWave: _brainWave,
                waveColor: _waveColor,
                benefit: _benefitController.text.isEmpty
                    ? 'Benefit note will appear here'
                    : _benefitController.text,
              ),

              const SizedBox(height: 28),

              // Export Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isExporting ? null : _exportAndShare,
                  icon: _isExporting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.share),
                  label: Text(_isExporting ? 'Exporting...' : AppStrings.exportAndShare),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // How it works
              _HowItWorks(),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  final String name;
  final String emoji;
  final double leftHz;
  final double rightHz;
  final String brainWave;
  final Color waveColor;
  final String benefit;

  const _PreviewCard({
    required this.name,
    required this.emoji,
    required this.leftHz,
    required this.rightHz,
    required this.brainWave,
    required this.waveColor,
    required this.benefit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: waveColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: waveColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 36)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text(
                  '${leftHz.toStringAsFixed(0)} Hz  •  ${rightHz.toStringAsFixed(0)} Hz  •  $brainWave',
                  style: TextStyle(color: waveColor, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(benefit,
                    style: const TextStyle(fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HowItWorks extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final steps = [
      '1. Fill in client name and set frequencies',
      '2. Tap "Export & Share"',
      '3. Choose WhatsApp / Email / Telegram',
      '4. Client taps the .json file',
      '5. App opens automatically — preset saved!',
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('How it works',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: AppColors.primary)),
          const SizedBox(height: 8),
          ...steps.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(s,
                    style: const TextStyle(
                        fontSize: 12, height: 1.4)),
              )),
        ],
      ),
    );
  }
}
