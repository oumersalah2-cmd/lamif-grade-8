import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../exams/models/exam_result_schema.dart';
import '../../exams/services/exam_isar_service.dart';
import '../config/grade_scale_config.dart';

/// Weak topic insight model
class WeakTopicInsight {
  final String subjectId;
  final String subjectNameOm;
  final String subjectNameEn;
  final String topicNameOm;
  final String topicNameEn;
  final double averageAccuracyPercentage;
  final int totalAttempts;
  final String recommendationOm;
  final String recommendationEn;

  const WeakTopicInsight({
    required this.subjectId,
    required this.subjectNameOm,
    required this.subjectNameEn,
    required this.topicNameOm,
    required this.topicNameEn,
    required this.averageAccuracyPercentage,
    required this.totalAttempts,
    required this.recommendationOm,
    required this.recommendationEn,
  });
}

class WeakTopicsAnalyzer {
  final IExamIsarService _isarService;

  WeakTopicsAnalyzer(this._isarService);

  /// Analyzes past exam results to extract subjects and topics where accuracy is < 60%
  Future<List<WeakTopicInsight>> findWeakTopics() async {
    final results = await _isarService.getAllExamResults();
    if (results.isEmpty) return [];

    // Group results by subject
    final Map<String, List<ExamResult>> subjectGroups = {};
    for (final r in results) {
      final sub = r.subjectId.toLowerCase();
      subjectGroups.putIfAbsent(sub, () => []).add(r);
    }

    final List<WeakTopicInsight> weakList = [];

    subjectGroups.forEach((subjectId, attempts) {
      int totalScore = 0;
      int totalQuestions = 0;

      for (final a in attempts) {
        totalScore += a.score;
        totalQuestions += a.totalQuestions;
      }

      final accuracy = totalQuestions > 0 ? (totalScore / totalQuestions) * 100.0 : 0.0;

      // If performance is below 65%, tag as weak topic
      if (accuracy < 65.0) {
        final subConfig = GradeScaleConfig.standardSubjects.firstWhere(
          (s) => s.id == subjectId,
          orElse: () => GradeSubjectConfig(
            id: subjectId,
            nameOm: subjectId,
            nameEn: subjectId,
          ),
        );

        weakList.add(
          WeakTopicInsight(
            subjectId: subjectId,
            subjectNameOm: subConfig.nameOm,
            subjectNameEn: subConfig.nameEn,
            topicNameOm: _getCommonTopicForSubject(subjectId, isOm: true),
            topicNameEn: _getCommonTopicForSubject(subjectId, isOm: false),
            averageAccuracyPercentage: double.parse(accuracy.toStringAsFixed(1)),
            totalAttempts: attempts.length,
            recommendationOm:
                "Qabxiin kee ${accuracy.toStringAsFixed(1)}% qofa. Shaakala gaaffilee kanaan duraa irra deebi'uun qabxii kee ol guddifadhu.",
            recommendationEn:
                'Average score is ${accuracy.toStringAsFixed(1)}%. Review topic formulas and retake practice quizzes.',
          ),
        );
      }
    });

    // Sort weakest first
    weakList.sort((a, b) => a.averageAccuracyPercentage.compareTo(b.averageAccuracyPercentage));
    return weakList;
  }

  String _getCommonTopicForSubject(String subjectId, {required bool isOm}) {
    switch (subjectId.toLowerCase()) {
      case 'herrega':
        return isOm ? "Herrega Aljebiraa fi Ji'oomeetirii" : 'Algebra & Geometry';
      case 'afaan_oromoo':
        return isOm ? 'Seera Barreessaa fi Ogbarruu' : 'Grammar & Literature';
      case 'saayinsii_waliigalaa':
        return isOm ? 'Mobaayiliitii fi Annisaa' : 'Motion & Energy';
      case 'english':
        return isOm ? 'Qubee fi Ijaarsa Himaa' : 'Grammar & Vocabulary';
      case 'lammummaa':
        return isOm ? 'Heera Mootummaa fi Dimookiraasii' : 'Constitution & Democracy';
      default:
        return isOm ? 'Mata Dureewwan Ijoo' : 'Key Core Concepts';
    }
  }
}

final weakTopicsAnalyzerProvider = Provider<WeakTopicsAnalyzer>((ref) {
  final isarService = ref.watch(examIsarServiceProvider);
  return WeakTopicsAnalyzer(isarService);
});

final weakTopicsListProvider = FutureProvider<List<WeakTopicInsight>>((ref) async {
  final analyzer = ref.watch(weakTopicsAnalyzerProvider);
  return analyzer.findWeakTopics();
});
