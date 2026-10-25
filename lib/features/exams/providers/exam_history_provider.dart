import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/exam_result_schema.dart';
import '../services/exam_isar_service.dart';

/// Available sorting options for historical exams
enum ExamSortOrder {
  newestFirst,
  oldestFirst,
  highestScore,
  lowestScore,
}

extension ExamSortOrderExtension on ExamSortOrder {
  String get labelOm {
    switch (this) {
      case ExamSortOrder.newestFirst:
        return 'Haaraa Dura';
      case ExamSortOrder.oldestFirst:
        return 'Duraanii Dura';
      case ExamSortOrder.highestScore:
        return 'Qabxii Ol\'aanaa';
      case ExamSortOrder.lowestScore:
        return 'Qabxii Gadaanaa';
    }
  }
}

/// Filter state for exam history
class ExamHistoryFilter {
  final String? subjectId; // null = all subjects
  final ExamSortOrder sortOrder;

  const ExamHistoryFilter({
    this.subjectId,
    this.sortOrder = ExamSortOrder.newestFirst,
  });

  ExamHistoryFilter copyWith({
    String? Function()? subjectId,
    ExamSortOrder? sortOrder,
  }) {
    return ExamHistoryFilter(
      subjectId: subjectId != null ? subjectId() : this.subjectId,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

/// Per-subject performance breakdown
class SubjectPerformanceSummary {
  final String subjectId;
  final String subjectTitleOm;
  final int totalAttempts;
  final double averageScorePercentage;
  final double highestScorePercentage;
  final double latestScorePercentage;
  final bool isImproving;

  const SubjectPerformanceSummary({
    required this.subjectId,
    required this.subjectTitleOm,
    required this.totalAttempts,
    required this.averageScorePercentage,
    required this.highestScorePercentage,
    required this.latestScorePercentage,
    required this.isImproving,
  });
}

/// Detailed analytics tracking student improvement over time
class ExamImprovementStats {
  final int totalExams;
  final double averageScorePercentage;
  final double highestScorePercentage;
  final double lowestScorePercentage;
  final int passedExamsCount;
  final int failedExamsCount;
  final double passRatePercentage;
  final double improvementDelta; // Percentage change from early to recent tests
  final bool isImproving;
  final String improvementMessageOm;
  final List<ExamResult> recentChronologicalResults;
  final Map<String, SubjectPerformanceSummary> subjectBreakdowns;

  const ExamImprovementStats({
    required this.totalExams,
    required this.averageScorePercentage,
    required this.highestScorePercentage,
    required this.lowestScorePercentage,
    required this.passedExamsCount,
    required this.failedExamsCount,
    required this.passRatePercentage,
    required this.improvementDelta,
    required this.isImproving,
    required this.improvementMessageOm,
    required this.recentChronologicalResults,
    required this.subjectBreakdowns,
  });

  factory ExamImprovementStats.empty() {
    return const ExamImprovementStats(
      totalExams: 0,
      averageScorePercentage: 0.0,
      highestScorePercentage: 0.0,
      lowestScorePercentage: 0.0,
      passedExamsCount: 0,
      failedExamsCount: 0,
      passRatePercentage: 0.0,
      improvementDelta: 0.0,
      isImproving: false,
      improvementMessageOm: 'Qormaanni duraan fudhatame hin jiru.',
      recentChronologicalResults: [],
      subjectBreakdowns: {},
    );
  }
}

/// Reactive stream provider retrieving all ExamResult records from Isar
final examResultsStreamProvider = StreamProvider<List<ExamResult>>((ref) async* {
  final isarService = ref.watch(examIsarServiceProvider);

  // 1. Immediately yield initial records snapshot
  final initialList = await isarService.getAllExamResults();
  yield initialList;

  // 2. Stream subsequent mutations/updates
  yield* isarService.watchExamResults();
});

/// Filter state controller
final examHistoryFilterProvider = StateProvider<ExamHistoryFilter>((ref) {
  return const ExamHistoryFilter();
});

/// Filtered & sorted list of exam results
final filteredExamResultsProvider = Provider<List<ExamResult>>((ref) {
  final resultsAsync = ref.watch(examResultsStreamProvider);
  final filter = ref.watch(examHistoryFilterProvider);

  final allResults = resultsAsync.value ?? [];
  if (allResults.isEmpty) return [];

  // 1. Filter by subject if specified
  List<ExamResult> list = filter.subjectId == null || filter.subjectId!.isEmpty
      ? List<ExamResult>.from(allResults)
      : allResults
          .where((r) => r.subjectId.toLowerCase() == filter.subjectId!.toLowerCase())
          .toList();

  // 2. Sort results
  switch (filter.sortOrder) {
    case ExamSortOrder.newestFirst:
      list.sort((a, b) => b.dateTaken.compareTo(a.dateTaken));
      break;
    case ExamSortOrder.oldestFirst:
      list.sort((a, b) => a.dateTaken.compareTo(b.dateTaken));
      break;
    case ExamSortOrder.highestScore:
      list.sort((a, b) => b.scorePercentage.compareTo(a.scorePercentage));
      break;
    case ExamSortOrder.lowestScore:
      list.sort((a, b) => a.scorePercentage.compareTo(b.scorePercentage));
      break;
  }

  return list;
});

/// Provider computing student improvement metrics and trajectory over time
final examImprovementStatsProvider = Provider<ExamImprovementStats>((ref) {
  final resultsAsync = ref.watch(examResultsStreamProvider);
  final filter = ref.watch(examHistoryFilterProvider);
  final allResults = resultsAsync.value ?? [];

  if (allResults.isEmpty) {
    return ExamImprovementStats.empty();
  }

  // Filter based on active subject filter if user selected one
  final relevantResults = filter.subjectId == null || filter.subjectId!.isEmpty
      ? allResults
      : allResults
          .where((r) => r.subjectId.toLowerCase() == filter.subjectId!.toLowerCase())
          .toList();

  if (relevantResults.isEmpty) {
    return ExamImprovementStats.empty();
  }

  final totalExams = relevantResults.length;
  final scores = relevantResults.map((r) => r.scorePercentage).toList();
  final averageScore = scores.reduce((a, b) => a + b) / totalExams;
  final highestScore = scores.reduce((a, b) => a > b ? a : b);
  final lowestScore = scores.reduce((a, b) => a < b ? a : b);

  final passedCount = relevantResults.where((r) => r.isPassed).length;
  final failedCount = totalExams - passedCount;
  final passRate = (passedCount / totalExams) * 100.0;

  // Compute Improvement Trend (earlier tests vs recent tests)
  // Sort chronologically (oldest first)
  final chronological = List<ExamResult>.from(relevantResults)
    ..sort((a, b) => a.dateTaken.compareTo(b.dateTaken));

  double improvementDelta = 0.0;
  bool isImproving = false;
  String messageOm;

  if (chronological.length >= 2) {
    final half = (chronological.length / 2).floor();
    final firstHalfScores = chronological.take(half).map((e) => e.scorePercentage).toList();
    final secondHalfScores = chronological.skip(half).map((e) => e.scorePercentage).toList();

    final earlyAvg = firstHalfScores.isNotEmpty
        ? firstHalfScores.reduce((a, b) => a + b) / firstHalfScores.length
        : 0.0;
    final recentAvg = secondHalfScores.isNotEmpty
        ? secondHalfScores.reduce((a, b) => a + b) / secondHalfScores.length
        : 0.0;

    improvementDelta = recentAvg - earlyAvg;
    isImproving = improvementDelta >= 0;

    if (improvementDelta > 5.0) {
      messageOm = 'Baga gammaddan! Qabxiin kee +${improvementDelta.toStringAsFixed(1)}% dabaleera! 🚀';
    } else if (improvementDelta >= 0.0) {
      messageOm = 'Sadarkaan kee dhaabbataadha. Qabxii gaarii eeggachaa jirta! 👍';
    } else {
      messageOm = 'Qormaata duraanii caalaa xiqqoo gadi bu\'eera. Ammas shaakali! 💡';
    }
  } else {
    improvementDelta = 0.0;
    isImproving = true;
    messageOm = 'Qormaata dabalataa fudhachuun fooyya\'iinsa kee hordofi!';
  }

  // Subject breakdowns
  final Map<String, List<ExamResult>> bySubject = {};
  for (final res in allResults) {
    bySubject.putIfAbsent(res.subjectId, () => []).add(res);
  }

  final Map<String, SubjectPerformanceSummary> subjectSummaries = {};
  bySubject.forEach((subId, list) {
    list.sort((a, b) => a.dateTaken.compareTo(b.dateTaken));
    final subScores = list.map((e) => e.scorePercentage).toList();
    final subAvg = subScores.reduce((a, b) => a + b) / subScores.length;
    final subHighest = subScores.reduce((a, b) => a > b ? a : b);
    final subLatest = subScores.last;

    bool subImproving = true;
    if (list.length >= 2) {
      subImproving = subLatest >= subScores.first;
    }

    subjectSummaries[subId] = SubjectPerformanceSummary(
      subjectId: subId,
      subjectTitleOm: list.first.subjectTitleOm,
      totalAttempts: list.length,
      averageScorePercentage: subAvg,
      highestScorePercentage: subHighest,
      latestScorePercentage: subLatest,
      isImproving: subImproving,
    );
  });

  return ExamImprovementStats(
    totalExams: totalExams,
    averageScorePercentage: averageScore,
    highestScorePercentage: highestScore,
    lowestScorePercentage: lowestScore,
    passedExamsCount: passedCount,
    failedExamsCount: failedCount,
    passRatePercentage: passRate,
    improvementDelta: improvementDelta,
    isImproving: isImproving,
    improvementMessageOm: messageOm,
    recentChronologicalResults: chronological,
    subjectBreakdowns: subjectSummaries,
  );
});
