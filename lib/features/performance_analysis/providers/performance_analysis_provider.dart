import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../exams/models/exam_result_schema.dart';
import '../../exams/providers/exam_history_provider.dart';
import '../models/performance_trend_point.dart';
import '../models/subject_metric.dart';
import '../models/time_range_filter.dart';

/// State representation for the PerformanceAnalysis visualization engine
class PerformanceAnalysisState {
  final TimeRangeFilter timeRange;
  final String? selectedSubjectId; // null = all subjects
  final List<PerformanceTrendPoint> trendPoints;
  final Map<String, SubjectMetric> subjectMetrics;
  final double overallAverage;
  final double highestScore;
  final int totalExams;
  final double overallPassRate;
  final double overallTrendDelta;
  final bool isImproving;
  final SubjectMetric? strongestSubject;
  final SubjectMetric? needsFocusSubject;
  final bool isLoading;

  const PerformanceAnalysisState({
    this.timeRange = TimeRangeFilter.allTime,
    this.selectedSubjectId,
    this.trendPoints = const [],
    this.subjectMetrics = const {},
    this.overallAverage = 0.0,
    this.highestScore = 0.0,
    this.totalExams = 0,
    this.overallPassRate = 0.0,
    this.overallTrendDelta = 0.0,
    this.isImproving = true,
    this.strongestSubject,
    this.needsFocusSubject,
    this.isLoading = false,
  });

