import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/search_result_item.dart';
import '../providers/global_search_provider.dart';
import '../widgets/question_detail_modal.dart';
import '../widgets/search_result_card.dart';

/// Full-screen Global Search for Grade 8 students to find questions,
/// study topics, formulas, and past exam items offline.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(globalSearchProvider);
    final searchNotifier = ref.read(globalSearchProvider.notifier);
    final theme = Theme.of(context);

    // Keep text controller in sync if search term applied externally
    if (_controller.text != searchState.query && searchState.query.isNotEmpty && _controller.text.isEmpty) {
      _controller.text = searchState.query;
      _controller.selection = TextSelection.fromPosition(TextPosition(offset: _controller.text.length));
    }

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Container(
          margin: const EdgeInsets.only(right: 16),
          child: TextField(
            controller: _controller,
            autofocus: false,
            decoration: InputDecoration(
              hintText: 'Gaaffii, mata-duree, seera barbaadi...',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: searchState.query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _controller.clear();
                        searchNotifier.clearQuery();
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              filled: true,
              fillColor: theme.cardColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.2)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.2)),
              ),
            ),
            onChanged: (text) => searchNotifier.onQueryChanged(text),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Category Filter Chips (All, Questions, Topics)
            _buildCategoryFilters(searchState, searchNotifier),

            // 2. Main Search Body
            Expanded(
              child: searchState.isSearching
                  ? const Center(child: CircularProgressIndicator())
                  : searchState.query.trim().isEmpty
                      ? _buildEmptyQueryContent(searchState, searchNotifier, theme)
                      : _buildResultsList(searchState, theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilters(GlobalSearchState state, GlobalSearchNotifier notifier) {
    final categories = [
      {'filter': SearchCategoryFilter.all, 'label': 'Hunda (${state.totalMatches})'},
      {'filter': SearchCategoryFilter.questions, 'label': 'Gaaffilee (${state.questionsCount})'},
      {'filter': SearchCategoryFilter.topics, 'label': 'Mata-dureewwan (${state.topicsCount})'},
    ];

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final filter = cat['filter'] as SearchCategoryFilter;
          final isSelected = state.selectedCategory == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(cat['label'] as String),
              selected: isSelected,
              selectedColor: const Color(0xFF15803D),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : null,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 12.5,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              onSelected: (_) => notifier.selectCategory(filter),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyQueryContent(
    GlobalSearchState state,
    GlobalSearchNotifier notifier,
    ThemeData theme,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Popular Topics Suggestions
          if (state.popularTerms.isNotEmpty) ...[
            Row(
              children: const [
                Icon(Icons.local_fire_department_rounded, size: 18, color: Color(0xFFEA580C)),
                SizedBox(width: 6),
                Text(
                  'Barbaadamaa fi Jaallatamaa',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: state.popularTerms.map((term) {
                return ActionChip(
                  label: Text(term),
                  avatar: const Icon(Icons.trending_up, size: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onPressed: () {
                    _controller.text = term;
                    notifier.applySearchTerm(term);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],

          // Recent Searches
          if (state.recentSearches.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.history_rounded, size: 18, color: Colors.grey),
                    SizedBox(width: 6),
                    Text(
                      'Kanaan Dura Kan Barbaadde',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => notifier.clearAllRecent(),
                  child: const Text('Haqi', style: TextStyle(fontSize: 12, color: Colors.red)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...state.recentSearches.map(
              (term) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.access_time_rounded, size: 18, color: Colors.grey),
                title: Text(term, style: const TextStyle(fontSize: 14)),
                trailing: IconButton(
                  icon: const Icon(Icons.close, size: 16, color: Colors.grey),
                  onPressed: () => notifier.removeRecent(term),
                ),
                onTap: () {
                  _controller.text = term;
                  notifier.applySearchTerm(term);
                },
              ),
            ),
          ],

          // Search Tip Box
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Row(
              children: const [
                Icon(Icons.info_outline_rounded, color: Color(0xFF1D4ED8), size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Gaaffilee Qormaata Naannoo waggoota darbee fi yaadannoowwan barnootaa toora-alaan (offline) asitti barbaaduu dandeessa.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF1E40AF), height: 1.3),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(GlobalSearchState state, ThemeData theme) {
    if (state.results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                '"${state.query}" irratti homaa hin argamne',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                'Mee jecha biraatiin yaali ykn gosa barnootaa jijjiiri.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: state.results.length,
      itemBuilder: (context, index) {
        final item = state.results[index];
        return SearchResultCard(
          item: item,
          query: state.query,
          onTap: () {
            if (item.questionData != null) {
              QuestionDetailModal.show(context, item.questionData!, item.subjectNameOm);
            } else {
              _showTopicDetailDialog(context, item);
            }
          },
        );
      },
    );
  }

  void _showTopicDetailDialog(BuildContext context, SearchResultItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(item.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Gosa Barnootaa: ${item.subjectNameOm}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF15803D)),
              ),
              const SizedBox(height: 10),
              Text(item.matchedSnippet, style: const TextStyle(fontSize: 14, height: 1.4)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cufi'),
          ),
        ],
      ),
    );
  }
}
