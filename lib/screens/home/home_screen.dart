import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/frequencies.dart';
import '../../providers/preset_provider.dart';
import '../../providers/audio_provider.dart';
import '../../widgets/preset_card.dart';
import '../player/player_screen.dart';
import '../presets/presets_screen.dart';
import '../settings/settings_screen.dart';
import '../reminder/reminder_screen.dart';
import '../create_client_preset/create_client_preset_screen.dart';
import 'dart:math';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _getDailyQuote() {
    final idx = DateTime.now().day % AppStrings.dailyQuotes.length;
    return AppStrings.dailyQuotes[idx];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presets = ref.watch(presetProvider);
    final audioState = ref.watch(audioProvider);
    final defaultPresets = FrequencyConstants.defaultPresets.take(4).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.accent],
                ),
              ),
              child: const Icon(Icons.headphones, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 10),
            const Text(AppStrings.appName),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ReminderScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Daily Quote Card
          _QuoteCard(quote: _getDailyQuote()),
          const SizedBox(height: 20),

          // Now Playing Banner (if playing)
          if (audioState.isPlaying) ...[
            _NowPlayingBanner(audioState: audioState, ref: ref),
            const SizedBox(height: 20),
          ],

          // Quick Play Section
          _SectionHeader(
            title: 'Quick Play',
            onSeeAll: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const PresetsScreen())),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
            ),
            itemCount: defaultPresets.length,
            itemBuilder: (context, i) => PresetCard(
              preset: defaultPresets[i],
              isPlaying: audioState.isPlaying &&
                  audioState.currentPreset?.id == defaultPresets[i].id,
              onTap: () {
                ref.read(audioProvider.notifier).play(defaultPresets[i]);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PlayerScreen(preset: defaultPresets[i]),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // Coach Tools Section
          _SectionHeader(title: 'Coach Tools'),
          const SizedBox(height: 12),
          _CoachToolCard(
            icon: Icons.person_add_outlined,
            title: AppStrings.createClientPreset,
            subtitle: 'Create & share a custom preset for your client',
            color: AppColors.accent,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const CreateClientPresetScreen()),
            ),
          ),

          const SizedBox(height: 24),

          // Brain Waves Info
          const _BrainWaveInfo(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  final String quote;
  const _QuoteCard({required this.quote});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.15),
            AppColors.accent.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.format_quote, color: AppColors.accent, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              quote,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.textSecondary
                    : Colors.black87,
                fontSize: 13,
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NowPlayingBanner extends StatelessWidget {
  final AudioState audioState;
  final WidgetRef ref;
  const _NowPlayingBanner({required this.audioState, required this.ref});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (audioState.currentPreset != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PlayerScreen(preset: audioState.currentPreset!),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.accent],
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(Icons.graphic_eq, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Now Playing',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w500),
                  ),
                  Text(
                    audioState.currentPreset?.name ?? 'Custom Frequency',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                audioState.isPaused ? Icons.play_arrow : Icons.pause,
                color: Colors.white,
              ),
              onPressed: () {
                if (audioState.isPaused) {
                  ref.read(audioProvider.notifier).resume();
                } else {
                  ref.read(audioProvider.notifier).pause();
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.stop, color: Colors.white),
              onPressed: () => ref.read(audioProvider.notifier).stop(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  const _SectionHeader({required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            child: const Text('See All'),
          ),
      ],
    );
  }
}

class _CoachToolCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _CoachToolCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.textSecondary
                              : Colors.black54,
                          fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: color),
          ],
        ),
      ),
    );
  }
}

class _BrainWaveInfo extends StatelessWidget {
  const _BrainWaveInfo();

  @override
  Widget build(BuildContext context) {
    final waves = [
      {'name': 'Delta', 'hz': '1–4 Hz', 'state': 'Deep Sleep', 'color': AppColors.delta},
      {'name': 'Theta', 'hz': '4–8 Hz', 'state': 'Meditation', 'color': AppColors.theta},
      {'name': 'Alpha', 'hz': '8–13 Hz', 'state': 'Focus', 'color': AppColors.alpha},
      {'name': 'Beta', 'hz': '13–30 Hz', 'state': 'Energy', 'color': AppColors.beta},
      {'name': 'Gamma', 'hz': '30–50 Hz', 'state': 'Peak', 'color': AppColors.gamma},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Brain Wave Guide',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...waves.map((w) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: (w['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: (w['color'] as Color).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: w['color'] as Color,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(w['name'] as String,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(width: 8),
                    Text(w['hz'] as String,
                        style: TextStyle(
                            color: w['color'] as Color,
                            fontSize: 12,
                            fontWeight: FontWeight.w500)),
                    const Spacer(),
                    Text(w['state'] as String,
                        style: const TextStyle(fontSize: 13)),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}
