import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/reminder_model.dart';
import '../../services/hive_service.dart';
import '../../services/notification_service.dart';

class ReminderScreen extends ConsumerStatefulWidget {
  const ReminderScreen({super.key});

  @override
  ConsumerState<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends ConsumerState<ReminderScreen> {
  final HiveService _hiveService = HiveService();
  final NotificationService _notificationService = NotificationService();

  ReminderModel? _reminder;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 0);
  bool _isEnabled = false;

  @override
  void initState() {
    super.initState();
    final saved = _hiveService.getReminder();
    if (saved != null) {
      setState(() {
        _reminder = saved;
        _selectedTime = TimeOfDay(hour: saved.hour, minute: saved.minute);
        _isEnabled = saved.isEnabled;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _saveReminder() async {
    final reminder = ReminderModel(
      hour: _selectedTime.hour,
      minute: _selectedTime.minute,
      isEnabled: _isEnabled,
    );
    await _hiveService.saveReminder(reminder);

    if (_isEnabled) {
      await _notificationService.scheduleDailyReminder(
        hour: _selectedTime.hour,
        minute: _selectedTime.minute,
        title: '🎧 Time for your session!',
        body: 'Start your Binaural Beats session now.',
      );
    } else {
      await _notificationService.cancelAllReminders();
    }

    setState(() => _reminder = reminder);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEnabled ? 'Reminder set!' : 'Reminder turned off'),
          backgroundColor:
              _isEnabled ? AppColors.success : AppColors.textSecondary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.reminderTitle)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Toggle
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.notifications,
                        color: AppColors.primary),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Daily Reminder',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                        Text('Get a reminder every day',
                            style: TextStyle(
                                fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isEnabled,
                    activeColor: AppColors.primary,
                    onChanged: (v) => setState(() => _isEnabled = v),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Time Picker
            AnimatedOpacity(
              opacity: _isEnabled ? 1.0 : 0.4,
              duration: const Duration(milliseconds: 200),
              child: GestureDetector(
                onTap: _isEnabled ? _pickTime : null,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time,
                          color: AppColors.primary, size: 28),
                      const SizedBox(width: 16),
                      Text(
                        _selectedTime.format(context),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          letterSpacing: 2,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.edit, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saveReminder,
                icon: const Icon(Icons.save),
                label: const Text('Save Reminder'),
              ),
            ),

            if (_reminder != null) ...[
              const SizedBox(height: 20),
              Center(
                child: Text(
                  _reminder!.isEnabled
                      ? '✅ Reminder active at ${_reminder!.formattedTime}'
                      : '🔕 Reminder is off',
                  style: TextStyle(
                    color: _reminder!.isEnabled
                        ? AppColors.success
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
