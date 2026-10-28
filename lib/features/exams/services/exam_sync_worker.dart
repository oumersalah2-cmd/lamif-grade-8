import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:isar/isar.dart';
import 'package:workmanager/workmanager.dart';

import '../models/exam_result_schema.dart';
import '../models/user_progress_schema.dart';
import 'exam_isar_service.dart';

/// Unique task identifiers for WorkManager background service
const String kExamBackgroundSyncTask = 'com.lamif.kutaa8prep.exams.background_sync';
const String kExamPeriodicSyncTask = 'com.lamif.kutaa8prep.exams.periodic_sync';
const String kExamOneOffSyncTask = 'com.lamif.kutaa8prep.exams.one_off_sync';

/// Sync Status enumeration for UI and telemetry
enum BackgroundSyncStatus {
  idle,
  checkingNetwork,
  syncing,
  success,
  failedNoNetwork,
  failedServerError,
}

/// Result of a background sync execution run
class SyncExecutionResult {
  final bool isSuccess;
  final int syncedRecordsCount;
  final int remainingUnsyncedCount;
  final String messageOm;
  final DateTime timestamp;

  const SyncExecutionResult({
    required this.isSuccess,
    required this.syncedRecordsCount,
    required this.remainingUnsyncedCount,
    required this.messageOm,
    required this.timestamp,
  });

  @override
  String toString() =>
      'SyncExecutionResult(success: $isSuccess, synced: $syncedRecordsCount, pending: $remainingUnsyncedCount, msg: $messageOm)';
}

/// Remote Backend API Client for pushing exam results and user progress to PostgreSQL via Express
class ExamSyncApiClient {
  final http.Client _client;
  final String _baseUrl;

  ExamSyncApiClient({
    http.Client? client,
    String? baseUrl,
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? resolveDefaultBaseUrl();

  static String resolveDefaultBaseUrl() {
    if (kIsWeb) return 'http://localhost:5000';
    if (!kIsWeb && Platform.isAndroid) return 'http://10.0.2.2:5000';
    return 'http://localhost:5000';
  }

  /// Sends both unsynced ExamResults and UserProgress records to remote backend
  Future<Map<String, List<Id>>> syncOfflineBatch({
    required List<ExamResult> examResults,
    required List<UserProgress> userProgress,
    String? authToken,
  }) async {
    if (examResults.isEmpty && userProgress.isEmpty) {
      return {'exams': [], 'progress': []};
    }

    final payload = jsonEncode({
      'batchTimestamp': DateTime.now().toIso8601String(),
      'examResults': examResults.map((r) => r.toJson()).toList(),
      'userProgress': userProgress.map((p) => p.toJson()).toList(),
    });

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (authToken != null && authToken.isNotEmpty)
        'Authorization': 'Bearer $authToken',
    };

    try {
      final response = await _client
          .post(
            Uri.parse('$_baseUrl/api/v1/exams/sync'),
            headers: headers,
            body: payload,
          )
          .timeout(const Duration(seconds: 25));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final syncedExamIds = (decoded['syncedExamIds'] as List? ?? decoded['syncedIds'] as List? ?? [])
            .map((id) => (id as num).toInt())
            .toList();
        final syncedProgressIds = (decoded['syncedProgressIds'] as List? ?? [])
            .map((id) => (id as num).toInt())
            .toList();

        return {
          'exams': syncedExamIds.isNotEmpty ? syncedExamIds : examResults.map((r) => r.id).toList(),
          'progress': syncedProgressIds.isNotEmpty ? syncedProgressIds : userProgress.map((p) => p.id).toList(),
        };
      } else {
        throw HttpException(
          'Server rejected sync payload with HTTP ${response.statusCode}: ${response.body}',
        );
      }
    } on SocketException catch (e) {
      debugPrint('[ExamSyncApiClient] Network unreachable: ${e.message}');
      rethrow;
    } on TimeoutException catch (e) {
      debugPrint('[ExamSyncApiClient] Network timeout: ${e.message}');
      rethrow;
    }
  }

  /// Backward-compatible method: Sends batch of unsynced ExamResults
  Future<List<Id>> uploadExamResults({
    required List<ExamResult> results,
    String? authToken,
  }) async {
    final batchRes = await syncOfflineBatch(
      examResults: results,
      userProgress: [],
      authToken: authToken,
    );
    return batchRes['exams'] ?? [];
  }
}

