import 'package:isar/isar.dart';

part 'user_progress_schema.g.dart';

/// Offline-first Isar UserProgress collection
/// Tracks student overall progress, topics mastered, and study time locally
/// Crucial: `isSynced` boolean flag strictly defaults to false until pushed to backend
@collection
class UserProgress {
  Id id = Isar.autoIncrement;

  @Index()
  late String userId;

  @Index()
  late String subjectId;

  int totalQuestionsAttempted = 0;

  int totalCorrectAnswers = 0;

  int totalTimeSpentSeconds = 0;

  @Index()
  DateTime? lastStudiedAt;

  /// Crucial flag for dual-database offline-first synchronization engine
  /// Must strictly default to false on all local actions
  @Index()
  bool isSynced = false;

  UserProgress({
    this.id = Isar.autoIncrement,
    this.userId = '',
    this.subjectId = '',
    this.totalQuestionsAttempted = 0,
    this.totalCorrectAnswers = 0,
    this.totalTimeSpentSeconds = 0,
    this.lastStudiedAt,
    this.isSynced = false,
  });

  /// Accuracy percentage calculation (0.0 to 100.0)
  double get accuracyPercentage => totalQuestionsAttempted > 0
      ? (totalCorrectAnswers / totalQuestionsAttempted) * 100.0
      : 0.0;

  /// Formatted study time (e.g. "45 min" or "2 hr 15 min")
  String get formattedStudyTime {
    final minutes = totalTimeSpentSeconds ~/ 60;
    if (minutes < 60) {
      return '$minutes daqiiqaa';
    }
    final hours = minutes ~/ 60;
    final remMin = minutes % 60;
    return '$hours sa\'a $remMin daq';
  }

  /// Afaan Oromoo Subject title helper
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
        return 'Barnoota Waliigalaa';
    }
  }

  UserProgress copyWith({
    Id? id,
    String? userId,
    String? subjectId,
    int? totalQuestionsAttempted,
    int? totalCorrectAnswers,
    int? totalTimeSpentSeconds,
    DateTime? lastStudiedAt,
    bool? isSynced,
  }) {
    return UserProgress(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      subjectId: subjectId ?? this.subjectId,
      totalQuestionsAttempted: totalQuestionsAttempted ?? this.totalQuestionsAttempted,
      totalCorrectAnswers: totalCorrectAnswers ?? this.totalCorrectAnswers,
      totalTimeSpentSeconds: totalTimeSpentSeconds ?? this.totalTimeSpentSeconds,
      lastStudiedAt: lastStudiedAt ?? this.lastStudiedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'subjectId': subjectId,
      'totalQuestionsAttempted': totalQuestionsAttempted,
      'totalCorrectAnswers': totalCorrectAnswers,
      'totalTimeSpentSeconds': totalTimeSpentSeconds,
      'lastStudiedAt': (lastStudiedAt ?? DateTime.now()).toIso8601String(),
      'isSynced': isSynced,
    };
  }

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      id: json['id'] as int? ?? Isar.autoIncrement,
      userId: json['userId'] as String? ?? '',
      subjectId: json['subjectId'] as String? ?? '',
      totalQuestionsAttempted: json['totalQuestionsAttempted'] as int? ?? 0,
      totalCorrectAnswers: json['totalCorrectAnswers'] as int? ?? 0,
      totalTimeSpentSeconds: json['totalTimeSpentSeconds'] as int? ?? 0,
      lastStudiedAt: json['lastStudiedAt'] != null
          ? DateTime.tryParse(json['lastStudiedAt'] as String)
          : DateTime.now(),
      isSynced: json['isSynced'] as bool? ?? false,
    );
  }
}
