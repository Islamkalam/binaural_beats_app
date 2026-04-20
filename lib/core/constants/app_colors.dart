import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand Colors
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF9C94FF);
  static const Color primaryDark = Color(0xFF3D35CC);

  // Accent
  static const Color accent = Color(0xFF00D4AA);
  static const Color accentLight = Color(0xFF4DFFDA);

  // Background
  static const Color darkBg = Color(0xFF0D0D1A);
  static const Color darkSurface = Color(0xFF1A1A2E);
  static const Color darkCard = Color(0xFF16213E);
  static const Color lightBg = Color(0xFFF5F5FF);
  static const Color lightSurface = Color(0xFFFFFFFF);

  // Brain Wave Colors
  static const Color delta = Color(0xFF4A90D9);    // Deep Sleep - Blue
  static const Color theta = Color(0xFF9B59B6);    // Meditation - Purple
  static const Color alpha = Color(0xFF27AE60);    // Relaxed Focus - Green
  static const Color beta = Color(0xFFE67E22);     // Active Thinking - Orange
  static const Color gamma = Color(0xFFE74C3C);    // High Performance - Red

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0CC);
  static const Color textDark = Color(0xFF1A1A2E);

  // Status
  static const Color success = Color(0xFF2ECC71);
  static const Color warning = Color(0xFFF39C12);
  static const Color error = Color(0xFFE74C3C);

  // Gradient pairs
  static const List<Color> sleepGradient = [Color(0xFF1A1A4E), Color(0xFF0D0D2E)];
  static const List<Color> focusGradient = [Color(0xFF1A3A1A), Color(0xFF0D1A0D)];
  static const List<Color> relaxGradient = [Color(0xFF2A1A4E), Color(0xFF150D2E)];
  static const List<Color> energyGradient = [Color(0xFF4E2A0D), Color(0xFF2E150D)];
}