/// Top-level callback dispatcher for WorkManager execution in background isolate.
/// WorkManager spawns an isolated background Dart environment without Flutter UI bindings.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    debugPrint('[WorkManager] Background task triggered: $taskName');

    try {
      // 1. Initialize Isar in background isolate
      final isar = Isar.getInstance();
      final isarService = ExamIsarService(isar);
      final apiClient = ExamSyncApiClient();

      // 2. Perform the synchronization
      final result = await executeExamSyncEngine(
        isarService: isarService,
        apiClient: apiClient,
        authToken: inputData?['authToken'] as String?,
      );

      debugPrint('[WorkManager] Sync execution finished: ${result.toString()}');
      return result.isSuccess;
    } catch (err, stack) {
      debugPrint('[WorkManager] Fatal error during sync task: $err\n$stack');
      // Returning false causes WorkManager to retry later according to backoff policy
      return false;
    }
  });
}

/// Standalone core sync function executed both in background tasks and foreground triggers
Future<SyncExecutionResult> executeExamSyncEngine({
  required IExamIsarService isarService,
  required ExamSyncApiClient apiClient,
  String? authToken,
}) async {
  final now = DateTime.now();

  try {
    // Step 1: Query local Isar collections for records with isSynced = false
    final unsyncedResults = await isarService.getUnsyncedExamResults();
    final unsyncedProgress = await isarService.getUnsyncedUserProgress();
    final totalPending = unsyncedResults.length + unsyncedProgress.length;

    debugPrint(
      '[ExamSyncWorker] Found ${unsyncedResults.length} unsynced ExamResults and ${unsyncedProgress.length} unsynced UserProgress in Isar',
    );

    if (totalPending == 0) {
      return SyncExecutionResult(
        isSuccess: true,
        syncedRecordsCount: 0,
        remainingUnsyncedCount: 0,
        messageOm: 'Qabxiin haaraan qindaa\'u hin jiru. Isar qophiidha.',
        timestamp: now,
      );
    }

    // Step 2: Push pending records to remote Express/PostgreSQL backend
    Map<String, List<Id>> syncAck;
    try {
      syncAck = await apiClient.syncOfflineBatch(
        examResults: unsyncedResults,
        userProgress: unsyncedProgress,
        authToken: authToken,
      );
    } catch (networkError) {
      debugPrint(
        '[ExamSyncWorker] Network request encountered error: $networkError.',
      );
      return SyncExecutionResult(
        isSuccess: false,
        syncedRecordsCount: 0,
        remainingUnsyncedCount: totalPending,
        messageOm: 'Dogoggora netwoorkii: Qabxiin duumessatti hin ergamne. Yeroo intarneetiin deebi\'u ofumaan yaalama.',
        timestamp: now,
      );
    }

    // Step 3: Mark acknowledged records as isSynced = true in Isar
    int successfullyMarked = 0;
    final syncedExamIds = syncAck['exams'] ?? [];
    for (final id in syncedExamIds) {
      await isarService.markExamResultSynced(id);
      successfullyMarked++;
    }

    final syncedProgressIds = syncAck['progress'] ?? [];
    for (final id in syncedProgressIds) {
      await isarService.markUserProgressSynced(id);
      successfullyMarked++;
    }

    final remaining = totalPending - successfullyMarked;

    return SyncExecutionResult(
      isSuccess: true,
      syncedRecordsCount: successfullyMarked,
      remainingUnsyncedCount: remaining,
      messageOm: 'Galmeen $successfullyMarked (qormaata fi sochii) milkaa\'inaan duumessatti qindaa\'eera!',
      timestamp: now,
    );
  } catch (e, stack) {
    debugPrint('[ExamSyncWorker] Unexpected sync error: $e\n$stack');
    return SyncExecutionResult(
      isSuccess: false,
      syncedRecordsCount: 0,
      remainingUnsyncedCount: 0,
      messageOm: 'Rakkoo qindeessuu: ${e.toString()}',
      timestamp: now,
    );
  }
}

/// Production-ready WorkManager service manager for Grade 8 Exam Sync
class ExamWorkManagerService {
  final IExamIsarService _isarService;
  final ExamSyncApiClient _apiClient;
  bool _isInitialized = false;

  final StreamController<BackgroundSyncStatus> _statusController =
      StreamController<BackgroundSyncStatus>.broadcast();
  final StreamController<SyncExecutionResult> _lastResultController =
      StreamController<SyncExecutionResult>.broadcast();

  SyncExecutionResult? _lastResult;
  BackgroundSyncStatus _currentStatus = BackgroundSyncStatus.idle;

  ExamWorkManagerService({
    required IExamIsarService isarService,
    ExamSyncApiClient? apiClient,
  })  : _isarService = isarService,
        _apiClient = apiClient ?? ExamSyncApiClient();

