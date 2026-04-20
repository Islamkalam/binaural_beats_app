class TimerUtils {
  /// Format seconds to MM:SS string
  static String formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Format minutes to human-readable label
  static String minutesToLabel(int minutes) {
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final remaining = minutes % 60;
    if (remaining == 0) return '$hours hr';
    return '$hours hr $remaining min';
  }

  /// Convert minutes to seconds
  static int minutesToSeconds(int minutes) => minutes * 60;
}
