import 'package:flutter/material.dart';
import '../../exams/models/question_schema.dart';
import '../../study/models/study_material_model.dart';

/// Category filter for global search
enum SearchCategoryFilter {
  all('Hunda', 'All Results', Icons.apps_rounded),
  questions('Gaaffilee', 'Exam Questions', Icons.quiz_outlined),
  topics('Mata-dureewwan', 'Study Topics', Icons.menu_book_rounded);

  final String labelOm;
  final String labelEn;
  final IconData icon;

  const SearchCategoryFilter(this.labelOm, this.labelEn, this.icon);
}

/// Normalized search result item representing an offline Question or Topic
class SearchResultItem {
  final String id;
  final String title;
  final String subtitle;
  final SearchCategoryFilter category;
  final String subjectId;
  final String subjectNameOm;
  final String matchedSnippet;
  final Question? questionData;
  final StudyMaterialModel? studyMaterialData;

  const SearchResultItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.subjectId,
    required this.subjectNameOm,
    required this.matchedSnippet,
    this.questionData,
    this.studyMaterialData,
  });

  bool get isQuestion => category == SearchCategoryFilter.questions;
  bool get isStudyTopic => category == SearchCategoryFilter.topics;

  String get categoryBadgeOm {
    switch (category) {
      case SearchCategoryFilter.questions:
        return 'Gaaffii Qormaataa';
      case SearchCategoryFilter.topics:
        return 'Mata-duree Qo\'annoo';
      case SearchCategoryFilter.all:
        return 'Waliigala';
    }
  }

  Color get categoryColor {
    switch (category) {
      case SearchCategoryFilter.questions:
        return const Color(0xFF0D47A1); // Academic Blue
      case SearchCategoryFilter.topics:
        return const Color(0xFF15803D); // Emerald Green
      case SearchCategoryFilter.all:
        return const Color(0xFF475569);
    }
  }

  IconData get icon {
    switch (category) {
      case SearchCategoryFilter.questions:
        return Icons.quiz_rounded;
      case SearchCategoryFilter.topics:
        return Icons.auto_stories_rounded;
      case SearchCategoryFilter.all:
        return Icons.search_rounded;
    }
  }

  Color get subjectColor {
    switch (subjectId.toLowerCase()) {
      case 'herrega':
      case 'mathematics':
        return const Color(0xFF2563EB);
      case 'afaan_oromoo':
      case 'afaanoromoo':
        return const Color(0xFF16A34A);
      case 'saayinsii_waliigalaa':
      case 'general_science':
        return const Color(0xFFD97706);
      case 'hawaasa':
      case 'social_studies':
        return const Color(0xFF9333EA);
      case 'english':
        return const Color(0xFF0284C7);
      case 'ict':
        return const Color(0xFF0F766E);
      default:
        return const Color(0xFF1B6E32);
    }
  }
}
