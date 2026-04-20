import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import 'core/theme/app_theme.dart';
import 'models/preset_model.dart';
import 'models/reminder_model.dart';
import 'screens/splash/splash_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(PresetModelAdapter());
  Hive.registerAdapter(ReminderModelAdapter());
  await Hive.openBox<PresetModel>('presets');
  await Hive.openBox<ReminderModel>('reminders');
  await Hive.openBox('settings');

  // Initialize Notifications
  final notificationService = NotificationService();
  await notificationService.initialize();

  runApp(
    const ProviderScope(
      child: BinauralBeatsApp(),
    ),
  );
}

class BinauralBeatsApp extends ConsumerWidget {
  const BinauralBeatsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsBox = Hive.box('settings');
    final isDark = settingsBox.get('isDarkTheme', defaultValue: true) as bool;

    return MaterialApp(
      title: 'Binaural Beats',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: const SplashScreen(),
    );
  }
}
