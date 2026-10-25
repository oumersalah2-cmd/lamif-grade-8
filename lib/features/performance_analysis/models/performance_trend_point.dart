import 'package:flutter/material.dart';

/// Single historical exam data point along the timeline
class PerformanceTrendPoint {
  final int id;
  final String subjectId;
  final String subjectNameOm;
  final DateTime dateTaken;
  final double scorePercentage;
  final int rawScore;
  final int totalQuestions;
  final int durationSeconds;
  final bool isPassed;

  const PerformanceTrendPoint({
    required this.id,
    required this.subjectId,
    required this.subjectNameOm,
    required this.dateTaken,
    required this.scorePercentage,
    required this.rawScore,
    required this.totalQuestions,
    required this.durationSeconds,
    required this.isPassed,
  });

  /// Subject display color for multi-series visualization
  Color get subjectColor {
    switch (subjectId.toLowerCase()) {
      case 'herrega':
      case 'mathematics':
        return const Color(0xFF2563EB); // Deep Blue
      case 'afaan_oromoo':
      case 'afaanoromoo':
        return const Color(0xFF16A34A); // Emerald Green
      case 'saayinsii_waliigalaa':
      case 'general_science':
      case 'science':
        return const Color(0xFFD97706); // Amber Orange
      case 'hawaasa':
      case 'social_studies':
        return const Color(0xFF9333EA); // Purple
      case 'english':
        return const Color(0xFF0284C7); // Cyan
      case 'ict':
        return const Color(0xFF0F766E); // Teal
      default:
        return const Color(0xFF1B6E32); // Brand Green
    }
  }

  String get formattedDate {
    return '${dateTaken.day}/${dateTaken.month}/${dateTaken.year}';
  }
}
