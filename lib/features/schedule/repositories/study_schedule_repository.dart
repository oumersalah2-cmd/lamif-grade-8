import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/study_session_model.dart';

/// Contract for Study Schedule Repository
abstract class IStudyScheduleRepository {
  Future<List<StudySessionModel>> getSessionsByDay(DayOfWeekOm day);
  Future<List<StudySessionModel>> getAllSessions();
  Future<void> addSession(StudySessionModel session);
  Future<void> updateSession(StudySessionModel session);
  Future<void> toggleSessionCompleted(String sessionId, bool isCompleted);
  Future<void> deleteSession(String sessionId);
  Future<double> getDailyProgress(DayOfWeekOm day);
}

/// Abstract contract for local Isar-compatible schedule storage
abstract class ILocalScheduleStorage {
  Future<List<StudySessionModel>> getSessions(DayOfWeekOm day);
  Future<List<StudySessionModel>> getAllSessions();
  Future<void> saveSession(StudySessionModel session);
  Future<void> toggleCompleted(String sessionId, bool completed);
  Future<void> deleteSession(String sessionId);
}

/// In-memory and local database implementation of ILocalScheduleStorage
class LocalScheduleStorage implements ILocalScheduleStorage {
  final List<StudySessionModel> _sessions = [];

  LocalScheduleStorage() {
    _seedDefaultSchedule();
  }

  void _seedDefaultSchedule() {
    _sessions.addAll([
      // Wiixata (Monday)
      const StudySessionModel(
        id: 'sch_mon_1',
        subjectId: 'herrega',
        subjectNameOm: 'Herrega (Mathematics)',
        dayOfWeek: DayOfWeekOm.wiixata,
        startTime: '08:30',
        durationMinutes: 60,
        topicFocusOm: 'Algebiraa: Herrega Lakkoofsota Raashinaalii',
        isCompleted: true,
      ),
      const StudySessionModel(
        id: 'sch_mon_2',
        subjectId: 'afaan_oromoo',
        subjectNameOm: 'Afaan Oromoo',
        dayOfWeek: DayOfWeekOm.wiixata,
        startTime: '16:00',
        durationMinutes: 45,
        topicFocusOm: 'Caasluga: Seera Barreessaa fi Qubeeffama',
        isCompleted: false,
      ),

      // Kibxata (Tuesday)
      const StudySessionModel(
        id: 'sch_tue_1',
        subjectId: 'saayinsii_waliigalaa',
        subjectNameOm: 'Saayinsii Waliigalaa',
        dayOfWeek: DayOfWeekOm.kibxata,
        startTime: '08:30',
        durationMinutes: 50,
        topicFocusOm: 'Lubbu-qabeeyyii: Caasaa fi Dalagaa Seelii',
        isCompleted: false,
      ),
      const StudySessionModel(
        id: 'sch_tue_2',
        subjectId: 'english',
        subjectNameOm: 'English Language',
        dayOfWeek: DayOfWeekOm.kibxata,
        startTime: '17:00',
        durationMinutes: 45,
        topicFocusOm: 'Grammar: Direct & Indirect Speech Practice',
        isCompleted: false,
      ),

      // Roobii (Wednesday)
      const StudySessionModel(
        id: 'sch_wed_1',
        subjectId: 'barnoota_hawaasaa',
        subjectNameOm: 'Barnoota Hawaasaa',
        dayOfWeek: DayOfWeekOm.roobii,
        startTime: '09:00',
        durationMinutes: 45,
        topicFocusOm: 'Seenaa Oromoo fi Sirna Gadaa Kutaa 8ffaa',
        isCompleted: false,
      ),
      const StudySessionModel(
        id: 'sch_wed_2',
        subjectId: 'herrega',
        subjectNameOm: 'Herrega (Mathematics)',
        dayOfWeek: DayOfWeekOm.roobii,
        startTime: '16:30',
        durationMinutes: 60,
        topicFocusOm: 'Jiomeetirii: Riqoowwanii fi Rog-sadoota',
        isCompleted: false,
      ),

      // Kamisa (Thursday)
      const StudySessionModel(
        id: 'sch_thu_1',
        subjectId: 'civics',
        subjectNameOm: 'Barnoota Lammummaa',
        dayOfWeek: DayOfWeekOm.kamisa,
        startTime: '08:30',
        durationMinutes: 40,
        topicFocusOm: 'Heera Mootummaa fi Mirga Namoomaa',
        isCompleted: false,
      ),
      const StudySessionModel(
        id: 'sch_thu_2',
        subjectId: 'saayinsii_waliigalaa',
        subjectNameOm: 'Saayinsii Waliigalaa',
        dayOfWeek: DayOfWeekOm.kamisa,
        startTime: '16:00',
        durationMinutes: 50,
        topicFocusOm: 'Fiiziksii: Humni, Saffisa fi Dalagaa',
        isCompleted: false,
      ),

      // Jimaata (Friday)
      const StudySessionModel(
        id: 'sch_fri_1',
        subjectId: 'ict',
        subjectNameOm: 'Barnoota Qunnamtii Odeeffannoo (ICT)',
        dayOfWeek: DayOfWeekOm.jimaata,
        startTime: '09:00',
        durationMinutes: 45,
        topicFocusOm: 'Kompiitara fi Seera Nageenya Intarneetii',
        isCompleted: false,
      ),
      const StudySessionModel(
        id: 'sch_fri_2',
        subjectId: 'english',
        subjectNameOm: 'English Language',
        dayOfWeek: DayOfWeekOm.jimaata,
        startTime: '16:30',
        durationMinutes: 45,
        topicFocusOm: 'Reading Comprehension: Passage Analysis',
        isCompleted: false,
      ),

      // Sanbata (Saturday - Mock Exam Day)
      const StudySessionModel(
        id: 'sch_sat_1',
        subjectId: 'afaan_oromoo',
        subjectNameOm: 'Qormaata Naannoo Waliigalaa (Mock)',
        dayOfWeek: DayOfWeekOm.sanbata,
        startTime: '08:00',
        durationMinutes: 90,
        topicFocusOm: 'Qormaata Shaakalaa Ministry 2015/2016',
        isCompleted: false,
      ),
    ]);
  }

