import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/study_session_model.dart';
import '../repositories/study_schedule_repository.dart';

/// State representation for student daily study planner
class ScheduleState {
  final DayOfWeekOm selectedDay;
  final List<StudySessionModel> sessions;
  final bool isLoading;
  final String? errorMessage;

  const ScheduleState({
    this.selectedDay = DayOfWeekOm.wiixata,
    this.sessions = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  double get completionProgress {
    if (sessions.isEmpty) return 0.0;
    final completed = sessions.where((s) => s.isCompleted).length;
    return completed / sessions.length;
  }

  int get totalMinutes {
    return sessions.fold(0, (sum, item) => sum + item.durationMinutes);
  }

  ScheduleState copyWith({
    DayOfWeekOm? selectedDay,
    List<StudySessionModel>? sessions,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ScheduleState(
      selectedDay: selectedDay ?? this.selectedDay,
      sessions: sessions ?? this.sessions,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// StateNotifier for study sessions
class ScheduleNotifier extends StateNotifier<ScheduleState> {
  final IStudyScheduleRepository _repository;

  ScheduleNotifier(this._repository) : super(const ScheduleState()) {
    loadSessionsForDay(state.selectedDay);
  }

  Future<void> selectDay(DayOfWeekOm day) async {
    state = state.copyWith(selectedDay: day, isLoading: true);
    await loadSessionsForDay(day);
  }

  Future<void> loadSessionsForDay(DayOfWeekOm day) async {
    try {
      final sessions = await _repository.getSessionsByDay(day);
      state = state.copyWith(
        selectedDay: day,
        sessions: sessions,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Sagantaa fiduun hin danda'amne: $e',
      );
    }
  }

  Future<void> toggleCompleted(String sessionId, bool isCompleted) async {
    // Optimistic UI update
    final updated = state.sessions.map((s) {
      if (s.id == sessionId) {
        return s.copyWith(isCompleted: isCompleted);
      }
      return s;
    }).toList();

    state = state.copyWith(sessions: updated);

    await _repository.toggleSessionCompleted(sessionId, isCompleted);
  }

  Future<void> addSession({
    required String subjectId,
    required String subjectNameOm,
    required DayOfWeekOm dayOfWeek,
    required String startTime,
    required int durationMinutes,
    required String topicFocusOm,
    String? notes,
  }) async {
    final newSession = StudySessionModel(
      id: 'session_${DateTime.now().millisecondsSinceEpoch}',
      subjectId: subjectId,
      subjectNameOm: subjectNameOm,
      dayOfWeek: dayOfWeek,
      startTime: startTime,
      durationMinutes: durationMinutes,
      topicFocusOm: topicFocusOm,
      notes: notes,
      isCompleted: false,
    );

    await _repository.addSession(newSession);

    if (state.selectedDay == dayOfWeek) {
      final updated = List<StudySessionModel>.from(state.sessions)..add(newSession);
      updated.sort((a, b) => a.startTime.compareTo(b.startTime));
      state = state.copyWith(sessions: updated);
    }
  }

  Future<void> deleteSession(String sessionId) async {
    final updated = state.sessions.where((s) => s.id != sessionId).toList();
    state = state.copyWith(sessions: updated);
    await _repository.deleteSession(sessionId);
  }
}

/// Provider for ScheduleNotifier
final scheduleNotifierProvider =
    StateNotifierProvider<ScheduleNotifier, ScheduleState>((ref) {
  final repo = ref.watch(studyScheduleRepositoryProvider);
  return ScheduleNotifier(repo);
});
