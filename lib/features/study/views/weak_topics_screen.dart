import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../exams/screens/exam_screen.dart';
import '../services/weak_topics_analyzer.dart';

/// Weak Topics Screen displaying analysis of past attempts and offering targeted practice quiz
class WeakTopicsScreen extends ConsumerWidget {
  const WeakTopicsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weakTopicsAsync = ref.watch(weakTopicsListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Mata-dureewwan Dadhaboo',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              'Weak-Topic Analysis & Targeted Practice',
              style: TextStyle(fontSize: 11, color: Colors.black54),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: weakTopicsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text('Dogoggora: ${err.toString()}'),
            ),
          ),
          data: (weakTopics) {
            if (weakTopics.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_outline, color: Color(0xFF15803D), size: 64),
                      const SizedBox(height: 16),
                      const Text(
                        'Baga Gammaddan! Qabxiin keessan gaariidha.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Mata-dureen qabxii gadi-aanaa (<65%) qabu hin jiru. Qabxii keessan eegaa itti fufaa!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF15803D),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        onPressed: () => context.push('/exams'),
                        icon: const Icon(Icons.quiz),
                        label: const Text('Qormaata Shaakali (Take Mock Exam)'),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: weakTopics.length,
              itemBuilder: (context, index) {
                final topic = weakTopics[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDC2626).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.trending_down, color: Color(0xFFDC2626), size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    topic.subjectNameOm,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  Text(
                                    topic.topicNameOm,
                                    style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEE2E2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${topic.averageAccuracyPercentage}%',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Color(0xFFDC2626),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          topic.recommendationOm,
                          style: const TextStyle(fontSize: 12.5, color: Color(0xFF334155), height: 1.3),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          height: 48, // Accessibility minimum touch target
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF15803D),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (ctx) => ExamScreen(
                                    subjectId: topic.subjectId,
                                    subjectTitleOm: topic.subjectNameOm,
                                    durationMinutes: 30, // Targeted weak-topic review duration
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.flash_on, size: 20),
                            label: const Text(
                              'Mata-duree Kana Qofa Shaakali (Practice Topic)',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
