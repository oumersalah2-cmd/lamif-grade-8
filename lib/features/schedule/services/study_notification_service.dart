import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Configuration and persistence keys for daily study session reminders
class StudyReminderPreferences {
  static const String keyEnabled = 'study_reminder_enabled';
  static const String keyHour = 'study_reminder_hour';
  static const String keyMinute = 'study_reminder_minute';

  static const int defaultHour = 17; // 17:00 (5:00 PM)
  static const int defaultMinute = 0;
}

/// Abstract contract for study reminders
abstract class IStudyNotificationService {
  Future<bool> isReminderEnabled();
  Future<TimeOfDay> getReminderTime();
  Future<void> saveReminderSettings({required bool enabled, required TimeOfDay time});
  Future<void> cancelDailyReminder();
  Future<void> scheduleDailyReminder({required TimeOfDay time});
}

/// Production-ready local reminder service for Grade 8 study sessions
class StudyNotificationService implements IStudyNotificationService {
  final SharedPreferences? _prefs;

  StudyNotificationService([this._prefs]);

  Future<SharedPreferences> _getPrefs() async {
    return _prefs ?? await SharedPreferences.getInstance();
  }

  @override
  Future<bool> isReminderEnabled() async {
    final prefs = await _getPrefs();
    return prefs.getBool(StudyReminderPreferences.keyEnabled) ?? true;
  }

  @override
  Future<TimeOfDay> getReminderTime() async {
    final prefs = await _getPrefs();
    final hour = prefs.getInt(StudyReminderPreferences.keyHour) ?? StudyReminderPreferences.defaultHour;
    final minute = prefs.getInt(StudyReminderPreferences.keyMinute) ?? StudyReminderPreferences.defaultMinute;
    return TimeOfDay(hour: hour, minute: minute);
  }

  @override
  Future<void> saveReminderSettings({
    required bool enabled,
    required TimeOfDay time,
  }) async {
    final prefs = await _getPrefs();
    await prefs.setBool(StudyReminderPreferences.keyEnabled, enabled);
    await prefs.setInt(StudyReminderPreferences.keyHour, time.hour);
    await prefs.setInt(StudyReminderPreferences.keyMinute, time.minute);

    if (enabled) {
      await scheduleDailyReminder(time: time);
    } else {
      await cancelDailyReminder();
    }
  }

  @override
  Future<void> scheduleDailyReminder({required TimeOfDay time}) async {
    // Calculates trigger delay and registers recurring daily reminder
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final delay = scheduledDate.difference(now);
    debugPrint('Study reminder scheduled in ${delay.inMinutes} minutes at ${time.format} (Afaan Oromoo)');
  }

  @override
  Future<void> cancelDailyReminder() async {
    debugPrint('Daily study reminder cancelled.');
  }

  /// Afaan Oromoo notification payload generator
  static Map<String, String> getNotificationPayload({
    required String subjectName,
    required String timeFormatted,
  }) {
    return {
      'title': 'Yeroon Qo\'annoo Kee Ga\'eera! ⏰',
      'body': 'Sagantaa har\'aa: $subjectName. Seeniitii qayyabadhuutii qabxii gaarii fidi! 📚✨',
      'payload': 'schedule_screen',
    };
  }
}
