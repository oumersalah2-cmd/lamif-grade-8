class ExamAttemptModel {
  final String id;
  final String subjectId;
  final String examType; // "MOCK_MINISTRY" or "PRACTICE"
  final int totalQuestions;
  final int correctAnswersCount;
  final int scorePercentage;
  final int timeTakenSeconds;
  final DateTime timestamp;
  final Map<String, int> answersMap;
  final bool isSynced;

  const ExamAttemptModel({
    required this.id,
    required this.subjectId,
    required this.examType,
    required this.totalQuestions,
    required this.correctAnswersCount,
    required this.scorePercentage,
    required this.timeTakenSeconds,
    required this.timestamp,
    required this.answersMap,
    this.isSynced = false,
  });

  factory ExamAttemptModel.fromJson(Map<String, dynamic> json) {
    return ExamAttemptModel(
      id: json['id'] as String,
      subjectId: json['subjectId'] as String,
      examType: json['examType'] as String,
      totalQuestions: json['totalQuestions'] as int,
      correctAnswersCount: json['correctAnswersCount'] as int,
      scorePercentage: json['scorePercentage'] as int,
      timeTakenSeconds: json['timeTakenSeconds'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
      answersMap: (json['answersMap'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, v as int),
      ),
      isSynced: json['isSynced'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subjectId': subjectId,
      'examType': examType,
      'totalQuestions': totalQuestions,
      'correctAnswersCount': correctAnswersCount,
      'scorePercentage': scorePercentage,
      'timeTakenSeconds': timeTakenSeconds,
      'timestamp': timestamp.toIso8601String(),
      'answersMap': answersMap,
      'isSynced': isSynced,
    };
  }

  ExamAttemptModel copyWith({
    String? id,
    String? subjectId,
    String? examType,
    int? totalQuestions,
    int? correctAnswersCount,
    int? scorePercentage,
    int? timeTakenSeconds,
    DateTime? timestamp,
    Map<String, int>? answersMap,
    bool? isSynced,
  }) {
    return ExamAttemptModel(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      examType: examType ?? this.examType,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      correctAnswersCount: correctAnswersCount ?? this.correctAnswersCount,
      scorePercentage: scorePercentage ?? this.scorePercentage,
      timeTakenSeconds: timeTakenSeconds ?? this.timeTakenSeconds,
      timestamp: timestamp ?? this.timestamp,
      answersMap: answersMap ?? this.answersMap,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
