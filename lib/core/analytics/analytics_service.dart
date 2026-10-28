import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Privacy-compliant, non-personal analytics and crash reporting service.
///
/// Strictly observes Google Play Data Safety policies:
/// - Never collects names, phone numbers, school locations, receipt images, or answers.
/// - Only logs anonymized app lifecycle & telemetry events.
/// - Requires explicit user consent before activating transmission.
/// - Fully offline-tolerant: never throws, never blocks the main thread.
class AnalyticsService {
  static const String _kConsentKey = 'lamif_telemetry_consent_v1';

  final SharedPreferences? _prefs;
  bool _isFirebaseAvailable = false;
  bool _hasConsent = false;

  AnalyticsService([this._prefs]);

  bool get hasConsent => _hasConsent;

  Future<void> initialize() async {
    try {
      // 1. Check if Firebase Core is initialized
      if (Firebase.apps.isNotEmpty) {
        _isFirebaseAvailable = true;
      }
    } catch (_) {
      _isFirebaseAvailable = false;
    }

    try {
      // 2. Read consent from local preferences (Default: false until accepted)
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      _hasConsent = prefs.getBool(_kConsentKey) ?? false;

      await _applyCollectionState(_hasConsent);
    } catch (e) {
      debugPrint('[AnalyticsService] Initialization warning: $e');
    }
  }

  /// Sets telemetry and crash reporting consent (Bilingual toggle in Settings)
  Future<void> setConsent(bool enabled) async {
    _hasConsent = enabled;
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      await prefs.setBool(_kConsentKey, enabled);
      await _applyCollectionState(enabled);
    } catch (e) {
      debugPrint('[AnalyticsService] Error saving consent: $e');
    }
  }

  Future<void> _applyCollectionState(bool enabled) async {
    if (!_isFirebaseAvailable) return;
    try {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(enabled);
      await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(enabled);
      debugPrint('[AnalyticsService] Telemetry collection set to: $enabled');
    } catch (e) {
      debugPrint('[AnalyticsService] Warning setting collection state: $e');
    }
  }

  // ================= Non-Personal Anonymized Event Logging =================

  /// Log when student begins an exam session
  Future<void> logExamStarted({
    required String subjectId,
    required String mode, // 'mock', 'practice_by_topic', 'practice_weak_topics'
  }) async {
    if (!_hasConsent || !_isFirebaseAvailable) return;
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'exam_started',
        parameters: {
          'subject_id': subjectId,
          'mode': mode,
        },
      );
    } catch (_) {}
  }

  /// Log when student finishes an exam session
  Future<void> logExamFinished({
    required String subjectId,
    required int durationSeconds,
    required int scorePercentage,
  }) async {
    if (!_hasConsent || !_isFirebaseAvailable) return;
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'exam_finished',
        parameters: {
          'subject_id': subjectId,
          'duration_seconds': durationSeconds,
          'score_percentage': scorePercentage,
        },
      );
    } catch (_) {}
  }

  /// Log when offline sync succeeds
  Future<void> logSyncSuccess({required int recordCount}) async {
    if (!_hasConsent || !_isFirebaseAvailable) return;
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'sync_success',
        parameters: {
          'record_count': recordCount,
        },
      );
    } catch (_) {}
  }

  /// Log when offline sync fails (network or server error)
  Future<void> logSyncFailed({required String reason}) async {
    if (!_hasConsent || !_isFirebaseAvailable) return;
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'sync_failed',
        parameters: {
          'reason': reason.length > 50 ? reason.substring(0, 50) : reason,
        },
      );
    } catch (_) {}
  }

  /// Log when student uses Grade Calculator & Target Planner
  Future<void> logGradeCalculatorUsed({
    required int subjectsCount,
    required bool targetSet,
  }) async {
    if (!_hasConsent || !_isFirebaseAvailable) return;
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'grade_calculator_used',
        parameters: {
          'subjects_count': subjectsCount,
          'target_set': targetSet ? 1 : 0,
        },
      );
    } catch (_) {}
  }

  /// Log when weak topics view is opened
  Future<void> logWeakTopicsOpened({required int weakCount}) async {
    if (!_hasConsent || !_isFirebaseAvailable) return;
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'weak_topics_opened',
        parameters: {
          'weak_count': weakCount,
        },
      );
    } catch (_) {}
  }

  /// Log when payment screen is opened
  Future<void> logPaymentScreenOpened({required String track}) async {
    if (!_hasConsent || !_isFirebaseAvailable) return;
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'payment_screen_opened',
        parameters: {
          'track': track,
        },
      );
    } catch (_) {}
  }

  /// Captures unhandled or caught application errors
  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    bool fatal = false,
  }) async {
    if (!_hasConsent || !_isFirebaseAvailable) return;
    try {
      await FirebaseCrashlytics.instance.recordError(
        exception,
        stack,
        fatal: fatal,
      );
    } catch (_) {}
  }
}

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});
