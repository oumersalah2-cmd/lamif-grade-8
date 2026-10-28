import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Offline-first study streak and bookmarking model
class StudyStreakData {
  final int currentStreakDays;
  final int longestStreakDays;
  final DateTime? lastStudiedDate;
  final int totalQuestionsAnswered;

  const StudyStreakData({
    this.currentStreakDays = 0,
    this.longestStreakDays = 0,
    this.lastStudiedDate,
    this.totalQuestionsAnswered = 0,
  });

  bool get isStudiedToday {
    if (lastStudiedDate == null) return false;
    final now = DateTime.now();
    return lastStudiedDate!.year == now.year &&
        lastStudiedDate!.month == now.month &&
        lastStudiedDate!.day == now.day;
  }

  String get streakMessageOm {
    if (currentStreakDays == 0) {
      return 'Har\'a qayyabachuun itti-fufiinsa guyyaa keetii jalqabi!';
    }
    return 'Guyyoota $currentStreakDays walitti fuftee qayyabatteetta! Cimi!';
  }

  String get streakMessageEn {
    if (currentStreakDays == 0) {
      return 'Start your daily study streak by practicing today!';
    }
    return '$currentStreakDays-day study streak! Keep going!';
  }
}

/// Service managing study streaks and question bookmarks offline
class StudyOfflineService {
  static const String _kStreakKey = 'lamif_study_streak_v1';
  static const String _kBookmarksKey = 'lamif_bookmarked_questions_v1';

  final SharedPreferences? _prefsInstance;

  StudyOfflineService([this._prefsInstance]);

  Future<SharedPreferences> _getPrefs() async {
    return _prefsInstance ?? await SharedPreferences.getInstance();
  }

  /// Load current study streak
  Future<StudyStreakData> getStreakData() async {
    try {
      final prefs = await _getPrefs();
      final raw = prefs.getString(_kStreakKey);
      if (raw != null) {
        final Map<String, dynamic> data = jsonDecode(raw);
        final lastDateStr = data['lastStudiedDate'] as String?;
        final lastDate = lastDateStr != null ? DateTime.tryParse(lastDateStr) : null;

        int current = data['currentStreakDays'] as int? ?? 0;
        int longest = data['longestStreakDays'] as int? ?? 0;
        int totalQ = data['totalQuestionsAnswered'] as int? ?? 0;

        // Check if streak was broken (missed yesterday)
        if (lastDate != null) {
          final now = DateTime.now();
          final differenceDays = DateTime(now.year, now.month, now.day)
              .difference(DateTime(lastDate.year, lastDate.month, lastDate.day))
              .inDays;

          if (differenceDays > 1) {
            // Streak broken
            current = 0;
          }
        }

        return StudyStreakData(
          currentStreakDays: current,
          longestStreakDays: longest,
          lastStudiedDate: lastDate,
          totalQuestionsAnswered: totalQ,
        );
      }
    } catch (e) {
      debugPrint('[StudyOfflineService] Error loading streak data: $e');
    }
    return const StudyStreakData();
  }

  /// Records daily study activity and updates streak
  Future<StudyStreakData> recordStudyActivity({int questionsCount = 1}) async {
    final current = await getStreakData();
    final now = DateTime.now();
    final prefs = await _getPrefs();

    int newStreak = current.currentStreakDays;

    if (current.lastStudiedDate == null) {
      newStreak = 1;
    } else {
      final diffDays = DateTime(now.year, now.month, now.day)
          .difference(DateTime(
            current.lastStudiedDate!.year,
            current.lastStudiedDate!.month,
            current.lastStudiedDate!.day,
          ))
          .inDays;

      if (diffDays == 1) {
        // Consecutive next day
        newStreak += 1;
      } else if (diffDays > 1) {
        // Missed a day
        newStreak = 1;
      }
      // If diffDays == 0, already studied today, streak stays the same
    }

    final newLongest = newStreak > current.longestStreakDays ? newStreak : current.longestStreakDays;
    final newTotalQ = current.totalQuestionsAnswered + questionsCount;

    final updated = StudyStreakData(
      currentStreakDays: newStreak,
      longestStreakDays: newLongest,
      lastStudiedDate: now,
      totalQuestionsAnswered: newTotalQ,
    );

    await prefs.setString(
      _kStreakKey,
      jsonEncode({
        'currentStreakDays': updated.currentStreakDays,
        'longestStreakDays': updated.longestStreakDays,
        'lastStudiedDate': updated.lastStudiedDate?.toIso8601String(),
        'totalQuestionsAnswered': updated.totalQuestionsAnswered,
      }),
    );

    return updated;
  }

  /// Get list of bookmarked question IDs
  Future<List<String>> getBookmarkedQuestionIds() async {
    try {
      final prefs = await _getPrefs();
      return prefs.getStringList(_kBookmarksKey) ?? [];
    } catch (_) {
      return [];
    }
  }

  /// Toggles bookmark on a question
  Future<bool> toggleBookmark(String questionId) async {
    final prefs = await _getPrefs();
    final list = prefs.getStringList(_kBookmarksKey) ?? [];
    final isBookmarked = list.contains(questionId);

    if (isBookmarked) {
      list.remove(questionId);
    } else {
      list.add(questionId);
    }

    await prefs.setStringList(_kBookmarksKey, list);
    return !isBookmarked;
  }

  /// Checks if a question is bookmarked
  Future<bool> isQuestionBookmarked(String questionId) async {
    final ids = await getBookmarkedQuestionIds();
    return ids.contains(questionId);
  }
}

final studyOfflineServiceProvider = Provider<StudyOfflineService>((ref) {
  return StudyOfflineService();
});

final studyStreakProvider = FutureProvider<StudyStreakData>((ref) async {
  final service = ref.watch(studyOfflineServiceProvider);
  return service.getStreakData();
});
