import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ExamTimerStatus {
  initial,
  running,
  paused,
  timeUp,
  completed,
}

class ExamTimerState {
  final int totalSeconds;
  final int remainingSeconds;
  final ExamTimerStatus status;
  final bool isWarning; // < 5 minutes
  final bool isCritical; // < 1 minute

  const ExamTimerState({
    required this.totalSeconds,
    required this.remainingSeconds,
    this.status = ExamTimerStatus.initial,
    this.isWarning = false,
    this.isCritical = false,
  });

  double get progressRatio =>
      totalSeconds > 0 ? (remainingSeconds / totalSeconds).clamp(0.0, 1.0) : 0.0;

  String get formattedTime {
    final hours = remainingSeconds ~/ 3600;
    final minutes = (remainingSeconds % 3600) ~/ 60;
    final seconds = remainingSeconds % 60;

    final minStr = minutes.toString().padLeft(2, '0');
    final secStr = seconds.toString().padLeft(2, '0');

    if (hours > 0) {
      final hrStr = hours.toString().padLeft(2, '0');
      return '$hrStr:$minStr:$secStr';
    }
    return '$minStr:$secStr';
  }

  ExamTimerState copyWith({
    int? totalSeconds,
    int? remainingSeconds,
    ExamTimerStatus? status,
    bool? isWarning,
    bool? isCritical,
  }) {
    return ExamTimerState(
      totalSeconds: totalSeconds ?? this.totalSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      status: status ?? this.status,
      isWarning: isWarning ?? this.isWarning,
      isCritical: isCritical ?? this.isCritical,
    );
  }
}

/// Robust, offline-resilient countdown timer for exams
class ExamTimerNotifier extends StateNotifier<ExamTimerState> {
  final Future<void> Function()? _onAutoSubmit;
  Timer? _timer;
  DateTime? _targetEndTime;
  int _pausedRemainingSeconds = 0;

  ExamTimerNotifier({
    required int durationSeconds,
    Future<void> Function()? onAutoSubmit,
  })  : _onAutoSubmit = onAutoSubmit,
        super(ExamTimerState(
          totalSeconds: durationSeconds,
          remainingSeconds: durationSeconds,
          status: ExamTimerStatus.initial,
        ));

  /// Start the offline exam timer
  void start() {
    if (state.status == ExamTimerStatus.running) return;

    _pausedRemainingSeconds = state.remainingSeconds;
    _targetEndTime = DateTime.now().add(Duration(seconds: _pausedRemainingSeconds));

    state = state.copyWith(status: ExamTimerStatus.running);

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _tick();
    });
  }

  /// Pause timer (e.g., if student pauses in practice mode)
  void pause() {
    if (state.status != ExamTimerStatus.running) return;

    _timer?.cancel();
    _pausedRemainingSeconds = state.remainingSeconds;
    state = state.copyWith(status: ExamTimerStatus.paused);
  }

  /// Resume paused timer
  void resume() {
    if (state.status != ExamTimerStatus.paused) return;
    start();
  }

  /// Stop or complete timer
  void stop() {
    _timer?.cancel();
    state = state.copyWith(status: ExamTimerStatus.completed);
  }

  /// Internal tick calculating remaining seconds based on absolute device time
  /// Guarantees offline resilience even if the UI thread lags or device briefly sleeps
  void _tick() {
    if (_targetEndTime == null) return;

    final now = DateTime.now();
    final difference = _targetEndTime!.difference(now).inSeconds;

    if (difference <= 0) {
      _timer?.cancel();
      state = state.copyWith(
        remainingSeconds: 0,
        status: ExamTimerStatus.timeUp,
        isWarning: false,
        isCritical: true,
      );
      _triggerAutoSubmit();
    } else {
      final isCrit = difference <= 60;
      final isWarn = difference <= 300 && !isCrit;

      state = state.copyWith(
        remainingSeconds: difference,
        status: ExamTimerStatus.running,
        isWarning: isWarn,
        isCritical: isCrit,
      );
    }
  }

  void _triggerAutoSubmit() {
    if (_onAutoSubmit != null) {
      _onAutoSubmit!();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// Riverpod family provider for managing the exam timer
final examTimerProvider = StateNotifierProvider.autoDispose
    .family<ExamTimerNotifier, ExamTimerState, ExamTimerParams>((ref, params) {
  final notifier = ExamTimerNotifier(
    durationSeconds: params.durationSeconds,
    onAutoSubmit: params.onAutoSubmit,
  );
  if (params.autoStart) {
    notifier.start();
  }
  return notifier;
});

class ExamTimerParams {
  final int durationSeconds;
  final Future<void> Function()? onAutoSubmit;
  final bool autoStart;

  const ExamTimerParams({
    required this.durationSeconds,
    this.onAutoSubmit,
    this.autoStart = true,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExamTimerParams &&
          runtimeType == other.runtimeType &&
          durationSeconds == other.durationSeconds;

  @override
  int get hashCode => durationSeconds.hashCode;
}