  @override
  Future<List<StudySessionModel>> getSessions(DayOfWeekOm day) async {
    return _sessions.where((s) => s.dayOfWeek == day).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  @override
  Future<List<StudySessionModel>> getAllSessions() async {
    return List.unmodifiable(_sessions);
  }

  @override
  Future<void> saveSession(StudySessionModel session) async {
    final idx = _sessions.indexWhere((s) => s.id == session.id);
    if (idx >= 0) {
      _sessions[idx] = session;
    } else {
      _sessions.add(session);
    }
  }

  @override
  Future<void> toggleCompleted(String sessionId, bool completed) async {
    final idx = _sessions.indexWhere((s) => s.id == sessionId);
    if (idx >= 0) {
      _sessions[idx] = _sessions[idx].copyWith(isCompleted: completed);
    }
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    _sessions.removeWhere((s) => s.id == sessionId);
  }
}

/// Production implementation of StudyScheduleRepository
class StudyScheduleRepository implements IStudyScheduleRepository {
  final ILocalScheduleStorage _localStorage;

  StudyScheduleRepository(this._localStorage);

  @override
  Future<List<StudySessionModel>> getSessionsByDay(DayOfWeekOm day) async {
    return _localStorage.getSessions(day);
  }

  @override
  Future<List<StudySessionModel>> getAllSessions() async {
    return _localStorage.getAllSessions();
  }

  @override
  Future<void> addSession(StudySessionModel session) async {
    await _localStorage.saveSession(session);
  }

  @override
  Future<void> updateSession(StudySessionModel session) async {
    await _localStorage.saveSession(session);
  }

  @override
  Future<void> toggleSessionCompleted(String sessionId, bool isCompleted) async {
    await _localStorage.toggleCompleted(sessionId, isCompleted);
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    await _localStorage.deleteSession(sessionId);
  }

  @override
  Future<double> getDailyProgress(DayOfWeekOm day) async {
    final sessions = await _localStorage.getSessions(day);
    if (sessions.isEmpty) return 0.0;
    final completedCount = sessions.where((s) => s.isCompleted).length;
    return completedCount / sessions.length;
  }
}

/// Storage provider
final localScheduleStorageProvider = Provider<ILocalScheduleStorage>((ref) {
  return LocalScheduleStorage();
});

/// Repository provider
final studyScheduleRepositoryProvider = Provider<IStudyScheduleRepository>((ref) {
  final storage = ref.watch(localScheduleStorageProvider);
  return StudyScheduleRepository(storage);
});
