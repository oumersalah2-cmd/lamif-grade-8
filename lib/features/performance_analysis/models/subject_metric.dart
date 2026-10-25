import 'package:flutter/material.dart';

/// Aggregated subject-wise performance analytics for Grade 8 subjects
class SubjectMetric {
  final String subjectId;
  final String titleOm;
  final int totalExamsTaken;
  final double averageScorePercentage;
  final double highestScorePercentage;
  final double lowestScorePercentage;
  final double recentScorePercentage;
  final double trendDelta; // Difference between recent average and overall average
  final int passedCount;
  final int failedCount;

  const SubjectMetric({
    required this.subjectId,
    required this.titleOm,
    required this.totalExamsTaken,
    required this.averageScorePercentage,
    required this.highestScorePercentage,
    required this.lowestScorePercentage,
    required this.recentScorePercentage,
    required this.trendDelta,
    required this.passedCount,
    required this.failedCount,
  });

  bool get isImproving => trendDelta >= 0;

  double get passRate =>
      totalExamsTaken > 0 ? (passedCount / totalExamsTaken) * 100.0 : 0.0;

  Color get accentColor {
    switch (subjectId.toLowerCase()) {
      case 'herrega':
        return const Color(0xFF2563EB);
      case 'afaan_oromoo':
        return const Color(0xFF16A34A);
      case 'saayinsii_waliigalaa':
        return const Color(0xFFD97706);
      case 'hawaasa':
        return const Color(0xFF9333EA);
      case 'english':
        return const Color(0xFF0284C7);
      case 'ict':
        return const Color(0xFF0F766E);
      default:
        return const Color(0xFF1B6E32);
    }
  }

  IconData get icon {
    switch (subjectId.toLowerCase()) {
      case 'herrega':
        return Icons.calculate_rounded;
      case 'afaan_oromoo':
        return Icons.menu_book_rounded;
      case 'saayinsii_waliigalaa':
        return Icons.science_rounded;
      case 'hawaasa':
        return Icons.public_rounded;
      case 'english':
        return Icons.language_rounded;
      case 'ict':
        return Icons.computer_rounded;
      default:
        return Icons.school_rounded;
    }
  }
}
