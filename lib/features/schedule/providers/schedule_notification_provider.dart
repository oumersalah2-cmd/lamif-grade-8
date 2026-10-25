import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/study_notification_service.dart';

/// State representation for daily study reminders
class ReminderState {
  final bool isEnabled;
  final TimeOfDay reminderTime;
  final bool isLoading;

  const ReminderState({
    this.isEnabled = true,
    this.reminderTime = const TimeOfDay(hour: 17, minute: 0),
    this.isLoading = false,
  });

  ReminderState copyWith({
    bool? isEnabled,
    TimeOfDay? reminderTime,
    bool? isLoading,
  }) {
    return ReminderState(
      isEnabled: isEnabled ?? this.isEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Service Provider
final studyNotificationServiceProvider = Provider<IStudyNotificationService>((ref) {
  return StudyNotificationService();
});

/// Riverpod StateNotifier managing daily study reminders
class ReminderNotifier extends StateNotifier<ReminderState> {
  final IStudyNotificationService _service;

  ReminderNotifier(this._service) : super(const ReminderState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    state = state.copyWith(isLoading: true);
    final enabled = await _service.isReminderEnabled();
    final time = await _service.getReminderTime();
    state = state.copyWith(
      isEnabled: enabled,
      reminderTime: time,
      isLoading: false,
    );
  }

  Future<void> toggleEnabled(bool enabled) async {
    state = state.copyWith(isEnabled: enabled);
    await _service.saveReminderSettings(enabled: enabled, time: state.reminderTime);
  }

  Future<void> updateTime(TimeOfDay newTime) async {
    state = state.copyWith(reminderTime: newTime);
    await _service.saveReminderSettings(enabled: state.isEnabled, time: newTime);
  }
}

/// StateNotifierProvider for daily reminders
final reminderNotifierProvider = StateNotifierProvider<ReminderNotifier, ReminderState>((ref) {
  final service = ref.watch(studyNotificationServiceProvider);
  return ReminderNotifier(service);
});