  Stream<BackgroundSyncStatus> get statusStream => _statusController.stream;
  Stream<SyncExecutionResult> get resultStream => _lastResultController.stream;
  BackgroundSyncStatus get currentStatus => _currentStatus;
  SyncExecutionResult? get lastResult => _lastResult;

  /// Initializes WorkManager and registers both periodic background sync
  /// with network connectivity constraint and opportunistic triggers.
  Future<void> initializeWorkManager({bool isInDebugMode = false}) async {
    if (_isInitialized) return;

    try {
      await Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode: isInDebugMode,
      );
      _isInitialized = true;
      debugPrint('[ExamWorkManagerService] WorkManager initialized successfully.');

      // Register periodic background sync with strict network constraints
      await registerPeriodicSyncTask();
    } catch (e) {
      debugPrint('[ExamWorkManagerService] Error initializing WorkManager: $e');
    }
  }

  /// Registers a periodic sync task that runs every 15 minutes (Android WorkManager minimum)
  /// ONLY when network is available (NetworkType.connected).
  Future<void> registerPeriodicSyncTask({
    Duration frequency = const Duration(minutes: 15),
  }) async {
    try {
      await Workmanager().registerPeriodicTask(
        kExamPeriodicSyncTask,
        kExamBackgroundSyncTask,
        frequency: frequency,
        constraints: Constraints(
          networkType: NetworkType.connected, // Monitors for network availability
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: false,
        ),
        existingWorkPolicy: ExistingWorkPolicy.keep,
        backoffPolicy: BackoffPolicy.exponential,
        backoffPolicyDelay: const Duration(seconds: 30),
      );
      debugPrint(
        '[ExamWorkManagerService] Registered periodic sync task with NetworkType.connected constraint.',
      );
    } catch (e) {
      debugPrint('[ExamWorkManagerService] Failed to register periodic sync task: $e');
    }
  }

  /// Triggers an immediate One-Off sync task via WorkManager when:
  /// - A student completes an exam
  /// - The app comes back online
  /// - The user taps manual sync in the UI
  Future<void> triggerImmediateOneOffSync({String? authToken}) async {
    try {
      await Workmanager().registerOneOffTask(
        '${kExamOneOffSyncTask}_${DateTime.now().millisecondsSinceEpoch}',
        kExamBackgroundSyncTask,
        constraints: Constraints(
          networkType: NetworkType.connected, // Strictly requires active network
        ),
        existingWorkPolicy: ExistingWorkPolicy.replace,
        initialDelay: Duration.zero,
        inputData: {
          if (authToken != null) 'authToken': authToken,
          'trigger': 'IMMEDIATE_USER_OR_EXAM_END',
        },
      );
      debugPrint('[ExamWorkManagerService] Enqueued immediate OneOff sync task.');
    } catch (e) {
      debugPrint('[ExamWorkManagerService] Failed to trigger OneOff sync: $e');
    }
  }

  /// Runs an in-process foreground sync immediately, updating state streams for the UI
  Future<SyncExecutionResult> performForegroundSync({String? authToken}) async {
    _updateStatus(BackgroundSyncStatus.syncing);

    final result = await executeExamSyncEngine(
      isarService: _isarService,
      apiClient: _apiClient,
      authToken: authToken,
    );

    _lastResult = result;
    _lastResultController.add(result);

    if (result.isSuccess) {
      _updateStatus(BackgroundSyncStatus.success);
    } else {
      _updateStatus(BackgroundSyncStatus.failedNoNetwork);
    }

    // Return to idle after delay
    Future.delayed(const Duration(seconds: 4), () {
      _updateStatus(BackgroundSyncStatus.idle);
    });

    return result;
  }

  /// Cancels all scheduled WorkManager sync tasks
  Future<void> cancelAllTasks() async {
    try {
      await Workmanager().cancelAll();
      debugPrint('[ExamWorkManagerService] All WorkManager sync tasks cancelled.');
    } catch (e) {
      debugPrint('[ExamWorkManagerService] Failed to cancel tasks: $e');
    }
  }

  // --- Jittered Batch Sync with Exponential Backoff ---
  Timer? _jitterTimer;
  int _consecutiveFailures = 0;
  final math.Random _random = math.Random();
  bool _isJitterLoopActive = false;

  /// Starts the in-app jittered batch sync loop (60s + random 0-30s)
  /// with exponential backoff on network failures.
  void startJitteredSyncLoop({String? authToken}) {
    if (_isJitterLoopActive) return;
    _isJitterLoopActive = true;
    _consecutiveFailures = 0;
    _scheduleNextJitteredSync(authToken: authToken);
    debugPrint('[ExamWorkManagerService] Jittered batch sync loop started.');
  }

  void _scheduleNextJitteredSync({String? authToken}) {
    _jitterTimer?.cancel();
    if (!_isJitterLoopActive) return;

    // Base interval: 60s + random 0-30s
    int baseSeconds = 60 + _random.nextInt(31);

    // Exponential backoff if consecutive failures occurred (caps at 300s = 5m)
    if (_consecutiveFailures > 0) {
      final backoffMultiplier = 1 << math.min(_consecutiveFailures, 4); // Max 16x
      baseSeconds = math.min(300, baseSeconds * backoffMultiplier);
    }

    debugPrint(
      '[ExamWorkManagerService] Next jittered sync in $baseSeconds seconds (consecutive failures: $_consecutiveFailures).',
    );

    _jitterTimer = Timer(Duration(seconds: baseSeconds), () async {
      await _runJitteredBatchSync(authToken: authToken);
    });
  }

  Future<void> _runJitteredBatchSync({String? authToken}) async {
    if (!_isJitterLoopActive) return;

    // Check if there are actually pending items before attempting network call
    final unsyncedExams = await _isarService.getUnsyncedExamResults();
    final unsyncedProg = await _isarService.getUnsyncedUserProgress();

    if (unsyncedExams.isEmpty && unsyncedProg.isEmpty) {
      _consecutiveFailures = 0;
      _scheduleNextJitteredSync(authToken: authToken);
      return;
    }

    debugPrint(
      '[ExamWorkManagerService] Executing jittered sync for ${unsyncedExams.length} exams & ${unsyncedProg.length} progress...',
    );

    final result = await performForegroundSync(authToken: authToken);
    if (result.isSuccess) {
      _consecutiveFailures = 0;
    } else {
      _consecutiveFailures++;
    }

    _scheduleNextJitteredSync(authToken: authToken);
  }

  /// Stops active in-app jittered sync loop
  void stopJitteredSyncLoop() {
    _isJitterLoopActive = false;
    _jitterTimer?.cancel();
    _jitterTimer = null;
    debugPrint('[ExamWorkManagerService] Jittered batch sync loop stopped.');
  }

  void _updateStatus(BackgroundSyncStatus status) {
    _currentStatus = status;
    _statusController.add(status);
  }

  void dispose() {
    stopJitteredSyncLoop();
    _statusController.close();
    _lastResultController.close();
  }
}

