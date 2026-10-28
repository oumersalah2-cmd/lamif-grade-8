import '../config/grade_scale_config.dart';

/// Single subject score entry for calculation
class SubjectScoreEntry {
  final String subjectId;
  final String subjectNameOm;
  final String subjectNameEn;
  final double? scoreObtained;
  final double maxMark;

  const SubjectScoreEntry({
    required this.subjectId,
    required this.subjectNameOm,
    required this.subjectNameEn,
    this.scoreObtained,
    this.maxMark = 100.0,
  });

  bool get hasScore => scoreObtained != null && scoreObtained! >= 0;

  double get percentage {
    if (!hasScore || maxMark <= 0) return 0.0;
    return (scoreObtained! / maxMark) * 100.0;
  }

  SubjectScoreEntry copyWith({
    String? subjectId,
    String? subjectNameOm,
    String? subjectNameEn,
    double? scoreObtained,
    double? maxMark,
  }) {
    return SubjectScoreEntry(
      subjectId: subjectId ?? this.subjectId,
      subjectNameOm: subjectNameOm ?? this.subjectNameOm,
      subjectNameEn: subjectNameEn ?? this.subjectNameEn,
      scoreObtained: scoreObtained ?? this.scoreObtained,
      maxMark: maxMark ?? this.maxMark,
    );
  }
}

/// Overall grade calculation result
class GradeSummaryResult {
  final double totalObtained;
  final double totalMax;
  final double averagePercentage;
  final bool isPassed;
  final GradeAchievementTier tier;
  final int totalSubjectsCount;
  final int enteredSubjectsCount;

  const GradeSummaryResult({
    required this.totalObtained,
    required this.totalMax,
    required this.averagePercentage,
    required this.isPassed,
    required this.tier,
    required this.totalSubjectsCount,
    required this.enteredSubjectsCount,
  });
}

/// Target planner calculation outcome
class TargetPlannerResult {
  final double targetPercentage;
  final double requiredAverageOnRemaining;
  final bool isAchievable;
  final bool isAlreadyMet;
  final int remainingSubjectsCount;
  final String messageOm;
  final String messageEn;

  const TargetPlannerResult({
    required this.targetPercentage,
    required this.requiredAverageOnRemaining,
    required this.isAchievable,
    required this.isAlreadyMet,
    required this.remainingSubjectsCount,
    required this.messageOm,
    required this.messageEn,
  });
}
