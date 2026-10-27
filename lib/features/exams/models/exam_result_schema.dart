import 'package:isar/isar.dart';

part 'exam_result_schema.g.dart';

/// Offline-first Isar ExamResult collection
/// Tracks student performance locally with isSynced flag defaulting to false
@collection
class ExamResult {
  Id id = Isar.autoIncrement;

  @Index()
  late String subjectId;

  late int score;

  late int totalQuestions;

  late int timeTaken; // Duration in seconds

  @Index()
  DateTime? dateTaken;

  /// Critical flag for offline-first synchronization engine
  /// Must strictly default to false until pushed to backend
  @Index()
  bool isSynced = false;

  ExamResult({
    this.id = Isar.autoIncrement,
    this.subjectId = '',
    this.score = 0,
    this.totalQuestions = 0,
    this.timeTaken = 0,
    this.dateTaken,
    this.isSynced = false,
  });

  /// Calculates percentage score (0.0 to 100.0)
  double get scorePercentage =>
      totalQuestions > 0 ? (score / totalQuestions) * 100.0 : 0.0;

  /// Passing threshold for Grade 8 (typically 50% or above)
  bool get isPassed => scorePercentage >= 50.0;

  /// Formatted duration string (e.g., "12:45" or "1:05:30")
  String get formattedTimeTaken {
    final minutes = (timeTaken % 3600) ~/ 60;
    final seconds = timeTaken % 60;
    final hours = timeTaken ~/ 3600;

    final minStr = minutes.toString().padLeft(2, '0');
    final secStr = seconds.toString().padLeft(2, '0');

    if (hours > 0) {
      final hrStr = hours.toString().padLeft(2, '0');
      return '$hrStr:$minStr:$secStr';
    }
    return '$minStr:$secStr';
  }

  /// Formatted date string (e.g., "2026-02-24 14:30")
  String get formattedDate {
    final dt = dateTaken ?? DateTime.now();
    final year = dt.year;
    final month = dt.month.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$year-$month-$day $hour:$minute';
  }

  /// Afaan Oromoo Subject Name Helper
  String get subjectTitleOm {
    switch (subjectId.toLowerCase()) {
      case 'herrega':
        return 'Herrega';
      case 'afaan_oromoo':
        return 'Afaan Oromoo';
      case 'saayinsii_waliigalaa':
        return 'Saayinsii Waliigalaa';
      case 'hawaasummaa':
      case 'saayinsii_hawaasaa':
        return 'Barnoota Hawaasummaa';
      case 'lammummaa':
        return 'Barnoota Lammummaa';
      case 'english':
        return 'Afaan Ingilizii';
      default:
        return 'Qormaata Waliigalaa';
    }
  }

  ExamResult copyWith({
    Id? id,
    String? subjectId,
    int? score,
    int? totalQuestions,
    int? timeTaken,
    DateTime? dateTaken,
    bool? isSynced,
  }) {
    return ExamResult(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      score: score ?? this.score,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      timeTaken: timeTaken ?? this.timeTaken,
      dateTaken: dateTaken ?? this.dateTaken,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subjectId': subjectId,
      'score': score,
      'totalQuestions': totalQuestions,
      'timeTaken': timeTaken,
      'dateTaken': (dateTaken ?? DateTime.now()).toIso8601String(),
      'isSynced': isSynced,
    };
  }

  factory ExamResult.fromJson(Map<String, dynamic> json) {
    return ExamResult(
      id: json['id'] as int? ?? Isar.autoIncrement,
      subjectId: json['subjectId'] as String? ?? '',
      score: json['score'] as int? ?? 0,
      totalQuestions: json['totalQuestions'] as int? ?? 0,
      timeTaken: json['timeTaken'] as int? ?? 0,
      dateTaken: json['dateTaken'] != null
          ? DateTime.parse(json['dateTaken'] as String)
          : DateTime.now(),
      isSynced: json['isSynced'] as bool? ?? false,
    );
  }
}
