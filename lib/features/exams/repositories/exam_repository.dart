import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../auth/providers/auth_notifier.dart';
import '../models/exam_attempt_model.dart';
import '../models/question_model.dart';
import '../models/sync_queue_item.dart';

/// Abstract contract for Exam Repository
abstract class IExamRepository {
  Future<List<QuestionModel>> getQuestionsForSubject(String subjectId, {bool forceRefresh = false});
  Future<void> saveExamAttempt(ExamAttemptModel attempt);
  Future<List<ExamAttemptModel>> getLocalExamHistory();
  Future<int> syncPendingResults();
  Stream<int> observePendingSyncCount();
}

/// Abstract contract for Local Storage (Isar / SQLite database)
abstract class ILocalExamStorage {
  Future<List<QuestionModel>> getQuestionsBySubject(String subjectId);
  Future<void> saveQuestions(List<QuestionModel> questions);
  Future<void> saveExamAttempt(ExamAttemptModel attempt);
  Future<List<ExamAttemptModel>> getAllExamAttempts();
  Future<void> queueSyncItem(SyncQueueItem item);
  Future<List<SyncQueueItem>> getPendingSyncItems();
  Future<void> markSyncItemComplete(String id);
  Stream<int> watchPendingCount();
}

/// In-Memory & Local Cache implementation conforming to Isar / Local Database structure
class LocalExamStorage implements ILocalExamStorage {
  final Map<String, List<QuestionModel>> _cachedQuestions = {};
  final List<ExamAttemptModel> _localAttempts = [];
  final List<SyncQueueItem> _syncQueue = [];
  final StreamController<int> _pendingCountController = StreamController<int>.broadcast();

  LocalExamStorage() {
    _seedDefaultQuestions();
  }

  void _notifyPending() {
    final count = _syncQueue.where((item) => item.status == SyncStatus.pending).length;
    _pendingCountController.add(count);
  }

  @override
  Future<List<QuestionModel>> getQuestionsBySubject(String subjectId) async {
    return _cachedQuestions[subjectId] ?? [];
  }

  @override
  Future<void> saveQuestions(List<QuestionModel> questions) async {
    for (final q in questions) {
      _cachedQuestions.putIfAbsent(q.subjectId, () => []);
      final list = _cachedQuestions[q.subjectId]!;
      list.removeWhere((item) => item.id == q.id);
      list.add(q);
    }
  }

  @override
  Future<void> saveExamAttempt(ExamAttemptModel attempt) async {
    _localAttempts.removeWhere((a) => a.id == attempt.id);
    _localAttempts.insert(0, attempt);
  }

  @override
  Future<List<ExamAttemptModel>> getAllExamAttempts() async {
    return List.unmodifiable(_localAttempts);
  }

  @override
  Future<void> queueSyncItem(SyncQueueItem item) async {
    _syncQueue.removeWhere((q) => q.id == item.id);
    _syncQueue.add(item);
    _notifyPending();
  }

  @override
  Future<List<SyncQueueItem>> getPendingSyncItems() async {
    return _syncQueue.where((item) => item.status == SyncStatus.pending).toList();
  }

  @override
  Future<void> markSyncItemComplete(String id) async {
    final index = _syncQueue.indexWhere((q) => q.id == id);
    if (index != -1) {
      _syncQueue[index] = _syncQueue[index].copyWith(status: SyncStatus.synced);
      _notifyPending();
    }
  }

  @override
  Stream<int> watchPendingCount() {
    return _pendingCountController.stream;
  }

  void _seedDefaultQuestions() {
    _cachedQuestions['afaan_oromoo'] = [
      const QuestionModel(
        id: "ao_001",
        subjectId: "afaan_oromoo",
        topicOm: "Caasluga - Dhamjecha",
        questionTextOm: "Dhamjechi hiika of danda'aa hin qabne fi dhamjecha biraatti maxxanuun tajaajilu maaldha?",
        options: ["Dhamjecha Walaba", "Dhamjecha Hirkataa", "Jirma Jechaa", "Dhamjecha Bu'uuraa"],
        correctOptionIndex: 1,
        explanationOm: "Dhamjechi hirkataan of danda'ee hin dhaabbatu; yeroo hunda dhamjecha walabatti maxxana.",
      ),
      const QuestionModel(
        id: "ao_002",
        subjectId: "afaan_oromoo",
        topicOm: "Mamaksa",
        questionTextOm: "Mamaksa: 'Kan abbaan gabaabse, ollaan hin ______.' Jechi dhumarratti galu kami?",
        options: ["dheeressu", "balleessu", "kabaju", "jaallatu"],
        correctOptionIndex: 0,
        explanationOm: "Kan abbaan gabaabse ollaan hin dheeressu.",
      ),
    ];

    _cachedQuestions['herrega'] = [
      const QuestionModel(
        id: "math_001",
        subjectId: "herrega",
        topicOm: "Lakkofsoota Inteejerii",
        questionTextOm: "Gatiin shallaggii (-15) + (-8) - (-12) hammam ta'a?",
        options: ["-11", "-35", "+11", "-23"],
        correctOptionIndex: 0,
        explanationOm: "(-15) + (-8) = -23. -23 - (-12) = -23 + 12 = -11.",
      ),
      const QuestionModel(
        id: "math_002",
        subjectId: "herrega",
        topicOm: "Aljebraa",
        questionTextOm: "Walqixxoo 3x - 7 = 14 keessatti gatiin 'x' meeqa?",
        options: ["5", "7", "9", "21"],
        correctOptionIndex: 1,
        explanationOm: "3x = 14 + 7 = 21 => x = 21/3 = 7.",
      ),
    ];
  }
}

