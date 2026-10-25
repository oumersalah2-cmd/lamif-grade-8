import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/time_range_filter.dart';
import '../providers/performance_analysis_provider.dart';
import '../widgets/metric_stat_card.dart';
import '../widgets/performance_trend_chart.dart';
import '../widgets/subject_radar_bar_chart.dart';

/// Performance Analysis Screen visualizing subject-wise exam trends over time
/// pulling from the existing Isar 'ExamResult' collection.
class PerformanceAnalysisScreen extends ConsumerWidget {
  const PerformanceAnalysisScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(performanceAnalysisProvider);
    final notifier = ref.read(performanceAnalysisProvider.notifier);

    // List of active subject filter options
    final subjectFilters = <Map<String, String?>>[
      {'id': null, 'label': 'Barnoota Hunda'},
      {'id': 'herrega', 'label': 'Herrega'},
      {'id': 'afaan_oromoo', 'label': 'Afaan Oromoo'},
      {'id': 'saayinsii_waliigalaa', 'label': 'Saayinsii'},
      {'id': 'hawaasa', 'label': 'Hawaasa'},
      {'id': 'english', 'label': 'English'},
      {'id': 'ict', 'label': 'ICT'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Xiinxala Qabxii (Performance)',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: const Color(0xFFE2E8F0), height: 1.0),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Time Range Selector & Title
              Row(
                mainAxisAlignment: MainContent.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Adeemsa Qabxii Yeroo',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Performance trends over time',
                        style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),

                  // D3 Time Range Pills
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(3),
                    child: Row(
                      mainAxisSize: MainContent.min,
                      children: TimeRangeFilter.values.map((range) {
                        final isSelected = state.timeRange == range;
                        return GestureDetector(
                          onTap: () => notifier.setTimeRange(range),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.06),
                                        offset: const Offset(0, 1),
                                        blurRadius: 4,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Text(
                              range.labelOm,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? const Color(0xFF0D47A1) : const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 2. 2x2 KPI Metric Cards Grid
              Row(
                children: [
                  Expanded(
                    child: MetricStatCard(
                      titleOm: 'Giddu-galeessa',
                      valueText: '${state.overallAverage.toStringAsFixed(1)}%',
                      subtitleOm: 'Qormaata ${state.totalExams} keessaa',
                      icon: Icons.analytics_rounded,
                      iconColor: const Color(0xFF0D47A1),
                      isPositiveTrend: state.isImproving,
                      trendText: state.overallTrendDelta != 0.0
                          ? '${state.overallTrendDelta > 0 ? "+" : ""}${state.overallTrendDelta.toStringAsFixed(1)}%'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MetricStatCard(
                      titleOm: 'Qabxii Ol\'aanaa',
                      valueText: '${state.highestScore.toStringAsFixed(1)}%',
                      subtitleOm: 'Milkaa\'ina guddaa',
                      icon: Icons.military_tech_rounded,
                      iconColor: const Color(0xFFD97706),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: MetricStatCard(
                      titleOm: 'Darbiinsa',
                      valueText: '${state.overallPassRate.toStringAsFixed(0)}%',
                      subtitleOm: 'Ulaagaa 50% ol',
                      icon: Icons.verified_rounded,
                      iconColor: const Color(0xFF16A34A),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MetricStatCard(
                      titleOm: 'Adeemsa Fooyya\'iinsaa',
                      valueText: state.isImproving ? 'Eeyyee' : 'Gadi-bu\'aa',
                      subtitleOm: state.isImproving ? 'Qabxiin dabalaa jira' : 'Xiyyeeffannoo barbaada',
                      icon: state.isImproving ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                      iconColor: state.isImproving ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                      isPositiveTrend: state.isImproving,
                      trendText: state.isImproving ? 'Jabaadhu' : 'Of eeggadhu',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 3. Subject Filter Selector Tabs
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: subjectFilters.map((filter) {
                    final isSelected = state.selectedSubjectId == filter['id'];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        selected: isSelected,
                        onSelected: (_) => notifier.selectSubject(filter['id']),
                        label: Text(filter['label']!),
                        labelStyle: TextStyle(
                          fontSize: 12.5,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.white : const Color(0xFF334155),
                        ),
                        backgroundColor: Colors.white,
                        selectedColor: const Color(0xFF0D47A1),
                        shape: RoundedCornerShape(12),
                        side: BorderSide(
                          color: isSelected ? const Color(0xFF0D47A1) : const Color(0xFFE2E8F0),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 14),

              // 4. D3/Recharts Smooth Bezier Line & Gradient Area Chart
              PerformanceTrendChart(
                points: state.trendPoints,
                activeSubjectTitle: state.selectedSubjectId != null
                    ? mapSubjectIdToTitleOm(state.selectedSubjectId!)
                    : null,
                height: 240,
              ),

              const SizedBox(height: 20),

              // 5. Subject Radar / Comparative Bar Chart
              SubjectRadarBarChart(
                subjectMetrics: state.subjectMetrics,
                selectedSubjectId: state.selectedSubjectId,
                onSubjectSelected: (subId) => notifier.selectSubject(subId),
              ),

              const SizedBox(height: 20),

              // 6. Actionable Academic Insights & Recommendations
              if (state.strongestSubject != null || state.needsFocusSubject != null)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.lightbulb_outline_rounded, color: Color(0xFFD97706), size: 22),
                          SizedBox(width: 8),
                          Text(
                            'Gorsa Qabxii Qormaataa (Insights)',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      if (state.strongestSubject != null)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Barnoota Qajeelaa: ${state.strongestSubject!.titleOm} (${state.strongestSubject!.averageScorePercentage.toStringAsFixed(1)}%). Dandeettii kee itti fufsiisi!',
                                style: const TextStyle(fontSize: 13, color: Color(0xFF334155), height: 1.4),
                              ),
                            ),
                          ],
                        ),

                      if (state.strongestSubject != null && state.needsFocusSubject != null)
                        const SizedBox(height: 10),

                      if (state.needsFocusSubject != null)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.info_outline_rounded, color: Color(0xFFDC2626), size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Xiyyeeffannoo Barbaada: ${state.needsFocusSubject!.titleOm} (${state.needsFocusSubject!.averageScorePercentage.toStringAsFixed(1)}%). Gaaffilee darban irra deebi\'ii shaakali.',
                                style: const TextStyle(fontSize: 13, color: Color(0xFF334155), height: 1.4),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
