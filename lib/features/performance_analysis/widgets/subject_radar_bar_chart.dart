import 'package:flutter/material.dart';
import '../models/subject_metric.dart';

/// Recharts-inspired horizontal comparative bar chart
/// illustrating subject-wise mastery, average vs highest scores, and pass thresholds.
class SubjectRadarBarChart extends StatelessWidget {
  final Map<String, SubjectMetric> subjectMetrics;
  final ValueChanged<String>? onSubjectSelected;
  final String? selectedSubjectId;

  const SubjectRadarBarChart({
    Key? key,
    required this.subjectMetrics,
    this.onSubjectSelected,
    this.selectedSubjectId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (subjectMetrics.isEmpty) {
      return const SizedBox.shrink();
    }

    final sortedList = subjectMetrics.values.toList()
      ..sort((a, b) => b.averageScorePercentage.compareTo(a.averageScorePercentage));

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainContent.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Wal-bira Qabama Barnootaa',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Subject-Wise Performance Comparison',
                    style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                  ),
                ],
              ),
              // Legend
              Row(
                children: [
                  Container(width: 8, height: 8, decoration: BoxDecoration(color: const Color(0xFF0D47A1), borderRadius: BorderRadius.circular(2))),
                  const SizedBox(width: 4),
                  const Text('Giddu-galeessa', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  const SizedBox(width: 8),
                  Container(width: 8, height: 8, decoration: BoxDecoration(color: const Color(0xFF10B981), borderRadius: BorderRadius.circular(2))),
                  const SizedBox(width: 4),
                  const Text('Ol\'aanaa', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                ],
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Benchmarks Guide (50% Pass line, 80% Distinction line)
          Row(
            children: const [
              Expanded(flex: 50, child: Divider(color: Colors.transparent)),
              Text('50% (Darbi)', style: TextStyle(fontSize: 10, color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
              Expanded(flex: 30, child: Divider(color: Colors.transparent)),
              Text('80% (Qajeelaa)', style: TextStyle(fontSize: 10, color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
              Expanded(flex: 20, child: Divider(color: Colors.transparent)),
            ],
          ),

          const SizedBox(height: 8),

          // List of subject bars
          ...sortedList.map((metric) {
            final isSelected = selectedSubjectId != null &&
                selectedSubjectId!.toLowerCase() == metric.subjectId.toLowerCase();

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 7.0),
              child: InkWell(
                onTap: () => onSubjectSelected?.call(metric.subjectId),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? metric.accentColor.withOpacity(0.08) : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: isSelected ? Border.all(color: metric.accentColor.withOpacity(0.4)) : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Subject name & score labels
                      Row(
                        children: [
                          Icon(metric.icon, size: 15, color: metric.accentColor),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              metric.titleOm,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ),
                          Text(
                            '${metric.averageScorePercentage.toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: metric.accentColor,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '(Max: ${metric.highestScorePercentage.toStringAsFixed(0)}%)',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      // Stacked / Double bar representation
                      Stack(
                        children: [
                          // Background track
                          Container(
                            height: 10,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),

                          // 50% benchmark vertical tick
                          Positioned(
                            left: 0,
                            right: 0,
                            top: 0,
                            bottom: 0,
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: 0.50,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Container(
                                  width: 1.5,
                                  height: 10,
                                  color: const Color(0xFFEF4444).withOpacity(0.5),
                                ),
                              ),
                            ),
                          ),

                          // Highest Score bar (softer green background)
                          FractionallySizedBox(
                            widthFactor: (metric.highestScorePercentage / 100.0).clamp(0.0, 1.0),
                            child: Container(
                              height: 10,
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withOpacity(0.35),
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ),

                          // Average Score bar (main subject color)
                          FractionallySizedBox(
                            widthFactor: (metric.averageScorePercentage / 100.0).clamp(0.0, 1.0),
                            child: Container(
                              height: 10,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    metric.accentColor,
                                    metric.accentColor.withOpacity(0.85),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
