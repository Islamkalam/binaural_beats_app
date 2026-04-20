# 🎧 Binaural Beats Generator

**Flutter Mobile App — White Label for Wellness Coaches**

---

## Overview

A complete Flutter app for generating binaural beats audio. Coaches can white-label this app and sell it to their clients. The standout feature is **Coach → Client Preset Sharing**: coaches create custom frequency presets and share them via WhatsApp/Email — clients tap the file and it imports directly into the app.

---

## Features

| Feature | Description |
|---|---|
| 🎵 Binaural Beats Player | Left/Right channel sine waves with volume control |
| 🧘 8 Default Presets | Delta, Theta, Alpha, Beta, Gamma states |
| 🎛️ Custom Frequency | Manual Hz slider — save as personal preset |
| ⏱️ Sleep Timer | Auto-stop after 5/10/15/30/60/90/120 min |
| 🔔 Daily Reminder | Local push notification at custom time |
| 📤 Coach Export | Create client preset → share as .json via any app |
| 📥 Client Import | Tap .json file → app opens → preset auto-saves |
| 🌓 Dark/Light Theme | Fully themed dark & light modes |
| 🏷️ White Label | Coach name, branding, colors configurable |
| 📱 Fully Offline | No server — all data stays on device (Hive) |

---

## Project Structure

```
lib/
├── main.dart
├── core/
│   ├── constants/
│   │   ├── frequencies.dart     # All Hz values & default presets
│   │   ├── app_colors.dart      # Brand colors
│   │   └── app_strings.dart     # All text labels
│   ├── theme/
│   │   └── app_theme.dart       # Dark/Light theme
│   └── utils/
│       └── timer_utils.dart     # Timer helpers
├── models/
│   ├── preset_model.dart        # Hive model for presets
│   └── reminder_model.dart      # Hive model for reminders
├── services/
│   ├── audio_service.dart       # Sine wave generator + just_audio
│   ├── hive_service.dart        # Local DB read/write
│   ├── notification_service.dart
│   ├── export_service.dart      # Coach: JSON export + share_plus
│   └── import_service.dart      # Client: receive_sharing_intent
├── providers/
│   ├── audio_provider.dart      # Riverpod audio state
│   ├── preset_provider.dart     # Riverpod presets state
│   └── timer_provider.dart      # Riverpod timer state
├── screens/
│   ├── splash/
│   ├── home/
│   ├── player/
│   ├── custom_frequency/
│   ├── presets/
│   ├── timer/
│   ├── reminder/
│   ├── settings/
│   ├── create_client_preset/    # Coach feature (NEW)
│   └── import_preset/           # Client feature (NEW)
└── widgets/
    ├── frequency_slider.dart
    ├── preset_card.dart
    └── player_controls.dart
```

---

## Setup Instructions

### 1. Prerequisites

- Flutter SDK (latest stable) — https://flutter.dev/docs/get-started/install
- Dart SDK (included with Flutter)
- Android Studio or VS Code
- Xcode (for iOS builds, macOS only)

### 2. Install

```bash
# Clone / unzip the project
cd binaural_beats_app

# Get dependencies
flutter pub get
```

### 3. Run

```bash
# Android
flutter run

# iOS
flutter run -d ios

# Release build
flutter build apk --release        # Android
flutter build ios --release        # iOS
```

---

## White Label Customization

To customize for a coach's brand:

| Item | Location |
|---|---|
| App Name | `pubspec.yaml` → `name` + `android/AndroidManifest.xml` |
| Coach Name | Settings Screen in app (saved to Hive) |
| Primary Color | `lib/core/constants/app_colors.dart` → `AppColors.primary` |
| App Icon | Replace `android/app/src/main/res/mipmap-*/ic_launcher.png` + `ios/Runner/Assets.xcassets/AppIcon.appiconset/` |
| Splash Logo | `lib/screens/splash/splash_screen.dart` |
| About Text | `lib/core/constants/app_strings.dart` → `coachBio` |

---

## Coach → Client Preset Sharing Flow

```
Coach opens app
    └─> Create Client Preset screen
        └─> Enter client name + set frequencies
            └─> Tap "Export & Share"
                └─> share_plus opens share sheet
                    └─> Coach sends .json via WhatsApp/Email

Client receives .json file
    └─> Taps the file
        └─> Phone: "Open with Binaural Beats?"
            └─> Import Preset Screen opens
                └─> Preview: name, Hz, brain wave, benefit
                    └─> Client taps "Import"
                        └─> Preset saved to Hive ✅
```

---

## Dependencies

```yaml
just_audio: ^0.9.36          # Audio playback
audio_session: ^0.1.18       # Background audio
flutter_sound: ^9.2.13       # Sine wave generation
flutter_riverpod: ^2.4.9     # State management
hive: ^2.2.3                 # Local database
hive_flutter: ^1.1.0
flutter_local_notifications: ^16.3.0  # Reminders
share_plus: ^7.2.1           # Export: share JSON file
receive_sharing_intent: ^1.8.0  # Import: receive JSON file
path_provider: ^2.1.2        # File paths
uuid: ^4.3.3                 # Unique IDs
```

---

## Brain Waves Reference

| Wave | Hz | State | Use Case |
|---|---|---|---|
| Delta | 1–4 Hz | Deep Sleep | Insomnia, deep rest |
| Theta | 4–8 Hz | Meditation | Deep relaxation, stress relief |
| Alpha | 8–13 Hz | Relaxed Focus | Study, light meditation |
| Beta | 13–30 Hz | Active Thinking | Energy, alertness, focus |
| Gamma | 30–50 Hz | High Performance | Peak performance, creativity |

---

## Notes

- **Always use headphones** — binaural beats only work with stereo headphones
- App is **fully offline** — no Firebase, no Supabase, zero server cost
- Each coach receives their own build with custom branding
- Version: 1.0.0 | Framework: Flutter | April 2026
