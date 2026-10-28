import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../exams/services/exam_isar_service.dart';
import '../config/grade_scale_config.dart';
import '../models/grade_calculation_model.dart';
import '../services/grade_calculator_service.dart';

class GradeCalculatorState {
  final List<SubjectScoreEntry> subjects;
  final double targetPercentage;
  final GradeSummaryResult summary;
  final TargetPlannerResult targetPlan;
  final bool isAutoFilled;

  const GradeCalculatorState({
    required this.subjects,
    required this.targetPercentage,
    required this.summary,
    required this.targetPlan,
    this.isAutoFilled = false,
  });

  GradeCalculatorState copyWith({
    List<SubjectScoreEntry>? subjects,
    double? targetPercentage,
    GradeSummaryResult? summary,
    TargetPlannerResult? targetPlan,
    bool? isAutoFilled,
  }) {
    return GradeCalculatorState(
      subjects: subjects ?? this.subjects,
      targetPercentage: targetPercentage ?? this.targetPercentage,
      summary: summary ?? this.summary,
      targetPlan: targetPlan ?? this.targetPlan,
      isAutoFilled: isAutoFilled ?? this.isAutoFilled,
    );
  }
}

class GradeCalculatorNotifier extends StateNotifier<GradeCalculatorState> {
  final IExamIsarService _isarService;

  GradeCalculatorNotifier(this._isarService)
      : super(_initialState());

  static GradeCalculatorState _initialState() {
    final initialSubjects = GradeScaleConfig.standardSubjects.map((s) {
      return SubjectScoreEntry(
        subjectId: s.id,
        subjectNameOm: s.nameOm,
        subjectNameEn: s.nameEn,
        scoreObtained: null,
        maxMark: s.defaultMaxMark,
      );
    }).toList();

    const double initialTarget = 75.0;
    final initialSummary = GradeCalculatorService.calculateSummary(entries: initialSubjects);
    final initialPlan = GradeCalculatorService.planTarget(
      entries: initialSubjects,
      targetPercentage: initialTarget,
    );

    return GradeCalculatorState(
      subjects: initialSubjects,
      targetPercentage: initialTarget,
      summary: initialSummary,
      targetPlan: initialPlan,
    );
  }

  /// Update student's mark for a specific subject
  void updateScore(String subjectId, double? score) {
    final updated = state.subjects.map((s) {
      if (s.subjectId == subjectId) {
        return s.copyWith(scoreObtained: score);
      }
      return s;
    }).toList();

    _recalculate(updated, state.targetPercentage);
  }

  /// Update maximum mark for a subject
  void updateMaxMark(String subjectId, double maxMark) {
    if (maxMark <= 0) return;
    final updated = state.subjects.map((s) {
      if (s.subjectId == subjectId) {
        return s.copyWith(maxMark: maxMark);
      }
      return s;
    }).toList();

    _recalculate(updated, state.targetPercentage);
  }

  /// Set planner target average
  void setTargetPercentage(double target) {
    _recalculate(state.subjects, target);
  }

  /// Reset all entered scores
  void resetScores() {
    final cleared = state.subjects.map((s) => s.copyWith(scoreObtained: null)).toList();
    _recalculate(cleared, state.targetPercentage, isAutoFilled: false);
  }

  /// Auto-fill scores from student's best practice exams in local Isar database
  Future<int> autoFillFromBestExamScores() async {
    final allResults = await _isarService.getAllExamResults();
    if (allResults.isEmpty) return 0;

    // Map subjectId -> highest score ratio
    final Map<String, double> bestPercentageBySubject = {};
    for (final res in allResults) {
      if (res.totalQuestions <= 0) continue;
      final percentage = (res.score / res.totalQuestions) * 100.0;
      final sub = res.subjectId.toLowerCase();
      final currentBest = bestPercentageBySubject[sub] ?? 0.0;
      if (percentage > currentBest) {
        bestPercentageBySubject[sub] = percentage;
      }
    }

    int filledCount = 0;
    final updated = state.subjects.map((entry) {
      final best = bestPercentageBySubject[entry.subjectId.toLowerCase()];
      if (best != null) {
        // Convert best percentage to subject's maxMark
        final score = double.parse(((best / 100.0) * entry.maxMark).toStringAsFixed(1));
        filledCount++;
        return entry.copyWith(scoreObtained: score);
      }
      return entry;
    }).toList();

    _recalculate(updated, state.targetPercentage, isAutoFilled: true);
    return filledCount;
  }

  void _recalculate(List<SubjectScoreEntry> subjects, double target, {bool? isAutoFilled}) {
    final summary = GradeCalculatorService.calculateSummary(entries: subjects);
    final targetPlan = GradeCalculatorService.planTarget(
      entries: subjects,
      targetPercentage: target,
    );

    state = state.copyWith(
      subjects: subjects,
      targetPercentage: target,
      summary: summary,
      targetPlan: targetPlan,
      isAutoFilled: isAutoFilled ?? state.isAutoFilled,
    );
  }
}

final gradeCalculatorProvider =
    StateNotifierProvider<GradeCalculatorNotifier, GradeCalculatorState>((ref) {
  final isarService = ref.watch(examIsarServiceProvider);
  return GradeCalculatorNotifier(isarService);
});
