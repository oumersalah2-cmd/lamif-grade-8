import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../exams/services/exam_isar_service.dart';
import '../../study/repositories/study_material_repository.dart';
import '../models/search_result_item.dart';
import '../services/global_search_service.dart';

/// State representation for Global Search
class GlobalSearchState {
  final String query;
  final SearchCategoryFilter selectedCategory;
  final String? selectedSubjectId; // null = all subjects
  final List<SearchResultItem> results;
  final List<String> recentSearches;
  final List<String> popularTerms;
  final bool isSearching;
  final String? errorMessage;

  const GlobalSearchState({
    this.query = '',
    this.selectedCategory = SearchCategoryFilter.all,
    this.selectedSubjectId,
    this.results = const [],
    this.recentSearches = const [],
    this.popularTerms = const [],
    this.isSearching = false,
    this.errorMessage,
  });

  int get totalMatches => results.length;

  int get questionsCount =>
      results.where((r) => r.category == SearchCategoryFilter.questions).length;

  int get topicsCount =>
      results.where((r) => r.category == SearchCategoryFilter.topics).length;

  GlobalSearchState copyWith({
    String? query,
    SearchCategoryFilter? selectedCategory,
    String? Function()? selectedSubjectId,
    List<SearchResultItem>? results,
    List<String>? recentSearches,
    List<String>? popularTerms,
    bool? isSearching,
    String? errorMessage,
  }) {
    return GlobalSearchState(
      query: query ?? this.query,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedSubjectId: selectedSubjectId != null ? selectedSubjectId() : this.selectedSubjectId,
      results: results ?? this.results,
      recentSearches: recentSearches ?? this.recentSearches,
      popularTerms: popularTerms ?? this.popularTerms,
      isSearching: isSearching ?? this.isSearching,
      errorMessage: errorMessage,
    );
  }
}

/// Service Provider
final globalSearchServiceProvider = Provider<IGlobalSearchService>((ref) {
  final isarExamService = ref.watch(examIsarServiceProvider);
  final studyRepository = ref.watch(studyMaterialRepositoryProvider);
  return GlobalSearchService(
    isarExamService: isarExamService,
    studyRepository: studyRepository,
  );
});

/// StateNotifier handling real-time offline debounced searches
class GlobalSearchNotifier extends StateNotifier<GlobalSearchState> {
  final IGlobalSearchService _searchService;
  Timer? _debounceTimer;

  GlobalSearchNotifier(this._searchService) : super(const GlobalSearchState()) {
    _initSearchData();
  }

  Future<void> _initSearchData() async {
    final recent = await _searchService.getRecentSearches();
    final popular = _searchService.getPopularSearchTerms();
    state = state.copyWith(
      recentSearches: recent,
      popularTerms: popular,
    );
  }

  void onQueryChanged(String newQuery) {
    state = state.copyWith(query: newQuery);
    _debounceTimer?.cancel();

    if (newQuery.trim().isEmpty) {
      state = state.copyWith(results: [], isSearching: false);
      return;
    }

    state = state.copyWith(isSearching: true);
    _debounceTimer = Timer(const Duration(milliseconds: 250), () {
      executeSearch();
    });
  }

  Future<void> executeSearch() async {
    final q = state.query.trim();
    if (q.isEmpty) {
      state = state.copyWith(results: [], isSearching: false);
      return;
    }

    state = state.copyWith(isSearching: true);
    try {
      final results = await _searchService.search(
        query: q,
        category: state.selectedCategory,
        subjectId: state.selectedSubjectId,
      );

      // Save to recent search history
      await _searchService.saveRecentSearch(q);
      final recent = await _searchService.getRecentSearches();

      state = state.copyWith(
        results: results,
        recentSearches: recent,
        isSearching: false,
      );
    } catch (e) {
      state = state.copyWith(
        isSearching: false,
        errorMessage: 'Barbaaduun hin milkoofne: $e',
      );
    }
  }

  void selectCategory(SearchCategoryFilter category) {
    state = state.copyWith(selectedCategory: category);
    executeSearch();
  }

  void selectSubject(String? subjectId) {
    state = state.copyWith(selectedSubjectId: () => subjectId);
    executeSearch();
  }

  void applySearchTerm(String term) {
    state = state.copyWith(query: term);
    executeSearch();
  }

  void clearQuery() {
    _debounceTimer?.cancel();
    state = state.copyWith(query: '', results: [], isSearching: false);
  }

  Future<void> removeRecent(String term) async {
    await _searchService.removeRecentSearch(term);
    final updated = await _searchService.getRecentSearches();
    state = state.copyWith(recentSearches: updated);
  }

  Future<void> clearAllRecent() async {
    await _searchService.clearRecentSearches();
    state = state.copyWith(recentSearches: []);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

/// Provider for GlobalSearchNotifier
final globalSearchProvider =
    StateNotifierProvider<GlobalSearchNotifier, GlobalSearchState>((ref) {
  final service = ref.watch(globalSearchServiceProvider);
  return GlobalSearchNotifier(service);
});
