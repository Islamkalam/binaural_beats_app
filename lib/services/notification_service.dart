// import 'package:awesome_notifications/awesome_notifications.dart';
// import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<void> initialize() async {
    // Notifications disabled temporarily
  }

  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    // Notifications disabled temporarily
  }

  Future<void> cancelAllReminders() async {
    // Notifications disabled temporarily
  }
}
