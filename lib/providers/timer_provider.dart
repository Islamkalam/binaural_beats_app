import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TimerState {
  final int totalSeconds;
  final int remainingSeconds;
  final bool isRunning;
  final bool isFinished;

  const TimerState({
    this.totalSeconds = 0,
    this.remainingSeconds = 0,
    this.isRunning = false,
    this.isFinished = false,
  });

  double get progress =>
      totalSeconds == 0 ? 0 : 1 - (remainingSeconds / totalSeconds);

  TimerState copyWith({
    int? totalSeconds,
    int? remainingSeconds,
    bool? isRunning,
    bool? isFinished,
  }) =>
      TimerState(
        totalSeconds: totalSeconds ?? this.totalSeconds,
        remainingSeconds: remainingSeconds ?? this.remainingSeconds,
        isRunning: isRunning ?? this.isRunning,
        isFinished: isFinished ?? this.isFinished,
      );
}

class TimerNotifier extends StateNotifier<TimerState> {
  Timer? _timer;
  void Function()? onTimerFinished;

  TimerNotifier() : super(const TimerState());

  void setTimer(int minutes) {
    final seconds = minutes * 60;
    _timer?.cancel();
    state = TimerState(
      totalSeconds: seconds,
      remainingSeconds: seconds,
      isRunning: false,
      isFinished: false,
    );
  }

  void start() {
    if (state.remainingSeconds <= 0) return;
    _timer?.cancel();
    state = state.copyWith(isRunning: true, isFinished: false);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    if (state.remainingSeconds <= 1) {
      _timer?.cancel();
      state = state.copyWith(
        remainingSeconds: 0,
        isRunning: false,
        isFinished: true,
      );
      onTimerFinished?.call();
    } else {
      state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
    }
  }

  void pause() {
    _timer?.cancel();
    state = state.copyWith(isRunning: false);
  }

  void reset() {
    _timer?.cancel();
    state = TimerState(
      totalSeconds: state.totalSeconds,
      remainingSeconds: state.totalSeconds,
      isRunning: false,
      isFinished: false,
    );
  }

  void cancel() {
    _timer?.cancel();
    state = const TimerState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final timerProvider = StateNotifierProvider<TimerNotifier, TimerState>(
  (ref) => TimerNotifier(),
);
