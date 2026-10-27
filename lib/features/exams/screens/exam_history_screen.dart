import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/exam_result_schema.dart';
import '../providers/exam_history_provider.dart';
import '../repositories/exam_repository.dart';
import '../services/exam_isar_service.dart';
import '../services/exam_sync_worker.dart';
import 'exam_screen.dart';

/// Screen displaying a list of past ExamResult entries from the local Isar database,
/// showing dates taken, scores, and analytics to help students track improvement over time.
/// Localized entirely in Afaan Oromoo with Material Design 3.
class ExamHistoryScreen extends ConsumerWidget {
  const ExamHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(examResultsStreamProvider);
    final filteredResults = ref.watch(filteredExamResultsProvider);
    final stats = ref.watch(examImprovementStatsProvider);
    final filter = ref.watch(examHistoryFilterProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Seenaa Qormaataa',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Gala Qabxii fi Fooyya\'iinsa Barataa',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1B6E32),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // WorkManager background & immediate sync button
          IconButton(
            tooltip: 'Qabxii Duumessatti Qindeessi (WorkManager Sync)',
            icon: const Icon(Icons.sync),
            onPressed: () async {
              final syncManager = ref.read(examWorkManagerServiceProvider);
              // Trigger WorkManager one-off task for background persistence
              await syncManager.triggerImmediateOneOffSync();
              // Perform immediate foreground execution for instant UI update
              final result = await syncManager.performForegroundSync();
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(
                          result.isSuccess ? Icons.cloud_done : Icons.cloud_off,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text(result.messageOm)),
                      ],
                    ),
                    backgroundColor: result.isSuccess
                        ? const Color(0xFF1B6E32)
                        : const Color(0xFFD97706),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),
          // Sorting Menu
          PopupMenuButton<ExamSortOrder>(
            tooltip: 'Tartiiba Filadhu',
            icon: const Icon(Icons.sort),
            initialValue: filter.sortOrder,
            onSelected: (newSort) {
              ref.read(examHistoryFilterProvider.notifier).update(
                    (state) => state.copyWith(sortOrder: newSort),
                  );
            },
            itemBuilder: (context) => [
              for (final sortOption in ExamSortOrder.values)
                PopupMenuItem(
                  value: sortOption,
                  child: Row(
                    children: [
                      Icon(
                        sortOption == filter.sortOrder
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        size: 18,
                        color: sortOption == filter.sortOrder
                            ? const Color(0xFF1B6E32)
                            : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(sortOption.labelOm),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: resultsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFF1B6E32)),
          ),
          error: (err, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(
                    'Dogoggora seenaa qormaataa buusuu: ${err.toString()}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          data: (allResults) {
            return RefreshIndicator(
              color: const Color(0xFF1B6E32),
              onRefresh: () async {
                ref.invalidate(examResultsStreamProvider);
              },
              child: CustomScrollView(
                slivers: [
                  // 1. Overall Student Improvement Summary Card
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: _buildImprovementHeaderCard(context, stats),
                    ),
                  ),

                  // 2. Score Progression Visualizer / Improvement Trend
                  if (stats.recentChronologicalResults.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: _buildScoreTrendVisualizer(context, stats),
                      ),
                    ),

                  // 3. Subject Filter Chips Bar
                  SliverToBoxAdapter(
                    child: _buildSubjectFilterBar(context, ref, filter, allResults),
                  ),

                  // 4. Section Title with current count & sorting label
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            filter.subjectId == null
                                ? 'Qormaatawwan Hunda (${filteredResults.length})'
                                : 'Qormaatawwan Filataman (${filteredResults.length})',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.swap_vert, size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  filter.sortOrder.labelOm,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 5. Results List or Empty State
                  if (filteredResults.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildEmptyState(context, filter),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 88),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final result = filteredResults[index];
                            return _buildExamResultCard(context, ref, result);
                          },
                          childCount: filteredResults.length,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF1B6E32),
        foregroundColor: Colors.white,
        elevation: 3,
        onPressed: () => _navigateToNewExam(context, filter.subjectId),
        icon: const Icon(Icons.play_arrow),
        label: const Text(
          'Qormaata Haaraa',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  /// 1. Overall Student Improvement Summary Card
  Widget _buildImprovementHeaderCard(BuildContext context, ExamImprovementStats stats) {
    final isImproving = stats.isImproving;
    final deltaStr = stats.improvementDelta >= 0
        ? '+${stats.improvementDelta.toStringAsFixed(1)}%'
        : '${stats.improvementDelta.toStringAsFixed(1)}%';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B6E32), Color(0xFF0D471E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B6E32).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Badge & Trend Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.insights, color: Color(0xFFFFD54F), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Fooyya\'iinsa Qabxii Barataa',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              // Delta chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isImproving
                      ? const Color(0xFF16A34A).withOpacity(0.3)
                      : Colors.orange.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isImproving ? const Color(0xFF4ADE80) : Colors.orange,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isImproving ? Icons.trending_up : Icons.trending_down,
                      color: isImproving ? const Color(0xFF4ADE80) : Colors.orange,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      deltaStr,
                      style: TextStyle(
                        color: isImproving ? const Color(0xFF4ADE80) : Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Localized motivational message
          Text(
            stats.improvementMessageOm,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.35,
            ),
          ),

          const SizedBox(height: 16),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 16),

          // 4-Column Metric Grid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildHeaderStatItem(
                label: 'Qormaata',
                value: '${stats.totalExams}',
                icon: Icons.assignment_turned_in_outlined,
              ),
              _buildHeaderStatItem(
                label: 'Giddu-galeessa',
                value: '${stats.averageScorePercentage.toStringAsFixed(1)}%',
                icon: Icons.pie_chart_outline,
              ),
              _buildHeaderStatItem(
                label: 'Ol\'aanaa',
                value: '${stats.highestScorePercentage.toStringAsFixed(0)}%',
                icon: Icons.military_tech_outlined,
                color: const Color(0xFFFFD54F),
              ),
              _buildHeaderStatItem(
                label: 'Darbiinsa',
                value: '${stats.passRatePercentage.toStringAsFixed(0)}%',
                icon: Icons.check_circle_outline,
                color: const Color(0xFF4ADE80),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStatItem({
    required String label,
    required String value,
    required IconData icon,
    Color? color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 18, color: color ?? Colors.white70),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: color ?? Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.white70),
        ),
      ],
    );
  }

  /// 2. Score Progression Visualizer / Improvement Trend
  Widget _buildScoreTrendVisualizer(BuildContext context, ExamImprovementStats stats) {
    final recent = stats.recentChronologicalResults.length > 7
        ? stats.recentChronologicalResults.sublist(stats.recentChronologicalResults.length - 7)
        : stats.recentChronologicalResults;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.show_chart, color: Color(0xFF1B6E32), size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Dambalii Qabxii (Score Trajectory)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              Text(
                'Qormaata ${recent.length} dhiyoo',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Visual Progress Bars Row
          SizedBox(
            height: 110,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (int i = 0; i < recent.length; i++)
                  Expanded(
                    child: _buildTrendBarItem(
                      result: recent[i],
                      isLatest: i == recent.length - 1,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Duraanii (Oldest)',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF16A34A),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text('>=50%', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  const SizedBox(width: 10),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEA580C),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text('<50%', style: TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
              Text(
                'Dhiyoo (Latest)',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrendBarItem({
    required ExamResult result,
    required bool isLatest,
  }) {
    final pct = result.scorePercentage;
    final isPassed = result.isPassed;
    final barHeightFraction = (pct / 100.0).clamp(0.12, 1.0);
    final barColor = isPassed ? const Color(0xFF16A34A) : const Color(0xFFEA580C);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Score percentage label
          Text(
            '${pct.toInt()}%',
            style: TextStyle(
              fontSize: 10,
              fontWeight: isLatest ? FontWeight.bold : FontWeight.w600,
              color: isLatest ? const Color(0xFF1B6E32) : Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 4),
          // Bar container
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: barHeightFraction,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isLatest ? barColor : barColor.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(6),
                    border: isLatest
                        ? Border.all(color: const Color(0xFF0D471E), width: 1.5)
                        : null,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          // Short date label (MM/dd)
          Text(
            result.dateTaken != null
                ? '${result.dateTaken!.month}/${result.dateTaken!.day}'
                : '--/--',
            style: TextStyle(
              fontSize: 9,
              fontWeight: isLatest ? FontWeight.bold : FontWeight.normal,
              color: isLatest ? const Color(0xFF1B6E32) : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  /// 3. Subject Filter Chips Bar
  Widget _buildSubjectFilterBar(
    BuildContext context,
    WidgetRef ref,
    ExamHistoryFilter currentFilter,
    List<ExamResult> allResults,
  ) {
    final subjects = [
      {'id': null, 'label': 'Hunda (All)', 'icon': Icons.apps},
      {'id': 'herrega', 'label': 'Herrega', 'icon': Icons.calculate},
      {'id': 'afaan_oromoo', 'label': 'Afaan Oromoo', 'icon': Icons.menu_book},
      {'id': 'saayinsii_waliigalaa', 'label': 'Saayinsii Waliigalaa', 'icon': Icons.science},
      {'id': 'hawaasummaa', 'label': 'Barnoota Hawaasummaa', 'icon': Icons.public},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          for (final s in subjects) ...[
            Builder(builder: (context) {
              final id = s['id'] as String?;
              final isSelected = currentFilter.subjectId == id;
              final count = id == null
                  ? allResults.length
                  : allResults.where((r) => r.subjectId.toLowerCase() == id.toLowerCase()).length;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  avatar: Icon(
                    s['icon'] as IconData,
                    size: 16,
                    color: isSelected ? Colors.white : const Color(0xFF1B6E32),
                  ),
                  label: Text('${s['label']} ($count)'),
                  selected: isSelected,
                  selectedColor: const Color(0xFF1B6E32),
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF1E293B),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected ? const Color(0xFF1B6E32) : Colors.grey.shade300,
                    ),
                  ),
                  onSelected: (selected) {
                    ref.read(examHistoryFilterProvider.notifier).update(
                          (state) => state.copyWith(
                            subjectId: () => id,
                          ),
                        );
                  },
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  /// 4. Result Card for each ExamResult record
  Widget _buildExamResultCard(
    BuildContext context,
    WidgetRef ref,
    ExamResult result,
  ) {
    final pct = result.scorePercentage;
    final isPassed = result.isPassed;
    final subjectConfig = _getSubjectConfig(result.subjectId);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0.8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showResultDetailsSheet(context, ref, result, subjectConfig),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Subject icon, title, and formatted date
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: subjectConfig.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(subjectConfig.icon, color: subjectConfig.color, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          result.subjectTitleOm,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 12, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              result.formattedDate,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Score fraction & percentage pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isPassed
                          ? const Color(0xFFDCFCE7)
                          : const Color(0xFFFFEDD5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isPassed ? const Color(0xFF86EFAC) : const Color(0xFFFDBA74),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${pct.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isPassed ? const Color(0xFF15803D) : const Color(0xFFC2410C),
                          ),
                        ),
                        Text(
                          '${result.score}/${result.totalQuestions}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isPassed ? const Color(0xFF166534) : const Color(0xFF9A3412),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 10),

              // Bottom Row: Status pills (Pass/Needs practice, Time, Sync status)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Pass / Fail badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isPassed ? const Color(0xFFF0FDF4) : const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPassed ? Icons.check_circle : Icons.replay,
                          size: 13,
                          color: isPassed ? const Color(0xFF16A34A) : const Color(0xFFEA580C),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isPassed ? 'Darbiteetta' : 'Cimi Yaali',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isPassed ? const Color(0xFF16A34A) : const Color(0xFFEA580C),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Duration Taken
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timer_outlined, size: 13, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        'Yeroo: ${result.formattedTimeTaken}',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ],
                  ),

                  // Offline / Synced flag badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: result.isSynced
                          ? const Color(0xFFF0FDF4)
                          : const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          result.isSynced ? Icons.cloud_done : Icons.cloud_off,
                          size: 13,
                          color: result.isSynced
                              ? const Color(0xFF16A34A)
                              : const Color(0xFFD97706),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          result.isSynced ? 'Qindaa\'eera' : 'Offline',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: result.isSynced
                                ? const Color(0xFF16A34A)
                                : const Color(0xFFD97706),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Empty state when no exam results are found
  Widget _buildEmptyState(BuildContext context, ExamHistoryFilter filter) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF1B6E32).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.assignment_outlined,
                size: 44,
                color: Color(0xFF1B6E32),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              filter.subjectId == null
                  ? 'Qormaanni duraan fudhatame hin jiru'
                  : 'Gosa barnootaa kanaaf qormaanni hin jiru',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Qormaata jalqabaa fudhachuun dandeettii kee gamaaggami, fooyya\'iinsa qabxii keetiis asitti hordofi.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1B6E32),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => _navigateToNewExam(context, filter.subjectId),
              icon: const Icon(Icons.play_arrow),
              label: const Text(
                'Qormaata Jalqabi',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Bottom sheet showing comprehensive performance detail for an ExamResult
  void _showResultDetailsSheet(
    BuildContext context,
    WidgetRef ref,
    ExamResult result,
    _SubjectConfig subjectConfig,
  ) {
    final pct = result.scorePercentage;
    final isPassed = result.isPassed;
    final avgSecondsPerQuestion = result.totalQuestions > 0
        ? (result.timeTaken / result.totalQuestions).toStringAsFixed(1)
        : '0';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header Row
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: subjectConfig.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(subjectConfig.icon, color: subjectConfig.color, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.subjectTitleOm,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Guyyaa: ${result.formattedDate}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Score Highlight Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isPassed ? const Color(0xFFF0FDF4) : const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isPassed ? const Color(0xFFBBF7D0) : const Color(0xFFFED7AA),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        '${pct.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: isPassed ? const Color(0xFF15803D) : const Color(0xFFC2410C),
                        ),
                      ),
                      Text(
                        isPassed ? 'Baga Gammaddan!' : 'Shaakala Dabalataa',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isPassed ? const Color(0xFF15803D) : const Color(0xFFC2410C),
                        ),
                      ),
                    ],
                  ),
                  Container(height: 40, width: 1, color: Colors.grey.shade300),
                  Column(
                    children: [
                      Text(
                        '${result.score} / ${result.totalQuestions}',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        'Gaaffilee Deebiste',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Performance Metrics Table
            _buildDetailRow(
              icon: Icons.timer_outlined,
              label: 'Waliigala Yeroo Fudhatte:',
              value: result.formattedTimeTaken,
            ),
            _buildDetailRow(
              icon: Icons.speed,
              label: 'Giddu-galeessa Gaaffii Tokkoof:',
              value: '$avgSecondsPerQuestion sekondii',
            ),
            _buildDetailRow(
              icon: result.isSynced ? Icons.cloud_done : Icons.cloud_off,
              label: 'Haala Kuusaa (Isar Storage):',
              value: result.isSynced ? 'Synced (Duumessatti qindaa\'e)' : 'Offline (Isar irratti kuufame)',
              valueColor: result.isSynced ? const Color(0xFF16A34A) : const Color(0xFFD97706),
            ),

            const SizedBox(height: 24),

            // Action Buttons: Retake test
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: subjectConfig.color,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                _navigateToNewExam(context, result.subjectId);
              },
              icon: const Icon(Icons.replay),
              label: Text('Gosa Barnootaa Kana Ammas Qori (${result.subjectTitleOm})'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: valueColor ?? const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToNewExam(BuildContext context, String? subjectId) {
    final subId = subjectId ?? 'herrega';
    final config = _getSubjectConfig(subId);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ExamScreen(
          subjectId: subId,
          subjectTitleOm: '${config.titleOm} (Kutaa 8ffaa)',
          durationMinutes: 60,
        ),
      ),
    );
  }

  _SubjectConfig _getSubjectConfig(String subjectId) {
    switch (subjectId.toLowerCase()) {
      case 'herrega':
        return const _SubjectConfig(
          id: 'herrega',
          titleOm: 'Herrega',
          icon: Icons.calculate,
          color: Color(0xFF2563EB),
        );
      case 'afaan_oromoo':
        return const _SubjectConfig(
          id: 'afaan_oromoo',
          titleOm: 'Afaan Oromoo',
          icon: Icons.menu_book,
          color: Color(0xFF16A34A),
        );
      case 'saayinsii_waliigalaa':
        return const _SubjectConfig(
          id: 'saayinsii_waliigalaa',
          titleOm: 'Saayinsii Waliigalaa',
          icon: Icons.science,
          color: Color(0xFF7C3AED),
        );
      case 'hawaasummaa':
      case 'saayinsii_hawaasaa':
        return const _SubjectConfig(
          id: 'hawaasummaa',
          titleOm: 'Barnoota Hawaasummaa',
          icon: Icons.public,
          color: Color(0xFFEA580C),
        );
      case 'lammummaa':
        return const _SubjectConfig(
          id: 'lammummaa',
          titleOm: 'Barnoota Lammummaa',
          icon: Icons.gavel,
          color: Color(0xFF0D9488),
        );
      case 'english':
        return const _SubjectConfig(
          id: 'english',
          titleOm: 'Afaan Ingilizii',
          icon: Icons.language,
          color: Color(0xFFD97706),
        );
      default:
        return const _SubjectConfig(
          id: 'default',
          titleOm: 'Qormaata Waliigalaa',
          icon: Icons.school,
          color: Color(0xFF1B6E32),
        );
    }
  }
}

class _SubjectConfig {
  final String id;
  final String titleOm;
  final IconData icon;
  final Color color;

  const _SubjectConfig({
    required this.id,
    required this.titleOm,
    required this.icon,
    required this.color,
  });
}