  PerformanceAnalysisState copyWith({
    TimeRangeFilter? timeRange,
    String? Function()? selectedSubjectId,
    List<PerformanceTrendPoint>? trendPoints,
    Map<String, SubjectMetric>? subjectMetrics,
    double? overallAverage,
    double? highestScore,
    int? totalExams,
    double? overallPassRate,
    double? overallTrendDelta,
    bool? isImproving,
    SubjectMetric? Function()? strongestSubject,
    SubjectMetric? Function()? needsFocusSubject,
    bool? isLoading,
  }) {
    return PerformanceAnalysisState(
      timeRange: timeRange ?? this.timeRange,
      selectedSubjectId: selectedSubjectId != null ? selectedSubjectId() : this.selectedSubjectId,
      trendPoints: trendPoints ?? this.trendPoints,
      subjectMetrics: subjectMetrics ?? this.subjectMetrics,
      overallAverage: overallAverage ?? this.overallAverage,
      highestScore: highestScore ?? this.highestScore,
      totalExams: totalExams ?? this.totalExams,
      overallPassRate: overallPassRate ?? this.overallPassRate,
      overallTrendDelta: overallTrendDelta ?? this.overallTrendDelta,
      isImproving: isImproving ?? this.isImproving,
      strongestSubject: strongestSubject != null ? strongestSubject() : this.strongestSubject,
      needsFocusSubject: needsFocusSubject != null ? needsFocusSubject() : this.needsFocusSubject,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Helper mapping raw subject IDs to Afaan Oromoo titles
String mapSubjectIdToTitleOm(String id) {
  switch (id.toLowerCase().trim()) {
    case 'herrega':
    case 'mathematics':
      return 'Herrega (Math)';
    case 'afaan_oromoo':
    case 'afaanoromoo':
      return 'Afaan Oromoo';
    case 'saayinsii_waliigalaa':
    case 'general_science':
      return 'Saayinsii Waliigalaa';
    case 'hawaasa':
    case 'social_studies':
      return 'Barnoota Hawaasaa';
    case 'english':
      return 'Afaan Ingilizii (English)';
    case 'ict':
      return 'ICT';
    default:
      return id.replaceFirst(id[0], id[0].toUpperCase());
  }
}

/// Riverpod StateNotifier processing raw Isar ExamResult records into visualization analytics
class PerformanceAnalysisNotifier extends StateNotifier<PerformanceAnalysisState> {
  final Ref _ref;

  PerformanceAnalysisNotifier(this._ref) : super(const PerformanceAnalysisState()) {
    // Listen to changes in the underlying Isar ExamResult stream
    _ref.listen<AsyncValue<List<ExamResult>>>(examResultsStreamProvider, (prev, next) {
      if (next.hasValue) {
        _recalculateAnalytics(next.value ?? []);
      }
    });

    final initialResults = _ref.read(examResultsStreamProvider).value;
    if (initialResults != null) {
      _recalculateAnalytics(initialResults);
    }
  }

  void setTimeRange(TimeRangeFilter range) {
    state = state.copyWith(timeRange: range);
    final results = _ref.read(examResultsStreamProvider).value ?? [];
    _recalculateAnalytics(results);
  }

  void selectSubject(String? subjectId) {
    state = state.copyWith(selectedSubjectId: () => subjectId);
    final results = _ref.read(examResultsStreamProvider).value ?? [];
    _recalculateAnalytics(results);
  }

  void _recalculateAnalytics(List<ExamResult> rawResults) {
    if (rawResults.isEmpty) {
      state = state.copyWith(
        trendPoints: [],
        subjectMetrics: {},
        overallAverage: 0.0,
        highestScore: 0.0,
        totalExams: 0,
        overallPassRate: 0.0,
        overallTrendDelta: 0.0,
        strongestSubject: () => null,
        needsFocusSubject: () => null,
      );
      return;
    }

    // 1. Filter by time range cutoff
    final cutoff = state.timeRange.cutoffDate;
    var filtered = cutoff == null
        ? List<ExamResult>.from(rawResults)
        : rawResults.where((r) => r.dateTaken.isAfter(cutoff)).toList();

    // 2. Sort chronologically (oldest to newest for trend line drawing)
    filtered.sort((a, b) => a.dateTaken.compareTo(b.dateTaken));

    // 3. Compute subject-wise breakdown metrics
    final Map<String, List<ExamResult>> subjectMap = {};
    for (final res in filtered) {
      final key = res.subjectId.toLowerCase().trim();
      subjectMap.putIfAbsent(key, () => []).add(res);
    }

    final Map<String, SubjectMetric> metrics = {};
    for (final entry in subjectMap.entries) {
      final subId = entry.key;
      final list = entry.value;

      final totalAttempts = list.length;
      final avg = list.map((e) => e.scorePercentage).reduce((a, b) => a + b) / totalAttempts;
      final highest = list.map((e) => e.scorePercentage).reduce((a, b) => a > b ? a : b);
      final lowest = list.map((e) => e.scorePercentage).reduce((a, b) => a < b ? a : b);
      final recent = list.last.scorePercentage;
      final passed = list.where((e) => e.isPassed).length;
      final failed = totalAttempts - passed;

      // Calculate trend delta (comparing second half average to first half average)
      double delta = 0.0;
      if (totalAttempts >= 2) {
        final mid = totalAttempts ~/ 2;
        final firstHalfAvg = list.take(mid).map((e) => e.scorePercentage).reduce((a, b) => a + b) / mid;
        final secondHalfAvg = list.skip(mid).map((e) => e.scorePercentage).reduce((a, b) => a + b) / (totalAttempts - mid);
        delta = secondHalfAvg - firstHalfAvg;
      }

      metrics[subId] = SubjectMetric(
        subjectId: subId,
        titleOm: mapSubjectIdToTitleOm(subId),
        totalExamsTaken: totalAttempts,
        averageScorePercentage: avg,
        highestScorePercentage: highest,
        lowestScorePercentage: lowest,
        recentScorePercentage: recent,
        trendDelta: delta,
        passedCount: passed,
        failedCount: failed,
      );
    }

    // Identify Strongest and Needs Focus subjects
    SubjectMetric? strongest;
    SubjectMetric? needsFocus;

    if (metrics.isNotEmpty) {
      final sortedMetrics = metrics.values.toList()
        ..sort((a, b) => b.averageScorePercentage.compareTo(a.averageScorePercentage));
      strongest = sortedMetrics.first;
      needsFocus = sortedMetrics.last;
    }

    // 4. Generate points for trend visualization
    final targetList = state.selectedSubjectId == null
        ? filtered
        : filtered.where((r) => r.subjectId.toLowerCase() == state.selectedSubjectId!.toLowerCase()).toList();

    final trendPoints = targetList.map((r) {
      return PerformanceTrendPoint(
        id: r.id,
        subjectId: r.subjectId,
        subjectNameOm: mapSubjectIdToTitleOm(r.subjectId),
        dateTaken: r.dateTaken,
        scorePercentage: r.scorePercentage,
        rawScore: r.score,
        totalQuestions: r.totalQuestions,
        durationSeconds: r.timeTaken,
        isPassed: r.isPassed,
      );
    }).toList();

    // 5. Global aggregated stats
    final totalExams = targetList.length;
    final overallAvg = totalExams > 0
        ? targetList.map((e) => e.scorePercentage).reduce((a, b) => a + b) / totalExams
        : 0.0;
    final highest = totalExams > 0
        ? targetList.map((e) => e.scorePercentage).reduce((a, b) => a > b ? a : b)
        : 0.0;
    final passedCount = targetList.where((e) => e.isPassed).length;
    final passRate = totalExams > 0 ? (passedCount / totalExams) * 100.0 : 0.0;

    double globalDelta = 0.0;
    if (totalExams >= 2) {
      final mid = totalExams ~/ 2;
      final firstHalf = targetList.take(mid).map((e) => e.scorePercentage).reduce((a, b) => a + b) / mid;
      final secondHalf = targetList.skip(mid).map((e) => e.scorePercentage).reduce((a, b) => a + b) / (totalExams - mid);
      globalDelta = secondHalf - firstHalf;
    }

    state = state.copyWith(
      trendPoints: trendPoints,
      subjectMetrics: metrics,
      overallAverage: overallAvg,
      highestScore: highest,
      totalExams: totalExams,
      overallPassRate: passRate,
      overallTrendDelta: globalDelta,
      isImproving: globalDelta >= 0,
      strongestSubject: () => strongest,
      needsFocusSubject: () => needsFocus,
    );
  }
}

/// Provider exposing the performance analysis state
final performanceAnalysisProvider =
    StateNotifierProvider<PerformanceAnalysisNotifier, PerformanceAnalysisState>((ref) {
  return PerformanceAnalysisNotifier(ref);
});
