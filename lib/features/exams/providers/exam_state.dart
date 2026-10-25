import '../models/question_schema.dart';
import '../models/exam_result_schema.dart';

/// Lifecycle statuses for an active offline exam session
enum ExamStatus {
  initial,
  loading,
  inProgress,
  completed,
  error,
}

/// Immutable state representing an active Grade 8 exam session
class ExamState {
  final String subjectId;
  final String subjectTitleOm;
  final List<Question> questions;
  final int currentQuestionIndex;
  
  /// Maps questionIndex -> selectedOptionIndex (0, 1, 2, 3...)
  final Map<int, int> selectedAnswers;

  /// Countdown timer remaining in seconds
  final int remainingSeconds;
  final int totalDurationSeconds;

  final ExamStatus status;
  final String? errorMessage;
  final ExamResult? finalResult;

  const ExamState({
    required this.subjectId,
    this.subjectTitleOm = 'Qormaata Kutaa 8ffaa',
    this.questions = const [],
    this.currentQuestionIndex = 0,
    this.selectedAnswers = const {},
    this.remainingSeconds = 3600, // 60 minutes default
    this.totalDurationSeconds = 3600,
    this.status = ExamStatus.initial,
    this.errorMessage,
    this.finalResult,
  });

  /// Factory for clean initialization
  factory ExamState.initial({
    String subjectId = 'herrega',
    String subjectTitleOm = 'Herrega',
    int durationMinutes = 60,
  }) {
    final totalSeconds = durationMinutes * 60;
    return ExamState(
      subjectId: subjectId,
      subjectTitleOm: subjectTitleOm,
      remainingSeconds: totalSeconds,
      totalDurationSeconds: totalSeconds,
      status: ExamStatus.initial,
    );
  }

  /// Current active question
  Question? get currentQuestion {
    if (questions.isEmpty ||
        currentQuestionIndex < 0 ||
        currentQuestionIndex >= questions.length) {
      return null;
    }
    return questions[currentQuestionIndex];
  }

  /// Flag indicating if user is on the final question of the test
  bool get isLastQuestion =>
      questions.isNotEmpty && currentQuestionIndex == questions.length - 1;

  /// Flag indicating if user is on the first question
  bool get isFirstQuestion => currentQuestionIndex == 0;

  /// Total number of questions
  int get totalQuestions => questions.length;

  /// Number of questions answered so far
  int get answeredCount => selectedAnswers.length;

  /// Progress fraction (0.0 to 1.0) for progress bars
  double get progressFraction =>
      totalQuestions > 0 ? (currentQuestionIndex + 1) / totalQuestions : 0.0;

  /// Selected option index for the current active question (or null if unanswered)
  int? get currentSelectedOption => selectedAnswers[currentQuestionIndex];

  /// Formatted countdown timer string ("MM:SS" or "HH:MM:SS")
  String get formattedRemainingTime {
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

  /// Timer warning: less than 5 minutes remaining
  bool get isTimeWarning => remainingSeconds <= 300 && remainingSeconds > 60;

  /// Timer critical: less than 1 minute remaining
  bool get isTimeCritical => remainingSeconds <= 60 && remainingSeconds > 0;

  /// Time has completely expired
  bool get isTimeUp => remainingSeconds <= 0;

  ExamState copyWith({
    String? subjectId,
    String? subjectTitleOm,
    List<Question>? questions,
    int? currentQuestionIndex,
    Map<int, int>? selectedAnswers,
    int? remainingSeconds,
    int? totalDurationSeconds,
    ExamStatus? status,
    String? errorMessage,
    ExamResult? finalResult,
  }) {
    return ExamState(
      subjectId: subjectId ?? this.subjectId,
      subjectTitleOm: subjectTitleOm ?? this.subjectTitleOm,
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      totalDurationSeconds: totalDurationSeconds ?? this.totalDurationSeconds,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      finalResult: finalResult ?? this.finalResult,
    );
  }
}
