import 'package:hive/hive.dart';

part 'reminder_model.g.dart';

@HiveType(typeId: 1)
class ReminderModel extends HiveObject {
  @HiveField(0)
  int hour;

  @HiveField(1)
  int minute;

  @HiveField(2)
  bool isEnabled;

  @HiveField(3)
  String label;

  ReminderModel({
    required this.hour,
    required this.minute,
    this.isEnabled = true,
    this.label = 'Daily Binaural Beats Session',
  });

  String get formattedTime {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final displayMinute = minute.toString().padLeft(2, '0');
    return '$displayHour:$displayMinute $period';
  }
}