// ================= Riverpod Providers =================

/// Provider for ExamSyncApiClient
final examSyncApiClientProvider = Provider<ExamSyncApiClient>((ref) {
  return ExamSyncApiClient();
});

/// Global singleton provider for ExamWorkManagerService
final examWorkManagerServiceProvider = Provider<ExamWorkManagerService>((ref) {
  final isarService = ref.watch(examIsarServiceProvider);
  final apiClient = ref.watch(examSyncApiClientProvider);
  final service = ExamWorkManagerService(
    isarService: isarService,
    apiClient: apiClient,
  );

  ref.onDispose(() {
    service.dispose();
  });

  return service;
});

/// Stream provider for watching background sync status
final backgroundSyncStatusProvider = StreamProvider<BackgroundSyncStatus>((ref) {
  final manager = ref.watch(examWorkManagerServiceProvider);
  return manager.statusStream;
});

/// Stream provider for watching last sync result
final lastSyncResultProvider = StreamProvider<SyncExecutionResult>((ref) {
  final manager = ref.watch(examWorkManagerServiceProvider);
  return manager.resultStream;
});

/// Future provider to count how many ExamResult records currently have isSynced = false
final unsyncedExamResultsCountProvider = FutureProvider<int>((ref) async {
  final isarService = ref.watch(examIsarServiceProvider);
  final unsynced = await isarService.getUnsyncedExamResults();
  return unsynced.length;
});

/// Future provider to count how many UserProgress records currently have isSynced = false
final unsyncedUserProgressCountProvider = FutureProvider<int>((ref) async {
  final isarService = ref.watch(examIsarServiceProvider);
  final unsynced = await isarService.getUnsyncedUserProgress();
  return unsynced.length;
});

/// Future provider to count total records waiting for background sync
final totalUnsyncedRecordsCountProvider = FutureProvider<int>((ref) async {
  final exams = await ref.watch(unsyncedExamResultsCountProvider.future);
  final progress = await ref.watch(unsyncedUserProgressCountProvider.future);
  return exams + progress;
});
