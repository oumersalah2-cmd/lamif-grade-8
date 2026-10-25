import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../exams/models/question_schema.dart';
import '../../exams/services/exam_isar_service.dart';
import '../../study/models/study_material_model.dart';
import '../../study/repositories/study_material_repository.dart';
import '../models/search_result_item.dart';

abstract class IGlobalSearchService {
  Future<List<SearchResultItem>> search({
    required String query,
    SearchCategoryFilter category = SearchCategoryFilter.all,
    String? subjectId,
  });

  Future<List<String>> getRecentSearches();
  Future<void> saveRecentSearch(String query);
  Future<void> removeRecentSearch(String query);
  Future<void> clearRecentSearches();
  List<String> getPopularSearchTerms();
}

class GlobalSearchService implements IGlobalSearchService {
  final IExamIsarService _isarExamService;
  final IStudyMaterialRepository _studyRepository;
  final SharedPreferences? _prefs;

  static const String _kRecentSearchesKey = 'lamif_global_search_recent';

  GlobalSearchService({
    required IExamIsarService isarExamService,
    required IStudyMaterialRepository studyRepository,
    SharedPreferences? prefs,
  })  : _isarExamService = isarExamService,
        _studyRepository = studyRepository,
        _prefs = prefs;

  Future<SharedPreferences> _getPrefs() async {
    return _prefs ?? await SharedPreferences.getInstance();
  }

  @override
  Future<List<SearchResultItem>> search({
    required String query,
    SearchCategoryFilter category = SearchCategoryFilter.all,
    String? subjectId,
  }) async {
    final cleanQuery = query.trim().toLowerCase();
    final results = <SearchResultItem>[];

    // 1. Search Exam Questions in local Isar collection
    if (category == SearchCategoryFilter.all || category == SearchCategoryFilter.questions) {
      final questions = await _isarExamService.searchQuestions(cleanQuery, subjectId: subjectId);
      for (final q in questions) {
        final snippet = _extractSnippet(
          primary: q.text,
          secondary: q.explanation,
          query: cleanQuery,
        );

        results.add(
          SearchResultItem(
            id: 'question_${q.id}',
            title: q.text,
            subtitle: '${_mapSubjectTitle(q.subjectId)} • Gaaffii Qormaataa',
            category: SearchCategoryFilter.questions,
            subjectId: q.subjectId,
            subjectNameOm: _mapSubjectTitle(q.subjectId),
            matchedSnippet: snippet,
            questionData: q,
          ),
        );
      }
    }

    // 2. Search Study Materials & Topics in local storage
    if (category == SearchCategoryFilter.all || category == SearchCategoryFilter.topics) {
      final materials = await _studyRepository.searchMaterials(cleanQuery, subjectId: subjectId);
      for (final m in materials) {
        final snippet = _extractSnippet(
          primary: '${m.unitTitleOm}: ${m.topicTitleOm}',
          secondary: m.summaryContentOm,
          query: cleanQuery,
        );

        results.add(
          SearchResultItem(
            id: 'topic_${m.id}',
            title: m.topicTitleOm,
            subtitle: '${_mapSubjectTitle(m.subjectId)} • Boqonnaa ${m.unitNumber}: ${m.unitTitleOm}',
            category: SearchCategoryFilter.topics,
            subjectId: m.subjectId,
            subjectNameOm: _mapSubjectTitle(m.subjectId),
            matchedSnippet: snippet,
            studyMaterialData: m,
          ),
        );
      }
    }

    return results;
  }

  String _extractSnippet({
    required String primary,
    required String secondary,
    required String query,
  }) {
    if (query.isEmpty) {
      return secondary.length > 90 ? '${secondary.substring(0, 90)}...' : secondary;
    }

    final lowerSec = secondary.toLowerCase();
    final matchIndex = lowerSec.indexOf(query);

    if (matchIndex != -1) {
      final start = (matchIndex - 30).clamp(0, secondary.length);
      final end = (matchIndex + query.length + 50).clamp(0, secondary.length);
      final prefix = start > 0 ? '...' : '';
      final suffix = end < secondary.length ? '...' : '';
      return '$prefix${secondary.substring(start, end)}$suffix';
    }

    return secondary.length > 90 ? '${secondary.substring(0, 90)}...' : secondary;
  }

  String _mapSubjectTitle(String subjectId) {
    switch (subjectId.toLowerCase()) {
      case 'herrega':
      case 'mathematics':
        return 'Herrega';
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
        return 'Afaan Ingilizii';
      case 'ict':
        return 'ICT';
      default:
        return subjectId.replaceFirst(subjectId[0], subjectId[0].toUpperCase());
    }
  }

  @override
  Future<List<String>> getRecentSearches() async {
    final prefs = await _getPrefs();
    final raw = prefs.getStringList(_kRecentSearchesKey) ?? [];
    return raw;
  }

  @override
  Future<void> saveRecentSearch(String query) async {
    final clean = query.trim();
    if (clean.isEmpty) return;

    final prefs = await _getPrefs();
    final current = prefs.getStringList(_kRecentSearchesKey) ?? [];
    current.removeWhere((item) => item.toLowerCase() == clean.toLowerCase());
    current.insert(0, clean);

    // Limit to 10 recent searches
    if (current.length > 10) {
      current.removeRange(10, current.length);
    }
    await prefs.setStringList(_kRecentSearchesKey, current);
  }

  @override
  Future<void> removeRecentSearch(String query) async {
    final prefs = await _getPrefs();
    final current = prefs.getStringList(_kRecentSearchesKey) ?? [];
    current.removeWhere((item) => item.toLowerCase() == query.toLowerCase());
    await prefs.setStringList(_kRecentSearchesKey, current);
  }

  @override
  Future<void> clearRecentSearches() async {
    final prefs = await _getPrefs();
    await prefs.remove(_kRecentSearchesKey);
  }

  @override
  List<String> getPopularSearchTerms() {
    return const [
      'Algebiraa',
      'Lakkoofsa Raashinaalii',
      'Caasluga',
      'Footosinteesisii',
      'Sirna Dhiigaa',
      'Seenaa Oromoo',
      'Geometrii',
      'Tenses',
      'Kompiitara',
    ];
  }
}
