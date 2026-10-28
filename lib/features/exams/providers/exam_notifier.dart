import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/question_schema.dart';
import '../models/exam_result_schema.dart';
import '../services/exam_isar_service.dart';
import 'exam_state.dart';

/// StateNotifier managing active Grade 8 offline exam sessions
class ExamNotifier extends StateNotifier<ExamState> {
  final IExamIsarService _isarService;
  Timer? _countdownTimer;

  ExamNotifier({
    required IExamIsarService isarService,
    String defaultSubjectId = 'herrega',
    String defaultSubjectTitle = 'Herrega',
    int defaultDurationMinutes = 60,
  })  : _isarService = isarService,
        super(ExamState.initial(
          subjectId: defaultSubjectId,
          subjectTitleOm: defaultSubjectTitle,
          durationMinutes: defaultDurationMinutes,
        ));

  /// Initialize and start a mock exam for a given subject
  Future<void> startExam({
    required String subjectId,
    String? subjectTitleOm,
    int durationMinutes = 60,
  }) async {
    _stopTimer();

    state = state.copyWith(
      status: ExamStatus.loading,
      subjectId: subjectId,
      subjectTitleOm: subjectTitleOm ?? _resolveSubjectName(subjectId),
      totalDurationSeconds: durationMinutes * 60,
      remainingSeconds: durationMinutes * 60,
      currentQuestionIndex: 0,
      selectedAnswers: {},
      finalResult: null,
      errorMessage: null,
    );

    try {
      // 1. Load cached Questions from Isar
      final cachedQuestions =
          await _isarService.getQuestionsBySubject(subjectId);

      if (cachedQuestions.isEmpty) {
        state = state.copyWith(
          status: ExamStatus.error,
          errorMessage:
              'Gaaffileen gosa barnootaa kanaa hin argamne. Mee dura daawwadhaa.',
        );
        return;
      }

      // Load any existing draft answers saved on previous interruption
      final savedDrafts = await _isarService.loadAnswerDrafts(subjectId);

      state = state.copyWith(
        questions: cachedQuestions,
        selectedAnswers: savedDrafts,
        status: ExamStatus.inProgress,
      );

      // 2. Start the countdown timer
      _startTimer();
    } catch (e) {
      state = state.copyWith(
        status: ExamStatus.error,
        errorMessage: 'Dogoggora gaaffilee fe\'uu: ${e.toString()}',
      );
    }
  }