/// Production implementation of IExamRepository managing local database & remote API sync
class ExamRepository implements IExamRepository {
  final ILocalExamStorage _localStorage;
  final http.Client _httpClient;
  final String _backendBaseUrl;
  final Ref _ref;

  ExamRepository({
    required ILocalExamStorage localStorage,
    http.Client? httpClient,
    String backendBaseUrl = 'https://api.lamifkutaa8.et',
    required Ref ref,
  })  : _localStorage = localStorage,
        _httpClient = httpClient ?? http.Client(),
        _backendBaseUrl = backendBaseUrl,
        _ref = ref;

  String? _getAuthToken() {
    final user = _ref.read(currentUserProvider);
    return user?.backendToken;
  }

  @override
  Future<List<QuestionModel>> getQuestionsForSubject(String subjectId, {bool forceRefresh = false}) async {
    // 1. Check local offline storage first (Offline-First)
    final localQuestions = await _localStorage.getQuestionsBySubject(subjectId);

    if (localQuestions.isNotEmpty && !forceRefresh) {
      return localQuestions;
    }

    // 2. Fetch fresh question bank from remote Express/Node.js API when connected
    try {
      final token = _getAuthToken();
      final headers = {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await _httpClient
          .get(
            Uri.parse('$_backendBaseUrl/api/v1/exams/questions?subjectId=$subjectId'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        final remoteQuestions = data.map((json) => QuestionModel.fromJson(json as Map<String, dynamic>)).toList();

        // Update local database
        await _localStorage.saveQuestions(remoteQuestions);
        return remoteQuestions;
      }
    } on SocketException {
      // Network down; return local offline cache
    } on TimeoutException {
      // Timeout; return local offline cache
    } catch (_) {
      // Fallback to local offline cache
    }

    return localQuestions;
  }

  @override
  Future<void> saveExamAttempt(ExamAttemptModel attempt) async {
    // 1. Immediately persist attempt locally (Offline-First invariant)
    await _localStorage.saveExamAttempt(attempt);

    // 2. Queue for remote synchronization
    final syncItem = SyncQueueItem(
      id: "sync_${attempt.id}",
      itemType: "EXAM_ATTEMPT",
      payload: attempt.toJson(),
      createdAt: DateTime.now(),
      status: SyncStatus.pending,
    );

    await _localStorage.queueSyncItem(syncItem);

    // 3. Attempt opportunistic background synchronization if connected
    unawaited(syncPendingResults());
  }

  @override
  Future<List<ExamAttemptModel>> getLocalExamHistory() async {
    return _localStorage.getAllExamAttempts();
  }

  @override
  Future<int> syncPendingResults() async {
    final pendingItems = await _localStorage.getPendingSyncItems();
    if (pendingItems.isEmpty) return 0;

    int syncedCount = 0;
    final token = _getAuthToken();
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    for (final item in pendingItems) {
      try {
        final response = await _httpClient
            .post(
              Uri.parse('$_backendBaseUrl/api/v1/exams/sync-results'),
              headers: headers,
              body: jsonEncode(item.payload),
            )
            .timeout(const Duration(seconds: 12));

        if (response.statusCode == 200 || response.statusCode == 201) {
          await _localStorage.markSyncItemComplete(item.id);
          syncedCount++;
        }
      } on SocketException {
        // Disconnected; retry on next connection
        break;
      } on TimeoutException {
        break;
      } catch (_) {
        break;
      }
    }

    return syncedCount;
  }

  @override
  Stream<int> observePendingSyncCount() {
    return _localStorage.watchPendingCount();
  }
}

// ================= Riverpod Providers =================

/// Provider for local storage database instance
final localExamStorageProvider = Provider<ILocalExamStorage>((ref) {
  return LocalExamStorage();
});

/// Provider for ExamRepository
final examRepositoryProvider = Provider<IExamRepository>((ref) {
  final localStorage = ref.watch(localExamStorageProvider);
  return ExamRepository(
    localStorage: localStorage,
    ref: ref,
  );
});

/// FutureProvider to fetch questions by subject (Offline-first with auto-cache)
final questionsBySubjectProvider = FutureProvider.family<List<QuestionModel>, String>((ref, subjectId) async {
  final repository = ref.watch(examRepositoryProvider);
  return repository.getQuestionsForSubject(subjectId);
});

/// StreamProvider to observe pending offline sync queue count in real-time
final pendingSyncCountProvider = StreamProvider<int>((ref) {
  final repository = ref.watch(examRepositoryProvider);
  return repository.observePendingSyncCount();
});

/// FutureProvider to retrieve local historical exam attempts
final examHistoryProvider = FutureProvider<List<ExamAttemptModel>>((ref) async {
  final repository = ref.watch(examRepositoryProvider);
  return repository.getLocalExamHistory();
});