  /// Start countdown timer ticking every 1 second
  void _startTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds > 1) {
        state = state.copyWith(
          remainingSeconds: state.remainingSeconds - 1,
        );
      } else {
        // Time expired! Auto-submit the exam
        _stopTimer();
        state = state.copyWith(remainingSeconds: 0);
        endExam();
      }
    });
  }

  /// Stop and cancel active timer
  void _stopTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  /// Record user's option choice for a question
  void selectAnswer(int questionIndex, int optionIndex) {
    if (state.status != ExamStatus.inProgress) return;
    if (questionIndex < 0 || questionIndex >= state.questions.length) return;

    final updatedAnswers = Map<int, int>.from(state.selectedAnswers);
    updatedAnswers[questionIndex] = optionIndex;

    state = state.copyWith(selectedAnswers: updatedAnswers);

    // Save every answer to local offline storage immediately on tap
    _isarService.saveAnswerDraft(state.subjectId, questionIndex, optionIndex);
  }

  /// Select answer for the currently active question
  void selectCurrentOption(int optionIndex) {
    selectAnswer(state.currentQuestionIndex, optionIndex);
  }

  /// Navigate to next question, or finish if on last question
  void nextQuestion() {
    if (state.isLastQuestion) {
      endExam();
    } else {
      state = state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex + 1,
      );
    }
  }

  /// Navigate to previous question
  void previousQuestion() {
    if (state.currentQuestionIndex > 0) {
      state = state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex - 1,
      );
    }
  }

  /// Jump to a specific question by index
  void goToQuestion(int index) {
    if (index >= 0 && index < state.questions.length) {
      state = state.copyWith(currentQuestionIndex: index);
    }
  }

  /// End exam session:
  /// - Calculates final score
  /// - Persists ExamResult to Isar with isSynced = false
  /// - Halts the timer
  Future<ExamResult?> endExam() async {
    _stopTimer();

    if (state.questions.isEmpty) return null;

    // 1. Calculate final score
    int correctCount = 0;
    for (int i = 0; i < state.questions.length; i++) {
      final question = state.questions[i];
      final selectedOptionIndex = state.selectedAnswers[i];

      if (selectedOptionIndex != null &&
          selectedOptionIndex >= 0 &&
          selectedOptionIndex < question.options.length) {
        if (question.options[selectedOptionIndex].isCorrect) {
          correctCount++;
        }
      }
    }

    final timeTaken = (state.totalDurationSeconds - state.remainingSeconds)
        .clamp(0, state.totalDurationSeconds);

    // 2. Build ExamResult with critical isSynced = false
    final examResult = ExamResult(
      subjectId: state.subjectId,
      score: correctCount,
      totalQuestions: state.questions.length,
      timeTaken: timeTaken,
      dateTaken: DateTime.now(),
      isSynced: false, // Critical offline-first sync requirement
    );

    // 3. Persist to Isar database
    try {
      final savedId = await _isarService.saveExamResult(examResult);
      final finalPersistedResult = examResult.copyWith(id: savedId);

      // Clear completed draft answers from disk
      await _isarService.clearAnswerDrafts(state.subjectId);

      state = state.copyWith(
        status: ExamStatus.completed,
        finalResult: finalPersistedResult,
      );

      return finalPersistedResult;
    } catch (e) {
      // In case of local write failure, retain in-memory completed state
      state = state.copyWith(
        status: ExamStatus.completed,
        finalResult: examResult,
      );
      return examResult;
    }
  }

  /// Helper to resolve subject titles in Afaan Oromoo
  String _resolveSubjectName(String subjectId) {
    switch (subjectId.toLowerCase()) {
      case 'herrega':
        return 'Herrega (Mathematics)';
      case 'afaan_oromoo':
        return 'Afaan Oromoo';
      case 'saayinsii_waliigalaa':
        return 'Saayinsii Waliigalaa (General Science)';
      case 'hawaasummaa':
        return 'Barnoota Hawaasummaa (Social Studies)';
      default:
        return 'Qormaata Kutaa 8ffaa';
    }
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}

/// Parameters for initializing the ExamNotifier family
class ExamNotifierParams {
  final String subjectId;
  final String? subjectTitleOm;
  final int durationMinutes;

  const ExamNotifierParams({
    required this.subjectId,
    this.subjectTitleOm,
    this.durationMinutes = 60,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExamNotifierParams &&
          runtimeType == other.runtimeType &&
          subjectId == other.subjectId &&
          durationMinutes == other.durationMinutes;

  @override
  int get hashCode => subjectId.hashCode ^ durationMinutes.hashCode;
}

/// Riverpod family provider for managing the active exam session
final examNotifierProvider = StateNotifierProvider.autoDispose
    .family<ExamNotifier, ExamState, ExamNotifierParams>((ref, params) {
  final isarService = ref.watch(examIsarServiceProvider);
  final notifier = ExamNotifier(
    isarService: isarService,
    defaultSubjectId: params.subjectId,
    defaultSubjectTitle: params.subjectTitleOm ?? 'Qormaata',
    defaultDurationMinutes: params.durationMinutes,
  );

  // Automatically start the exam on initialization
  notifier.startExam(
    subjectId: params.subjectId,
    subjectTitleOm: params.subjectTitleOm,
    durationMinutes: params.durationMinutes,
  );

  return notifier;
});

/// Generic non-family exam notifier provider for current active session
final activeExamNotifierProvider =
    StateNotifierProvider.autoDispose<ExamNotifier, ExamState>((ref) {
  final isarService = ref.watch(examIsarServiceProvider);
  final notifier = ExamNotifier(isarService: isarService);
  notifier.startExam(subjectId: 'herrega');
  return notifier;
});
